def fix_dashboard():
    with open('lib/screens/dashboard_screen.dart', 'r') as f:
        content = f.read()
    content = content.replace(
        "Flexible(child: Text(text, style: TextStyle(fontSize: 11, overflow: TextOverflow.ellipsis), overflow: TextOverflow.ellipsis)), color: has ? AppTheme.textPrimary : AppTheme.textPrimary)),",
        "Flexible(child: Text(text, style: TextStyle(fontSize: 11, color: has ? AppTheme.textPrimary : AppTheme.textPrimary), overflow: TextOverflow.ellipsis)),"
    )
    with open('lib/screens/dashboard_screen.dart', 'w') as f:
        f.write(content)

def fix_roadmap():
    with open('lib/screens/roadmap_screen.dart', 'r') as f:
        content = f.read()
    content = content.replace(
        "Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),",
        "Flexible(child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textPrimary), overflow: TextOverflow.ellipsis)),"
    )
    with open('lib/screens/roadmap_screen.dart', 'w') as f:
        f.write(content)

fix_dashboard()
fix_roadmap()
print("Fixed!")
