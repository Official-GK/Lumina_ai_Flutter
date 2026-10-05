# ─────────────────────────────────────────────────────────
# Lumina Career AI — FastAPI Backend (local-ready main.py)
# ─────────────────────────────────────────────────────────
# Local dev:  uvicorn main:app --reload --host 0.0.0.0 --port 8000
# Production: uvicorn main:app --host 0.0.0.0 --port $PORT
# ─────────────────────────────────────────────────────────

import os
import asyncio
import io
import json
import httpx
import logging
import traceback
from pathlib import Path
from typing import Any

# ── Load .env file if present (local dev only) ─────────────
from dotenv import load_dotenv
load_dotenv()  # reads backend/.env automatically

import pdfplumber
import google.generativeai as genai
import firebase_admin
from firebase_admin import auth, credentials, firestore

from fastapi import (
    FastAPI, File, Form, UploadFile,
    Header, HTTPException, Depends, Query
)
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel

# ── Logging ─────────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)
logger = logging.getLogger(__name__)


# ═══════════════════════════════════════════════════════════
# 1. Firebase Admin SDK — init once
#    Priority:
#      a) serviceAccountKey.json next to main.py  (local dev)
#      b) GOOGLE_APPLICATION_CREDENTIALS_JSON env  (Render)
# ═══════════════════════════════════════════════════════════
def _init_firebase() -> None:
    if firebase_admin._apps:
        return  # already initialised (guards against hot-reload re-runs)

    local_key = Path(__file__).parent / "serviceAccountKey.json"

    if local_key.exists():
        # ── Local development path ──────────────────────────
        cred = credentials.Certificate(str(local_key))
        logger.info("Firebase: using local serviceAccountKey.json")
    else:
        # ── Production / Render path ────────────────────────
        raw = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS_JSON")
        if not raw:
            raise EnvironmentError(
                "Neither serviceAccountKey.json nor "
                "GOOGLE_APPLICATION_CREDENTIALS_JSON env var found."
            )
        cred = credentials.Certificate(json.loads(raw))
        logger.info("Firebase: using GOOGLE_APPLICATION_CREDENTIALS_JSON env var")

    firebase_admin.initialize_app(cred)
    logger.info("Firebase Admin SDK initialised ✓")


_init_firebase()
db = firestore.client()


# ═══════════════════════════════════════════════════════════
# 2. Gemini SDK
# ═══════════════════════════════════════════════════════════
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
if not GEMINI_API_KEY:
    raise EnvironmentError(
        "GEMINI_API_KEY is not set. "
        "Add it to backend/.env or as a system environment variable."
    )

genai.configure(api_key=GEMINI_API_KEY)
gemini_model = genai.GenerativeModel("gemini-2.5-flash")
logger.info("Gemini SDK initialised ✓")


# ═══════════════════════════════════════════════════════════
# 3. FastAPI app + CORS
# ═══════════════════════════════════════════════════════════
app = FastAPI(
    title="Lumina Career AI — Backend",
    description=(
        "Handles resume analysis (Gemini), career chat, "
        "and personalised job/course recommendations."
    ),
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],      # tighten to your domain in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ═══════════════════════════════════════════════════════════
# 4. Auth dependency  —  verify_token
#    Flutter sends:  Authorization: Bearer <firebase_id_token>
#    Returns the decoded token dict (contains uid, email, …)
# ═══════════════════════════════════════════════════════════
async def verify_token(authorization: str = Header(None)) -> dict:
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=401,
            detail="Missing or malformed Authorization header. "
                   "Expected: 'Bearer <firebase_id_token>'",
        )
    id_token = authorization.split("Bearer ", 1)[1]
    try:
        return auth.verify_id_token(id_token)
    except auth.ExpiredIdTokenError:
        raise HTTPException(status_code=401, detail="Firebase ID token has expired.")
    except auth.InvalidIdTokenError:
        raise HTTPException(status_code=401, detail="Firebase ID token is invalid.")
    except Exception as exc:
        logger.error("Token verification failed: %s", exc)
        raise HTTPException(status_code=401, detail=f"Token error: {exc}")


