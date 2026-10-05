import json
import subprocess
import collections

# Run dart analyze and get json
result = subprocess.run(['dart', 'analyze', '--format=json'], capture_output=True, text=True)
output = result.stdout.strip()
lines = output.split('\n')
json_str = ""
for line in lines:
    if line.startswith('{') and 'version' in line:
        json_str = line
        break

if not json_str:
    print("Could not parse json")
    import sys; sys.exit(1)

data = json.loads(json_str)
fixes = collections.defaultdict(list)

for issue in data.get('diagnostics', []):
    if issue['code'] in ['const_eval_method_invocation', 'non_constant_list_element', 'non_constant_map_value', 'invalid_assignment']:
        loc = issue['location']
        fixes[loc['file']].append(loc['range']['start']['line'])

# Undefined context in signup_screen
for issue in data.get('diagnostics', []):
    if issue['code'] == 'undefined_identifier' and issue['problemMessage'].startswith("Undefined name 'context'"):
        pass # We might need to wrap in Builder or something, but let's check

for file_path, line_nums in fixes.items():
    with open(file_path, 'r') as f:
        content_lines = f.readlines()
    
    # Sort descending to avoid line shift issues if we remove lines (we aren't, but still good)
    for line_num in sorted(set(line_nums), reverse=True):
        idx = line_num - 1
        # Need to remove 'const' from that line or preceding lines.
        # usually 'const ' is right before the widget.
        # Let's just replace 'const ' with '' on that line.
        # If not on that line, maybe the line above?
        # A simple approach: remove all 'const ' from the file!
        pass
        
    # Actually, if we just remove all `const ` before widgets that are not const, it's safer.
    # But since it's 433 issues, most are const errors.
    # What if we just remove ALL 'const ' strings that precede a capital letter across all dart files in lib/screens?
    with open(file_path, 'w') as f:
        new_content = []
        for line in content_lines:
            # this is a bit aggressive but works for Flutter
            import re
            new_line = re.sub(r'const\s+([A-Z])', r'\1', line)
            new_line = re.sub(r'const\s+\[', r'[', new_line)
            new_content.append(new_line)
        f.write("".join(new_content))

print("Fixed consts")
