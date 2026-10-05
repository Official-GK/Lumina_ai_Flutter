import os
import re

dir_path = 'lib/screens'
files = [f for f in os.listdir(dir_path) if f.endswith('.dart')]
files.append('../main.dart')

replacements = {
    'Color(0xFFF9F9FF)': 'AppTheme.bg',
    'Colors.white': 'AppTheme.cardBg',
    'Color(0xFF111C2D)': 'AppTheme.textPrimary',
    'Color(0xFF3D4947)': 'AppTheme.textSecondary',
    'Color(0xFFDEE8FF)': 'AppTheme.highlight',
    'Color(0xFFF0F3FF)': 'AppTheme.subtle',
    'Color(0xFFEBDCFF)': 'AppTheme.purpleHighlight',
    'Color(0xFF006A62)': 'AppTheme.primary',
    'Color(0xFF26A69A)': 'AppTheme.tertiary',
    'Color(0xFF6F48B2)': 'AppTheme.secondary',
    'Color(0xFF260058)': 'AppTheme.deepPurpleText',
    'Colors.grey': 'AppTheme.grey',
}

for file_name in files:
    path = os.path.join(dir_path, file_name)
    if not os.path.exists(path):
        continue
        
    with open(path, 'r') as f:
        content = f.read()
    
    original_content = content
    
    # Do replacements
    for k, v in replacements.items():
        # replace const version first
        content = content.replace(f'const {k}', v)
        content = content.replace(k, v)
        
    # Remove "const " globally
    content = re.sub(r'\bconst\s+', '', content)
    
    # Add import 'package:final_projectg/app_theme.dart'; or similar
    # we can just use relative import if in screens
    if 'screens' in path:
        if "import '../app_theme.dart';" not in content:
            content = "import '../app_theme.dart';\n" + content
    else:
        if "import 'app_theme.dart';" not in content:
            content = "import 'app_theme.dart';\n" + content

    with open(path, 'w') as f:
        f.write(content)

print("Refactor completed")
