import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../services/theme_service.dart';
import '../widgets/home_button.dart';

/// Anemia Q&A chat assistant powered by Claude (via the backend /api/chat).
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage('assistant',
        'Salaan! Waxaan ahay caawiyaha caafimaad. Waxaad i weydiin kartaa wax kasta oo ku saabsan yaraanta dhiigga (anemia).\n\nHi! Ask me anything about anemia.'));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() {
      _messages.add(ChatMessage('user', text));
      _sending = true;
      _controller.clear();
    });
    _scrollToBottom();

    // Send only user/assistant turns (skip nothing — the greeting is fine).
    final reply = await ChatService.send(_messages);
    if (!mounted) return;
    setState(() {
      _messages.add(ChatMessage('assistant', reply.text));
      _sending = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF7B1FA2);
    return Scaffold(
      backgroundColor: context.bgPage,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: context.bgCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: context.borderSubtle),
                          ),
                          child: Icon(Icons.arrow_back_ios_new,
                              color: context.textPrimary, size: 18),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const HomeButton(),
                      const SizedBox(width: 12),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.smart_toy_outlined,
                            color: accent, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Caawiye AI',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: context.textPrimary,
                                )),
                            Text('Anemia assistant',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: context.textMuted,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Messages
                Expanded(
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    itemCount: _messages.length + (_sending ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (_sending && i == _messages.length) {
                        return _bubble(
                          context,
                          ChatMessage('assistant', '...'),
                          accent,
                          typing: true,
                        );
                      }
                      return _bubble(context, _messages[i], accent);
                    },
                  ),
                ),

                // Input
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          style: TextStyle(color: context.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Qor su\'aashaada...',
                            hintStyle: TextStyle(color: context.textMuted),
                            filled: true,
                            fillColor: context.inputBg,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _send,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.send_rounded,
                              color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bubble(BuildContext context, ChatMessage m, Color accent,
      {bool typing = false}) {
    final isUser = m.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? accent : context.bgCard,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser ? null : Border.all(color: context.borderSubtle),
        ),
        child: typing
            ? const SizedBox(
                width: 36,
                child: Text('• • •',
                    style: TextStyle(color: Color(0xFF9E9E9E))),
              )
            : Text(
                m.text,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: isUser ? Colors.white : context.textPrimary,
                ),
              ),
      ),
    );
  }
}
