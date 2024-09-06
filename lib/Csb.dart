import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatBot extends StatefulWidget {
  const ChatBot({super.key});

  @override
  State<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  TextEditingController _queryController = TextEditingController();
  String _response = '';
  bool _isLoading = false;

  Future<void> sendQuery(String query) async {
    setState(() {
      _isLoading = true;
      _response = '';
    });

    final url = Uri.parse('http://192.168.61.1:8080/ask_psdf');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': query}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _response = data['page_content'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _response = 'Failed to get response from the server';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatBotInv',style: TextStyle(color:Colors.white),),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey[900]!, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Response section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _response.isNotEmpty
                    ? SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[800],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      _response,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                )
                    : Center(
                  child: Text(
                    'No response yet...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),

            // Input section at the bottom
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueGrey[800],
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _queryController,
                        decoration: InputDecoration(
                          hintText: 'Ask a question...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16.0),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        if (_queryController.text.isNotEmpty) {
                          sendQuery(_queryController.text);
                          _queryController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}