import os
import glob

replacements = {
    'Color(0xFFBA1A1A)': 'AppTheme.error',
    'Color(0xFF005049)': 'AppTheme.primaryText',
    'Color(0xFF84F5E8)': 'AppTheme.primaryContainer',
    'Color(0xFF572E99)': 'AppTheme.secondary',
    'Color(0xFFB78EFE)': 'AppTheme.purpleHighlight',
    'Color(0xFFD8E3FB)': 'AppTheme.subtle',
    'Color(0xFFE7EEFF)': 'AppTheme.subtle',
    'Color(0xFF003430)': 'AppTheme.primaryText',
    'Color(0xFFFFFFFF)': 'AppTheme.cardBg',
    'Color(0xFF8EF4E9)': 'AppTheme.primary',
    'Color(0xFF00201D)': 'AppTheme.textPrimary',
}

for file_path in glob.glob('lib/screens/*.dart'):
    with open(file_path, 'r') as f:
        content = f.read()
    
    for old_val, new_val in replacements.items():
        content = content.replace(old_val, new_val)
        
    with open(file_path, 'w') as f:
        f.write(content)
print("Replaced colors in all screen files successfully.")
