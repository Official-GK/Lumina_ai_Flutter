import re

path = 'lib/screens/dashboard_screen.dart'
with open(path, 'r') as f:
    content = f.read()

# Replace all occurrences of "const "
content = re.sub(r'\bconst\s+', '', content)

with open(path, 'w') as f:
    f.write(content)
