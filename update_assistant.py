import re

with open('lib/screens/assistant_screen.dart', 'r') as f:
    content = f.read()

target = "child: Text(text, style: TextStyle(fontSize: 14, color: isUser ? AppTheme.cardBg : AppTheme.textPrimary, height: 1.5)),"
replacement = "child: _buildMarkdownText(text, isUser),"

if target in content:
    content = content.replace(target, replacement)
    
    # Add _buildMarkdownText method at the end of the class
    class_end = content.rfind('}')
    method = """
  Widget _buildMarkdownText(String text, bool isUser) {
    final defaultStyle = TextStyle(fontSize: 14, color: isUser ? AppTheme.cardBg : AppTheme.textPrimary, height: 1.5);
    final boldStyle = defaultStyle.copyWith(fontWeight: FontWeight.bold);
    
    final spans = <TextSpan>[];
    final parts = text.split('**');
    
    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 1) {
        spans.add(TextSpan(text: parts[i], style: boldStyle));
      } else {
        spans.add(TextSpan(text: parts[i], style: defaultStyle));
      }
    }
    
    return RichText(text: TextSpan(children: spans));
  }
"""
    content = content[:class_end] + method + "}\n"
    
    with open('lib/screens/assistant_screen.dart', 'w') as f:
        f.write(content)
    print("Updated assistant_screen.dart")
else:
    print("Target not found in assistant_screen.dart")
