import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const PaulGrahamChat());
}

class PaulGrahamChat extends StatelessWidget {
  const PaulGrahamChat({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paul Graham Agent',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  Future<void> _sendMessage(String prompt) async {
    print("Gönder'e basıldı.");
    setState(() {
      _messages.add({"role": "user", "text": prompt});
    });

    try {
      final uri = Uri.parse("http:localhost/generate");
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"prompt": prompt}),
      );
      print("Status code: ");
      print(response.statusCode);
      print("response.body: ");
      print(response.body);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final reply = decoded['response'];

        setState(() {
          _messages.add({"role": "assistant", "text": reply});
        });
      } else {
        setState(() {
          _messages.add({
            "role": "assistant",
            "text": "Hata oluştu:  [31m${response.statusCode} [0m",
          });
        });
      }
    } catch (e) {
      print("Hata oluştu: $e");
      setState(() {
        _messages.add({
          "role": "assistant",
          "text": "Bağlantı veya işleme hatası: $e",
        });
      });
    }

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paul Graham Chat")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.deepPurple[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(message['text'] ?? ""),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Prompt gir...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _sendMessage(_controller.text),
                  child: const Text("Gönder"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