# ═══════════════════════════════════════════════════════════
# 5. Pydantic schemas
# ═══════════════════════════════════════════════════════════
class ChatMessage(BaseModel):
    role: str   # "user" | "model"
    text: str

class ChatRequest(BaseModel):
    user_message: str
    history: list[ChatMessage] = []


# ═══════════════════════════════════════════════════════════
# 6. Helpers
# ═══════════════════════════════════════════════════════════
def _extract_pdf_text(file_bytes: bytes) -> str:
    """Extract plain text from a PDF byte-stream using pdfplumber."""
    parts: list[str] = []
    try:
        with pdfplumber.open(io.BytesIO(file_bytes)) as pdf:
            for page in pdf.pages:
                t = page.extract_text()
                if t:
                    parts.append(t)
    except Exception as exc:
        raise ValueError(f"Could not read PDF: {exc}")

    text = "\n".join(parts)
    if not text:
        raise ValueError(
            "PDF is empty or image-only — no extractable text found."
        )
    return text


def _call_gemini(prompt: str, expect_json: bool = False) -> str:
    """Send a prompt to Gemini and return the response text."""
    config: dict[str, Any] = {}
    if expect_json:
        config["response_mime_type"] = "application/json"
    try:
        resp = gemini_model.generate_content(
            prompt,
            generation_config=config or None,
        )
        return resp.text
    except Exception as exc:
        logger.error("Gemini error: %s\n%s", exc, traceback.format_exc())
        raise RuntimeError(f"AI service error: {exc}")


# ═══════════════════════════════════════════════════════════
# 7. Health check (public — Render liveness probe)
# ═══════════════════════════════════════════════════════════
@app.get("/", tags=["Health"])
async def root():
    return {"status": "ok", "service": "Lumina Career AI Backend v1.0"}


# ═══════════════════════════════════════════════════════════
# 8. POST /api/analyze-resume  (PROTECTED)
# ═══════════════════════════════════════════════════════════
_RESUME_PROMPT = """
You are an elite AI Career Counselor with 15+ years of experience at Google, Meta, and Anthropic.

A student has uploaded their resume. Perform a ruthlessly honest gap analysis.

RULES:
1. Extract every technical and soft skill present in the resume.
2. Identify precisely which skills are MISSING to be competitive for the target career.
3. Build a concrete week-by-week learning roadmap (4–8 milestones).
4. Recommend 2–3 portfolio projects that directly signal competency to Tier-1 recruiters.
5. Calculate a profile_score (0–100) based on skill match to the target career.

CRITICAL OUTPUT RULE:
Respond with ONLY valid JSON — no markdown fences, no prose, no explanation.
Follow this EXACT schema:
{
  "current_skills": ["string"],
  "target_career": "string",
  "missing_skills": ["string"],
  "profile_score": integer,
  "roadmap": [
    {
      "step": integer,
      "title": "string",
      "description": "string",
      "duration": "string"
    }
  ],
  "recommended_projects": [
    {
      "title": "string",
      "description": "string",
      "tech_stack": ["string"]
    }
  ]
}
"""

