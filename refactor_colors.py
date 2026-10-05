import os
import re

dir_path = 'lib/screens'
files = [f for f in os.listdir(dir_path) if f.endswith('.dart')]
files.append('../main.dart')

replacements = {
    'const Color(0xFFF9F9FF)': 'Theme.of(context).colorScheme.surface',
    'Color(0xFFF9F9FF)': 'Theme.of(context).colorScheme.surface',
    
    'Colors.white': 'Theme.of(context).colorScheme.surfaceContainer',
    
    'const Color(0xFF111C2D)': 'Theme.of(context).colorScheme.onSurface',
    'Color(0xFF111C2D)': 'Theme.of(context).colorScheme.onSurface',
    
    'const Color(0xFF3D4947)': 'Theme.of(context).colorScheme.onSurfaceVariant',
    'Color(0xFF3D4947)': 'Theme.of(context).colorScheme.onSurfaceVariant',
    
    'const Color(0xFFDEE8FF)': 'Theme.of(context).colorScheme.surfaceContainerHigh',
    'Color(0xFFDEE8FF)': 'Theme.of(context).colorScheme.surfaceContainerHigh',
    
    'const Color(0xFFF0F3FF)': 'Theme.of(context).colorScheme.surfaceContainerLow',
    'Color(0xFFF0F3FF)': 'Theme.of(context).colorScheme.surfaceContainerLow',
    
    'const Color(0xFFEBDCFF)': 'Theme.of(context).colorScheme.secondaryContainer',
    'Color(0xFFEBDCFF)': 'Theme.of(context).colorScheme.secondaryContainer',
    
    'const Color(0xFF006A62)': 'Theme.of(context).colorScheme.primary',
    'Color(0xFF006A62)': 'Theme.of(context).colorScheme.primary',
    
    'const Color(0xFF26A69A)': 'Theme.of(context).colorScheme.tertiary',
    'Color(0xFF26A69A)': 'Theme.of(context).colorScheme.tertiary',
    
    'const Color(0xFF6F48B2)': 'Theme.of(context).colorScheme.secondary',
    'Color(0xFF6F48B2)': 'Theme.of(context).colorScheme.secondary',
    
    'const Color(0xFF260058)': 'Theme.of(context).colorScheme.onSecondaryContainer',
    'Color(0xFF260058)': 'Theme.of(context).colorScheme.onSecondaryContainer',
}

for file_name in files:
    path = os.path.join(dir_path, file_name)
    if not os.path.exists(path):
        continue
        
    with open(path, 'r') as f:
        content = f.read()
        
    # Strip const from Text, Icon, TextStyle, SizedBox, Row, Column, Container, Padding, Center if it has Theme.of
    # This is a bit tricky with regex, we will instead just do a global replace of "const " to "" on lines that get a Theme.of replacement.
    
    lines = content.split('\n')
    new_lines = []
    for line in lines:
        new_line = line
        needs_const_removal = False
        for k, v in replacements.items():
            if k in new_line:
                new_line = new_line.replace(k, v)
                needs_const_removal = True
                
        if needs_const_removal:
            # If the line contains Theme.of, it can't have 'const ' in front of widgets
            # We'll just aggressively remove 'const ' from the line to be safe
            new_line = new_line.replace('const ', '')
            
        new_lines.append(new_line)
        
    with open(path, 'w') as f:
        f.write('\n'.join(new_lines))

print("Refactored colors!")
