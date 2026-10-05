import re

with open('lib/screens/assistant_screen.dart', 'r') as f:
    content = f.read()

target = """      endDrawer: Drawer(
        backgroundColor: AppTheme.bg,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20).copyWith(top: 60),
              color: AppTheme.cardBg,
              width: double.infinity,
              child: Text(
                'Chat History',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
            ),
            Expanded(
              child: _chatSessions.isEmpty
                  ? Center(child: Text("No past sessions", style: TextStyle(color: AppTheme.textSecondary)))
                  : ListView.builder(
                      itemCount: _chatSessions.length,
                      itemBuilder: (context, index) {
                        final session = _chatSessions[index];
                        // Find the first user message for the title
                        final firstUserMsg = session.firstWhere((m) => m['role'] == 'user', orElse: () => {'text': 'New Session'});
                        String title = firstUserMsg['text']!;
                        if (title.length > 30) title = title.substring(0, 30) + '...';
                        
                        return ListTile(
                          leading: Icon(Icons.chat_bubble_outline, color: _currentSessionIndex == index ? AppTheme.primary : AppTheme.textSecondary),
                          title: Text(title, style: TextStyle(color: AppTheme.textPrimary, fontWeight: _currentSessionIndex == index ? FontWeight.bold : FontWeight.normal)),
                          onTap: () => _loadSession(index),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),"""

replacement = """      endDrawer: Drawer(
        backgroundColor: AppTheme.bg,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(left: Radius.circular(32)),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.history, color: AppTheme.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Chat History',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              ),
              Divider(color: AppTheme.subtle, height: 1),
              const SizedBox(height: 8),
              Expanded(
                child: _chatSessions.isEmpty
                    ? Center(child: Text("No past sessions", style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _chatSessions.length,
                        itemBuilder: (context, index) {
                          final session = _chatSessions[index];
                          final firstUserMsg = session.firstWhere((m) => m['role'] == 'user', orElse: () => {'text': 'New Session'});
                          String title = firstUserMsg['text'] ?? 'New Session';
                          if (title.trim().isEmpty) title = 'New Session';
                          
                          final isSelected = _currentSessionIndex == index;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: InkWell(
                              onTap: () {
                                _loadSession(index);
                                Navigator.pop(context);
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppTheme.primary.withValues(alpha: 0.1) : AppTheme.cardBg,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? AppTheme.primary.withValues(alpha: 0.3) : Colors.transparent,
                                    width: 1,
                                  ),
                                  boxShadow: isSelected ? [] : [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected ? Icons.chat_bubble : Icons.chat_bubble_outline,
                                      color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: TextStyle(
                                          color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(Icons.chevron_right, size: 16, color: AppTheme.primary),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),"""

if target in content:
    content = content.replace(target, replacement)
    with open('lib/screens/assistant_screen.dart', 'w') as f:
        f.write(content)
    print("Updated drawer")
else:
    print("Target not found!")
