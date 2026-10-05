import re
import os

screens = ['dashboard_screen.dart', 'jobs_screen.dart', 'learning_screen.dart', 'roadmap_screen.dart', 'pricing_screen.dart']

for s in screens:
    path = os.path.join('lib/screens', s)
    if not os.path.exists(path): continue
    
    with open(path, 'r') as f:
        content = f.read()

    # Step 1: Remove the broken GestureDetector start and the trailing ')' after 16
    # Broken format: GestureDetector(onTap: () => Navigator.pushNamed(context, '/profile'), child: CircleAvatar(radius: 16))
    # or with newlines: child: CircleAvatar(\n      radius: 16))
    
    pattern = r"GestureDetector\(onTap: \(\) => Navigator\.pushNamed\(context, '/profile'\), child: CircleAvatar\(\s*radius:\s*16\)\)"
    
    def unwrap(match):
        # We restore just the CircleAvatar start. Wait, the original had newlines or not?
        # Let's just use CircleAvatar(radius: 16
        s = match.group(0)
        if '\n' in s:
            return "CircleAvatar(\n      radius: 16"
        return "CircleAvatar(radius: 16"
        
    content = re.sub(pattern, unwrap, content)
    
    # Step 2: Now correctly wrap the entire CircleAvatar block.
    # The CircleAvatar block always starts with CircleAvatar(radius: 16
    # and ends with a matching parenthesis.
    
    def wrap_properly(content):
        # Find 'CircleAvatar(radius: 16'
        # Wait, in some files it's 'CircleAvatar(\n      radius: 16'
        
        idx = content.find('CircleAvatar(')
        if idx == -1: return content
        
        # Check if this CircleAvatar has radius: 16 soon after
        sub = content[idx:idx+50]
        if 'radius: 16' not in sub:
            return content
            
        # Find the matching closing parenthesis for CircleAvatar
        open_parens = 0
        end_idx = -1
        for i in range(idx, len(content)):
            if content[i] == '(':
                open_parens += 1
            elif content[i] == ')':
                open_parens -= 1
                if open_parens == 0:
                    end_idx = i
                    break
                    
        if end_idx != -1:
            before = content[:idx]
            avatar_block = content[idx:end_idx+1]
            after = content[end_idx+1:]
            
            wrapped = "GestureDetector(onTap: () => Navigator.pushNamed(context, '/profile'), child: " + avatar_block + ")"
            return before + wrapped + after
        return content
        
    # Apply wrap_properly. Since there might be only one such CircleAvatar per file (in the appbar),
    # we just run it once.
    new_content = wrap_properly(content)
    
    with open(path, 'w') as f:
        f.write(new_content)

print("Fixed CircleAvatar wraps")
