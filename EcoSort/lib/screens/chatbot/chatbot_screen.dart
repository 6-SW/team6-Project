import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatbotScreen extends StatefulWidget {
  final String region;
  const ChatbotScreen({required this.region, super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  bool _showQuickButtons = true;

  final List<Map<String, String>> _quickButtons = [
    {'label': '📄 종이', 'query': '종이 분리배출 방법을 알려줘'},
    {'label': '♻️ 플라스틱', 'query': '플라스틱 분리배출 방법을 알려줘'},
    {'label': '🥫 캔', 'query': '캔 분리배출 방법을 알려줘'},
  ];

  @override
  void initState() {
    super.initState();
    _messages.add({
      'role': 'bot',
      'content': '분리배출 방법을 알려드리는 AI챗봇 입니다.\n정보가 필요하신 내용이 있으신가요?',
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isLoading = true;
      _showQuickButtons = false;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse('https://team6-project.onrender.com/chat'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': text}),
      );

      final jsonData = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        _isLoading = false;
        _messages.add({'role': 'bot', 'content': jsonData['answer']});
        _messages.add({'role': 'bot', 'content': '더 필요하신 정보가 있으신가요?'});
        _showQuickButtons = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.add({'role': 'bot', 'content': '오류가 발생했습니다. 다시 시도해주세요.'});
        _showQuickButtons = true;
      });
    }
    _scrollToBottom();
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

  Widget _buildMessage(Map<String, String> msg) {
    final isUser = msg['role'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? Colors.orange : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Text(
          msg['content']!,
          style: TextStyle(
            fontSize: 14,
            color: isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  // 입력중... 말풍선
  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: _TypingDots(),
      ),
    );
  }

  // 빠른 선택 버튼 (메시지 하단)
  Widget _buildQuickButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8,
          runSpacing: 6,
          children: _quickButtons.map((btn) {
            return ElevatedButton(
              onPressed: () => _sendMessage(btn['query']!),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade50,
                foregroundColor: Colors.orange.shade800,
                side: BorderSide(color: Colors.orange.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                elevation: 0,
              ),
              child: Text(btn['label']!, style: const TextStyle(fontSize: 13)),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 챗봇'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              // 메시지 + 로딩 + 버튼을 아이템으로 계산
              itemCount: _messages.length +
                  (_isLoading ? 1 : 0) +
                  (_showQuickButtons && !_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                // 메시지 영역
                if (index < _messages.length) {
                  return _buildMessage(_messages[index]);
                }
                // 로딩 말풍선
                if (_isLoading && index == _messages.length) {
                  return _buildTypingIndicator();
                }
                // 빠른 선택 버튼
                return _buildQuickButtons();
              },
            ),
          ),
          // 입력창
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: '질문을 입력하세요...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (text) => _sendMessage(text),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _sendMessage(_controller.text),
                  icon: const Icon(Icons.send, color: Colors.orange),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.orange.shade50,
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// 점 3개 애니메이션 위젯
class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _dotCount = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(() {
        setState(() {
          _dotCount = (_controller.value * 3).floor() + 1;
        });
      })
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '.' * _dotCount,
      style: const TextStyle(
        fontSize: 20,
        color: Colors.grey,
        letterSpacing: 4,
      ),
    );
  }
}