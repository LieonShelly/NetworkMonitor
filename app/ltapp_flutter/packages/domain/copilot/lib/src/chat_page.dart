import 'package:flutter/material.dart';
import 'package:lt_network/network.dart';
import 'package:lt_uicomponent/uicomponent.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() {
    return _ChatPageState();
  }
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textEditingController = TextEditingController();

  Future<void> _handleSubmitted(String text) async {
    final String sessionId = "ios_expert_001";
    if (text.trim().isEmpty) return;
    _textEditingController.clear();
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _messages.add(ChatMessage(text: "思考中", isUser: false));
    });
    try {
      final apiClient = ref.read(chatApiClientProvider);
      final response = await apiClient.post(
        '/chat',
        data: {'session_id': sessionId, 'message': text},
      );
      setState(() {
        _messages.removeLast();
        _messages.add(ChatMessage(text: response["reply"], isUser: false));
      });
    } catch (e) {
      debugPrint('Chat API Error: $e');
      setState(() {
        _messages.removeLast();
        _messages.add(
          ChatMessage(text: "❌ 请求失败，请检查 Python 后端是否已启动: $e", isUser: false),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'OmniFlow Copilot',
          style: AppTextStyle.feltTipSeniorRegular(
            fontSize: 30,
            color: Color(0xFF000000),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _buildMessageBubble(message);
                  },
                ),
              ),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final aliggment = message.isUser
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final bubbleColor = message.isUser ? Colors.blueAccent : Colors.grey[200];
    final textColor = message.isUser ? Colors.white : Colors.black87;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: aliggment,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              message.text,
              style: TextStyle(color: textColor, fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textEditingController,
                maxLines: null,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.send,
                autocorrect: true,
                enableSuggestions: true,
                decoration: InputDecoration(
                  hintText: '输入你的指令',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                onSubmitted: _handleSubmitted,
              ),
            ),
            const SizedBox(width: 8.0),
            FloatingActionButton(
              onPressed: () => _handleSubmitted(_textEditingController.text),
              elevation: 0,
              child: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