@app.post("/api/analyze-resume", tags=["AI Core"])
async def analyze_resume(
    file: UploadFile = File(..., description="PDF resume"),
    target_career: str = Form(..., description="Target job title / career path"),
    token: dict = Depends(verify_token),
) -> JSONResponse:
    """
    Accepts a PDF resume + target career.
    → Extracts text  → Calls Gemini  → Writes to Firestore  → Returns JSON.
    """
    uid = token["uid"]
    logger.info("analyze-resume  uid=%s  target='%s'", uid, target_career)

    # ── Validate file type ─────────────────────────────────
    if not (file.filename or "").lower().endswith(".pdf"):
        raise HTTPException(status_code=400, detail="Only PDF files are accepted.")

    # ── Extract PDF text ───────────────────────────────────
    raw_bytes = await file.read()
    try:
        resume_text = _extract_pdf_text(raw_bytes)
    except ValueError as exc:
        raise HTTPException(status_code=422, detail=str(exc))

    # ── Build and send Gemini prompt ───────────────────────
    prompt = (
        f"{_RESUME_PROMPT}\n\n"
        f"--- RESUME START ---\n{resume_text}\n--- RESUME END ---\n\n"
        f"Target Career: {target_career}"
    )
    try:
        raw_json = _call_gemini(prompt, expect_json=True)
    except RuntimeError as exc:
        raise HTTPException(status_code=503, detail=str(exc))

    # ── Parse Gemini output ────────────────────────────────
    try:
        analysis: dict[str, Any] = json.loads(raw_json)
    except json.JSONDecodeError:
        logger.error("Gemini returned invalid JSON:\n%s", raw_json)
        raise HTTPException(
            status_code=500,
            detail="AI returned malformed data — please retry.",
        )

    # ── Write to Firestore ─────────────────────────────────
    try:
        ts = firestore.SERVER_TIMESTAMP

        # Build roadmap steps — add a default status if the AI didn't include one
        roadmap_steps = []
        for i, step in enumerate(analysis.get("roadmap", [])):
            roadmap_steps.append({
                "step":              step.get("step", i + 1),
                "title":             step.get("title", ""),
                "description":       step.get("description", ""),
                "duration":          step.get("duration", ""),
                "status":            step.get("status", "in_progress" if i == 0 else "pending"),
                "completion_percent": step.get("completion_percent", 0.0),
            })

        db.collection("profiles").document(uid).set(
            {
                "uid":                    uid,
                "target_career":          analysis.get("target_career", target_career),
                "current_skills":         analysis.get("current_skills", []),
                "missing_skills":         analysis.get("missing_skills", []),
                "profile_score":          analysis.get("profile_score", 0),
                "next_recommended_step":  roadmap_steps[0]["title"] if roadmap_steps else "",
                "weeks_to_role":          analysis.get("weeks_to_role", len(roadmap_steps)),
                "last_analyzed":          ts,
            },
            merge=True,
        )
        db.collection("roadmaps").document(uid).set(
            {
                "uid":        uid,
                "steps":      roadmap_steps,
                "updated_at": ts,
            },
            merge=True,
        )

        projects = []
        for p in analysis.get("recommended_projects", []):
            projects.append({
                "title":          p.get("title", ""),
                "description":    p.get("description", ""),
                "tech_stack":     p.get("tech_stack", []),
                "difficulty":     p.get("difficulty", "Intermediate"),
                "estimated_time": p.get("estimated_time", "2 Weeks"),
                "github_url":     p.get("github_url", ""),
            })

        db.collection("portfolios").document(uid).set(
            {
                "uid":                  uid,
                "recommended_projects": projects,
                "completed_projects":   [],
                "updated_at":           ts,
            },
            merge=True,
        )
        logger.info("Firestore updated for uid=%s ✓", uid)
    except Exception as exc:
        logger.error("Firestore write error uid=%s: %s", uid, exc)
        # Return the analysis data AND a warning — the Flutter app will still show
        # the score from the response body even if Firestore is unavailable.
        return JSONResponse(
            status_code=200,
            content={
                "status":  "partial_success",
                "warning": f"AI analysis succeeded but database write failed: {exc}. "
                           "Please enable Cloud Firestore API at https://console.firebase.google.com/project/ai-career--skill/firestore",
                "data":    analysis,
            },
        )

    return JSONResponse({"status": "success", "data": analysis})


# ═══════════════════════════════════════════════════════════
# 9. POST /api/chat-assistant  (PROTECTED)
# ═══════════════════════════════════════════════════════════
_CHAT_SYSTEM = (
    "You are Lumina, an expert AI career assistant specialised in helping students "
    "land roles at top technology companies. Give direct, actionable advice. "
    "Keep answers under 180 words unless the user explicitly requests detail. "
    "Always maintain a warm, encouraging tone."
)

