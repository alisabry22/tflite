import 'package:flutter/material.dart';
import 'package:tflite/models/responses.dart';

import '../models/chat_message.dart';
import '../models/tagaddod_bot_model.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ChatbotModel _botModel = ChatbotModel();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeBot();
  }

  Future<void> _initializeBot() async {
    setState(() => _isLoading = true);
    setState(() => _isLoading = false);
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    _controller.clear();
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });

    try {
      debugPrint("text is $text");
     
       String modelTag = await _botModel.predict(text);
       debugPrint("tag is : $modelTag");
       //get response from tag
       String modelResponse = BotResponse.getResponse(modelTag);

      setState(() {
        _messages.add(ChatMessage(text: modelResponse, isUser: false));
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Sorry, I encountered an error. Please try again.',
          isUser: false,
        ));
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tagaddod Chat Bot'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return _buildMessage(message);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.green[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Text(
          message.text,
          style: const TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
              ),
              onSubmitted: _handleSubmitted,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: Colors.green,
            onPressed: () => _handleSubmitted(_controller.text),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
  
    super.dispose();
  }
}

 List<double> _preprocessText(String text) {
    // Convert text to numerical representation (Dummy example)
    List<double> vector = List.filled(7, 0);
    for (int i = 0; i < text.length && i < 7; i++) {
      vector[i] = text.codeUnitAt(i).toDouble();
    }
    return vector;
  }

String _postprocessOutput(List<double> output) {
    // Convert model output to readable text (Dummy example)
    return output.map((val) => val.toStringAsFixed(2)).join(", ");
  }
