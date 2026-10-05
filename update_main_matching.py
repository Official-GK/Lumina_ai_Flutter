import re

with open("backend/main.py", "r") as f:
    content = f.read()

old_logic = """    skill_list = [s.strip().lower() for s in skills.split(",") if s.strip()]
    
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
            results.append(course)"""

new_logic = """    import re
    # Split by comma, space, slash, etc. to get individual words
    words = re.split(r'[^a-zA-Z0-9]', skills.lower())
    search_tokens = {w for w in words if len(w) > 2}
    
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
            results.append(course)"""

content = content.replace(old_logic, new_logic)

with open("backend/main.py", "w") as f:
    f.write(content)
print("Updated matching logic in main.py")
