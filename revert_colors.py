import os

dir_path = 'lib/screens'
files = [f for f in os.listdir(dir_path) if f.endswith('.dart')]
files.append('../main.dart')

replacements = {
    'Theme.of(context).colorScheme.surfaceContainerHigh': 'Color(0xFFDEE8FF)',
    'Theme.of(context).colorScheme.surfaceContainerLow': 'Color(0xFFF0F3FF)',
    'Theme.of(context).colorScheme.surfaceContainer': 'Colors.white',
    'Theme.of(context).colorScheme.surface': 'Color(0xFFF9F9FF)',
    'Theme.of(context).colorScheme.onSurfaceVariant': 'Color(0xFF3D4947)',
    'Theme.of(context).colorScheme.onSurface': 'Color(0xFF111C2D)',
    'Theme.of(context).colorScheme.secondaryContainer': 'Color(0xFFEBDCFF)',
    'Theme.of(context).colorScheme.onSecondaryContainer': 'Color(0xFF260058)',
    'Theme.of(context).colorScheme.primary': 'Color(0xFF006A62)',
    'Theme.of(context).colorScheme.tertiary': 'Color(0xFF26A69A)',
    'Theme.of(context).colorScheme.secondary': 'Color(0xFF6F48B2)',
}

for file_name in files:
    path = os.path.join(dir_path, file_name)
    if not os.path.exists(path):
        continue
        
    with open(path, 'r') as f:
        content = f.read()
        
    for k, v in replacements.items():
        content = content.replace(k, v)
        
    with open(path, 'w') as f:
        f.write(content)

print("Reverted colors!")