@app.post("/api/chat-assistant", tags=["AI Core"])
async def chat_assistant(
    body: ChatRequest,
    token: dict = Depends(verify_token),
) -> JSONResponse:
    """Multi-turn AI career chat. Returns Lumina's reply text with student context."""
    uid = token["uid"]
    logger.info("chat-assistant  uid=%s", uid)

    # Fetch user profile & user data from Firestore for personalized AI responses
    user_context = ""
    if db:
        try:
            profile_doc = db.collection("profiles").document(uid).get()
            user_doc = db.collection("users").document(uid).get()
            name = user_doc.to_dict().get("full_name", "Student") if user_doc.exists else "Student"
            
            if profile_doc.exists:
                pdata = profile_doc.to_dict() or {}
                target = pdata.get("target_career", "Tech Role")
                c_skills = ", ".join(pdata.get("current_skills", [])) or "None listed"
                m_skills = ", ".join(pdata.get("missing_skills", [])) or "None listed"
                score = pdata.get("profile_score", 0)
                user_context = (
                    f"\n[Student Context]\n"
                    f"Name: {name}\n"
                    f"Target Role: {target}\n"
                    f"Readiness Score: {score}%\n"
                    f"Current Skills: {c_skills}\n"
                    f"Skill Gaps to Learn: {m_skills}\n"
                )
        except Exception as e:
            logger.warning("Failed to load profile context for assistant: %s", e)

    # Keep only the last 10 turns to avoid token overflow
    history_text = ""
    for msg in body.history[-10:]:
        label = "Student" if msg.role == "user" else "Lumina"
        history_text += f"{label}: {msg.text}\n"

    prompt = (
        f"{_CHAT_SYSTEM}\n"
        f"{user_context}\n"
        f"--- Conversation so far ---\n{history_text}"
        f"Student: {body.user_message}\nLumina:"
    )
    try:
        reply = _call_gemini(prompt, expect_json=False)
    except RuntimeError as exc:
        raise HTTPException(status_code=503, detail=str(exc))

    return JSONResponse({"status": "success", "reply": reply.strip()})


# ═══════════════════════════════════════════════════════════
# 10. GET /api/recommend-jobs  (PROTECTED)
# ═══════════════════════════════════════════════════════════
@app.get("/api/recommend-jobs", tags=["Recommendations"])
async def recommend_jobs(
    skills: str = Query("Flutter", description="Comma-separated skills, e.g. python,react"),
    country: str = Query("in", description="Country code"),
    page: int = Query(1, description="Page number"),
    results_per_page: int = Query(10, description="Results per page"),
    token: dict = Depends(verify_token),
) -> JSONResponse:
    """Returns real job listings matched to the provided skills from Adzuna."""
    app_id = os.getenv("ADZUNA_APP_ID", "c4bd6486")
    app_key = os.getenv("ADZUNA_APP_KEY", "200752c3e8713f5d94b14b47ad7de740")
    
    url = f"https://api.adzuna.com/v1/api/jobs/{country}/search/{page}"
    params = {
        "app_id": app_id,
        "app_key": app_key,
        "what": skills,
        "results_per_page": results_per_page
    }
    headers = {"Accept": "application/json"}
    
    jobs = []
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(url, params=params, headers=headers, timeout=10.0)
            if response.status_code == 200:
                data = response.json()
                results = data.get("results", [])
                for item in results:
                    salary_min = item.get("salary_min")
                    salary_max = item.get("salary_max")
                    
                    if salary_min and salary_max:
                        
                        def in_fmt(n):
                            s = str(int(n))
                            if len(s) > 3:
                                import re
                                s = s[:-3] + "," + s[-3:]
                                while len(s) > 6 and s[-7] != ",":
                                    s = s[:-6] + "," + s[-6:]
                            return s
                        salary_str = f"₹{in_fmt(salary_min)} - ₹{in_fmt(salary_max)}"

                    else:
                        salary_str = "Competitive / Disclosed on Apply"
                        
                    jobs.append({
                        "id": str(item.get("id", "")),
                        "title": item.get("title", "Untitled Role"),
                        "company": item.get("company", {}).get("display_name", "Confidential"),
                        "location": item.get("location", {}).get("display_name", "Remote / Multiple Locations"),
                        "salary": salary_str,
                        "description": item.get("description", "").strip(),
                        "redirect_url": item.get("redirect_url", "")
                    })
    except Exception as e:
        print(f"Adzuna API Error: {e}")
        
    return JSONResponse({"status": "success", "count": len(jobs), "jobs": jobs})


