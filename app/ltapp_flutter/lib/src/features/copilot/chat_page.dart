import 'package:flutter/material.dart';
import 'package:ltapp_flutter/src/core/theme/theme.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key})

  @override
  State<ChatPage> createState() {
    return _ChatPageState();
  }
}


class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OmniFlow Copilot', style: AppTextStyle.feltTipSeniorRegular(fontSize: 30, color: Color(0xFF000000)))), 
      body: Column(children: [],));
  }
}