
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../providers/user_data_provider.dart';
import 'package:flutter/material.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<List<Map<String, String>>> _chatSessions = [];
  int _currentSessionIndex = -1;
  List<Map<String, String>> _messages = [];
  bool _isTyping = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _loadSessions();
    }
  }

  Future<void> _loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getString('chat_sessions');
    if (sessionsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(sessionsJson);
        _chatSessions = decoded.map((session) {
          return (session as List).map((msg) => Map<String, String>.from(msg)).toList();
        }).toList();
      } catch (e) {
        _chatSessions = [];
      }
    }
    
    // Always start a new session when entering the page
    _startNewSession();
  }

  Future<void> _saveSessions() async {
    final prefs = await SharedPreferences.getInstance();
    // Only save sessions that have at least one user interaction
    final validSessions = _chatSessions.where((session) => session.length > 1).toList();
    final sessionsJson = jsonEncode(validSessions);
    await prefs.setString('chat_sessions', sessionsJson);
  }

  void _startNewSession() {
    setState(() {
      final provider = Provider.of<UserDataProvider>(context, listen: false);
      final user = FirebaseAuth.instance.currentUser;
      final name = user?.displayName?.isNotEmpty == true ? user!.displayName! : 'there';
      final target = provider.targetCareer.isNotEmpty ? provider.targetCareer : 'your target tech role';
      
      _messages = [
        {
          'role': 'model',
          'text': "👋 Hi $name! I'm Lumina, your personal AI career assistant. I have reviewed your profile for **$target**. Ask me anything about your skill gaps, resume feedback, salary negotiation, or project roadmap!",
        }
      ];
      // Remove any existing empty sessions
      _chatSessions.removeWhere((session) => session.length <= 1);
      
      _chatSessions.insert(0, List.from(_messages));
      _currentSessionIndex = 0;
    });
    _saveSessions();
    _scrollToBottom();
  }

  void _loadSession(int index) {
    setState(() {
      _currentSessionIndex = index;
      _messages = List.from(_chatSessions[index]);
    });
    _scrollToBottom();
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _isTyping) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _chatSessions[_currentSessionIndex] = List.from(_messages);
      _isTyping = true;
    });
    _saveSessions();
    _msgController.clear();
    _scrollToBottom();

    try {
      final history = _messages.sublist(0, _messages.length - 1)
          .map((m) => {'role': m['role']!, 'text': m['text']!})
          .toList();

      final responseText = await ApiService().sendChat(text, history);
      
      setState(() {
        _messages.add({'role': 'model', 'text': responseText});
        _chatSessions[_currentSessionIndex] = List.from(_messages);
      });
      _saveSessions();
    } catch (e) {
      setState(() {
        _messages.add({'role': 'model', 'text': "Oops! Something went wrong: $e"});
        _chatSessions[_currentSessionIndex] = List.from(_messages);
      });
      _saveSessions();
    } finally {
      setState(() => _isTyping = false);
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.bg,
        appBar: AppBar(
          backgroundColor: AppTheme.cardBg.withValues(alpha: 0.85),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: Row(children: [
          Icon(Icons.auto_awesome, color: AppTheme.primary),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Career Assistant Chat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            Text('Powered by Gemini', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
          ]),
        ]),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: Icon(Icons.history, color: AppTheme.textSecondary),
              tooltip: 'Chat History',
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add, color: AppTheme.textSecondary),
            tooltip: 'New Session',
            onPressed: _startNewSession,
          ),
          const SizedBox(width: 8),
        ],
      ),
      endDrawer: Drawer(
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
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return _buildTypingIndicator();
                }
                final msg = _messages[index];
                return _buildMessage(msg['role']!, msg['text']!);
              },
            ),
          ),

          // Suggested prompts (shown only at start)
          if (_messages.length <= 1) ...[
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _suggestion('How do I negotiate salary?'),
                  _suggestion('What skills should I learn for AI?'),
                  _suggestion('How to prepare for FAANG interview?'),
                  _suggestion('Review my career gap'),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Input bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                    maxLines: 4,
                    minLines: 1,
                    onSubmitted: (_) => _sendMessage(),
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText: 'Ask Lumina anything about your career...',
                      hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      filled: true,
                      fillColor: AppTheme.subtle,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: _isTyping ? AppTheme.subtle : AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isTyping ? Icons.hourglass_empty : Icons.send_rounded,
                      color: _isTyping ? AppTheme.textSecondary : AppTheme.cardBg,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
     ),
    );
  }

  Widget _buildMessage(String role, String text) {
    final isUser = role == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: Icon(Icons.auto_awesome, color: AppTheme.primary, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.primary : AppTheme.cardBg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
              ),
              child: _buildMarkdownText(text, isUser),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.secondary.withValues(alpha: 0.2),
                child: Icon(Icons.person, color: AppTheme.secondary, size: 18),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.15), shape: BoxShape.circle),
        child: Icon(Icons.auto_awesome, color: AppTheme.primary, size: 16),
      ),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18), bottomRight: Radius.circular(18), bottomLeft: Radius.circular(4))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _dot(0), const SizedBox(width: 4), _dot(1), const SizedBox(width: 4), _dot(2),
        ]),
      ),
    ]);
  }

  Widget _dot(int index) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.3, end: 1.0),
    duration: Duration(milliseconds: 400 + (index * 150)),
    builder: (_, v, _) => Opacity(
      opacity: v,
      child: Container(width: 6, height: 6, decoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle)),
    ),
  );

  Widget _suggestion(String text) {
    return GestureDetector(
      onTap: () {
        _msgController.text = text;
        _sendMessage();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3))),
        child: Text(text, style: TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w500)),
      ),
    );
  }

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
}