# ═══════════════════════════════════════════════════════════
# 11. GET /api/recommend-courses  (PROTECTED)
# ═══════════════════════════════════════════════════════════
@app.get("/api/recommend-courses", tags=["Recommendations"])
async def recommend_courses(
    skills: str = Query(..., description="Comma-separated skills, e.g. python,react"),
    token: dict = Depends(verify_token),
) -> JSONResponse:
    """Returns course recommendations matched to the provided skills from local JSON."""
    try:
        def read_db():
            with open("courses_db.json", "r") as f:
                return json.load(f)
        all_courses = await asyncio.to_thread(read_db)
    except Exception as e:
        return JSONResponse({"status": "error", "detail": "Could not read courses_db.json"}, status_code=500)

    import re
    # Split by comma, space, slash, etc. to get individual words
    words = re.split(r'[^a-zA-Z0-9]', skills.lower())
    search_tokens = {w for w in words if len(w) > 1}
    
    results = []
    for course in all_courses:
        title = course.get("title", "").lower()
        tags = [t.lower() for t in course.get("tags", [])]
        
        course_text = title + " " + " ".join(tags)
        
        matched = False
        for token in search_tokens:
            if token in course_text:
                matched = True
                break
                
        if matched:
            results.append(course)

    if not results:
        # Fallback to random 4 highly rated courses
        import random
        results = random.sample(all_courses, min(4, len(all_courses)))
        
    results = results[:5]
    return JSONResponse({"status": "success", "count": len(results), "courses": results})


# ═══════════════════════════════════════════════════════════
# 12. GET /api/profile, /api/roadmap, /api/portfolio  (PROTECTED)
# ═══════════════════════════════════════════════════════════
def _safe_dict(doc_snapshot) -> dict:
    """Convert Firestore doc to a JSON-safe dict (handles Timestamps)."""
    data = doc_snapshot.to_dict() or {}
    for k, v in data.items():
        # Firestore DatetimeWithNanoseconds → ISO string
        if hasattr(v, "isoformat"):
            data[k] = v.isoformat()
    return data

@app.get("/api/profile", tags=["User Data"])
async def get_profile(token: dict = Depends(verify_token)) -> JSONResponse:
    uid = token["uid"]
    doc = db.collection("profiles").document(uid).get()
    if not doc.exists:
        raise HTTPException(404, "Profile not found — upload your resume first.")
    return JSONResponse({"status": "success", "profile": _safe_dict(doc)})

@app.get("/api/roadmap", tags=["User Data"])
async def get_roadmap(token: dict = Depends(verify_token)) -> JSONResponse:
    uid = token["uid"]
    doc = db.collection("roadmaps").document(uid).get()
    if not doc.exists:
        raise HTTPException(404, "Roadmap not found — upload your resume first.")
    return JSONResponse({"status": "success", "roadmap": _safe_dict(doc)})

@app.get("/api/portfolio", tags=["User Data"])
async def get_portfolio(token: dict = Depends(verify_token)) -> JSONResponse:
    uid = token["uid"]
    doc = db.collection("portfolios").document(uid).get()
    if not doc.exists:
        raise HTTPException(404, "Portfolio not found.")
    return JSONResponse({"status": "success", "portfolio": _safe_dict(doc)})


# ═══════════════════════════════════════════════════════════
# Uvicorn entry-point
# ═══════════════════════════════════════════════════════════
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=int(os.getenv("PORT", 8000)),
        reload=True,   # set False in production
    )
