with open('lib/screens/assistant_screen.dart', 'r') as f:
    content = f.read()

target1 = """  Future<void> _saveSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = jsonEncode(_chatSessions);
    await prefs.setString('chat_sessions', sessionsJson);
  }"""

replacement1 = """  Future<void> _saveSessions() async {
    final prefs = await SharedPreferences.getInstance();
    // Only save sessions that have at least one user interaction
    final validSessions = _chatSessions.where((session) => session.length > 1).toList();
    final sessionsJson = jsonEncode(validSessions);
    await prefs.setString('chat_sessions', sessionsJson);
  }"""

target2 = """      _chatSessions.insert(0, List.from(_messages));
      _currentSessionIndex = 0;
    });
    _saveSessions();
    _scrollToBottom();
  }"""

replacement2 = """      // Remove any existing empty sessions
      _chatSessions.removeWhere((session) => session.length <= 1);
      
      _chatSessions.insert(0, List.from(_messages));
      _currentSessionIndex = 0;
    });
    _saveSessions();
    _scrollToBottom();
  }"""

if target1 in content and target2 in content:
    content = content.replace(target1, replacement1)
    content = content.replace(target2, replacement2)
    with open('lib/screens/assistant_screen.dart', 'w') as f:
        f.write(content)
    print("Updated session logic")
else:
    print("Targets not found!")
