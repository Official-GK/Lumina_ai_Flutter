import re

with open('backend/main.py', 'r') as f:
    content = f.read()

def indian_format(num):
    s = str(num)
    if len(s) > 3:
        return re.sub(r'\d(?=(\d{2})+\d{3}$)', r'\g<0>,', s)
    return s

target = 'salary_str = f"₹{int(salary_min):,} - ₹{int(salary_max):,}"'
replacement = '''
                        def in_fmt(n):
                            s = str(int(n))
                            if len(s) > 3:
                                import re
                                s = s[:-3] + "," + s[-3:]
                                while len(s) > 6 and s[-7] != ",":
                                    s = s[:-6] + "," + s[-6:]
                            return s
                        salary_str = f"₹{in_fmt(salary_min)} - ₹{in_fmt(salary_max)}"
'''

if target in content:
    content = content.replace(target, replacement)
    with open('backend/main.py', 'w') as f:
        f.write(content)
    print("Updated backend/main.py")
else:
    print("Target not found in main.py")
