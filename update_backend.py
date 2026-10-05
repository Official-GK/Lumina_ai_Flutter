import os

# 1. Update .env
with open('backend/.env', 'a') as f:
    f.write('\nADZUNA_APP_ID=c4bd6486\nADZUNA_APP_KEY=200752c3e8713f5d94b14b47ad7de740\n')

# 2. Update requirements.txt
with open('backend/requirements.txt', 'r') as f:
    reqs = f.read()
if 'httpx' not in reqs:
    with open('backend/requirements.txt', 'a') as f:
        f.write('\nhttpx\n')

# 3. Update main.py
with open('backend/main.py', 'r') as f:
    content = f.read()

import re

if 'import httpx' not in content:
    content = content.replace('import json', 'import json\nimport httpx')

old_jobs_func = """_JOB_TEMPLATES = [
    {"title": "Senior {skill} Engineer",      "company": "Stripe",    "salary": "$140k–$190k", "match": 91},
    {"title": "{skill} Developer",             "company": "Anthropic", "salary": "$130k–$175k", "match": 84},
    {"title": "Lead {skill} Architect",        "company": "Figma",     "salary": "$155k–$200k", "match": 78},
    {"title": "{skill} Specialist",            "company": "Notion",    "salary": "$90–$120/hr", "match": 72},
    {"title": "Junior {skill} Engineer",       "company": "Linear",    "salary": "$95k–$130k",  "match": 65},
]

@app.get("/api/recommend-jobs", tags=["Recommendations"])
async def recommend_jobs(
    skills: str = Query(..., description="Comma-separated skills, e.g. python,react"),
    token: dict = Depends(verify_token),
) -> JSONResponse:
    \"\"\"Returns ranked mock job listings matched to the provided skills.\"\"\"
    skill_list = [s.strip().title() for s in skills.split(",") if s.strip()]
    primary = skill_list[0] if skill_list else "Software"

    jobs = []
    for i, tmpl in enumerate(_JOB_TEMPLATES):
        sk = skill_list[i % len(skill_list)] if skill_list else primary
        jobs.append({
            "id": f"job_{i+1}",
            "title":          tmpl["title"].replace("{skill}", sk),
            "company":        tmpl["company"],
            "location":       "Remote / Hybrid",
            "type":           "Full-time",
            "salary_range":   tmpl["salary"],
            "match_score":    tmpl["match"],
            "required_skills": skill_list[:3],
            "logo_url": f"https://logo.clearbit.com/{tmpl['company'].lower()}.com",
        })

    return JSONResponse({"status": "success", "count": len(jobs), "jobs": jobs})"""

new_jobs_func = """@app.get("/api/recommend-jobs", tags=["Recommendations"])
async def recommend_jobs(
    skills: str = Query("Flutter", description="Comma-separated skills, e.g. python,react"),
    country: str = Query("in", description="Country code"),
    page: int = Query(1, description="Page number"),
    results_per_page: int = Query(10, description="Results per page"),
    token: dict = Depends(verify_token),
) -> JSONResponse:
    \"\"\"Returns real job listings matched to the provided skills from Adzuna.\"\"\"
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
                        salary_str = f"₹{int(salary_min):,} - ₹{int(salary_max):,}"
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
        
    return JSONResponse({"status": "success", "count": len(jobs), "jobs": jobs})"""

if old_jobs_func in content:
    content = content.replace(old_jobs_func, new_jobs_func)
else:
    print("Could not find old jobs func!")
    
with open('backend/main.py', 'w') as f:
    f.write(content)

print("Backend updated.")
