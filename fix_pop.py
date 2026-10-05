with open('lib/screens/assistant_screen.dart', 'r') as f:
    content = f.read()

target = """  void _loadSession(int index) {
    setState(() {
      _currentSessionIndex = index;
      _messages = List.from(_chatSessions[index]);
    });
    Navigator.pop(context); // close drawer
    _scrollToBottom();
  }"""

replacement = """  void _loadSession(int index) {
    setState(() {
      _currentSessionIndex = index;
      _messages = List.from(_chatSessions[index]);
    });
    _scrollToBottom();
  }"""

if target in content:
    content = content.replace(target, replacement)
    with open('lib/screens/assistant_screen.dart', 'w') as f:
        f.write(content)
    print("Fixed _loadSession")
else:
    print("Target not found in assistant_screen.dart")
