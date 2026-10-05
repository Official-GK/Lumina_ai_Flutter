import re

with open("backend/main.py", "r") as f:
    content = f.read()

# Add aiofiles if missing (but we can use standard json/open synchronously since it's just a local file, wait, they asked for asynchronously reading it, so let's import json and asyncio, but actually we can just read it synchronously in FastAPI, or use standard open if it's small, or use asyncio.to_thread). I'll use asyncio.to_thread.
if "import asyncio" not in content:
    content = content.replace("import os", "import os\nimport asyncio")

old_route = """_COURSE_TEMPLATES = [
    {"title": "Complete {skill} Bootcamp 2025",            "provider": "Coursera",         "rating": 4.8, "signal": "HIGH",   "price": "Free trial"},
    {"title": "{skill} for Production Systems",            "provider": "Udemy",            "rating": 4.6, "signal": "MEDIUM", "price": "$12.99"},
    {"title": "Stanford: Advanced {skill}",                "provider": "Stanford Online",   "rating": 4.9, "signal": "HIGH",   "price": "$49/mo"},
    {"title": "{skill} Design Patterns",                   "provider": "Pluralsight",       "rating": 4.5, "signal": "MEDIUM", "price": "$29/mo"},
    {"title": "Google {skill} Professional Certificate",   "provider": "Google Career Cert","rating": 4.7, "signal": "HIGH",   "price": "$49/mo"},
]

@app.get("/api/recommend-courses", tags=["Recommendations"])
async def recommend_courses(
    skills: str = Query(..., description="Comma-separated skills, e.g. python,react"),
    token: dict = Depends(verify_token),
) -> JSONResponse:
    \"\"\"Returns ranked mock course recommendations matched to the provided skills.\"\"\"
    skill_list = [s.strip().title() for s in skills.split(",") if s.strip()]
    primary = skill_list[0] if skill_list else "Software Engineering"

    courses = []
    for i, tmpl in enumerate(_COURSE_TEMPLATES):
        sk = skill_list[i % len(skill_list)] if skill_list else primary
        courses.append({
            "id":               f"course_{i+1}",
            "title":            tmpl["title"].replace("{skill}", sk),
            "provider":         tmpl["provider"],
            "duration":         f"{(i+1)*10} hours",
            "level":            ["Beginner", "Intermediate", "Advanced"][i % 3],
            "rating":           tmpl["rating"],
            "price":            tmpl["price"],
            "certificate":      True,
            "recruiter_signal": tmpl["signal"],
            "covers_skills":    skill_list[:2],
            "thumbnail":        f"https://picsum.photos/seed/course{i+1}/300/160",
        })

    return JSONResponse({"status": "success", "count": len(courses), "courses": courses})"""

new_route = """@app.get("/api/recommend-courses", tags=["Recommendations"])
async def recommend_courses(
    skills: str = Query(..., description="Comma-separated skills, e.g. python,react"),
    token: dict = Depends(verify_token),
) -> JSONResponse:
    \"\"\"Returns course recommendations matched to the provided skills from local JSON.\"\"\"
    try:
        def read_db():
            with open("courses_db.json", "r") as f:
                return json.load(f)
        all_courses = await asyncio.to_thread(read_db)
    except Exception as e:
        return JSONResponse({"status": "error", "detail": "Could not read courses_db.json"}, status_code=500)

    skill_list = [s.strip().lower() for s in skills.split(",") if s.strip()]
    
    results = []
    for course in all_courses:
        title = course.get("title", "").lower()
        tags = [t.lower() for t in course.get("tags", [])]
        
        # Check if any skill matches title or tags
        matched = False
        for sk in skill_list:
            if sk in title or sk in tags:
                matched = True
                break
                
        if matched:
            results.append(course)

    if not results:
        # Fallback to random 4 highly rated courses
        import random
        results = random.sample(all_courses, min(4, len(all_courses)))
        
    results = results[:5]
    return JSONResponse({"status": "success", "count": len(results), "courses": results})"""

content = content.replace(old_route, new_route)

with open("backend/main.py", "w") as f:
    f.write(content)
print("main.py updated!")
