import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatBox extends StatefulWidget {
  const ChatBox({super.key});
  @override
  ChatBoxState createState() => ChatBoxState();
}

class ChatBoxState extends State<ChatBox> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';
  List<Map<String, dynamic>> messages = []; // List to hold messages
  bool _isTextboxHovering = false;
  
  void _sendMessage() async {
    final String userInput = _controller.text;
    if (userInput.isNotEmpty) {
      // Mock response for demonstration purposes
      // Replace with actual HTTP request in production
      setState(() {
        messages.add({
          'text': userInput,
          'isUser': true,
        });
        _response = "Echo: $userInput";
        _controller.clear(); // Clear the input field after sending the message
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder regularBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: Colors.white, width: 1.5),
    );

    OutlineInputBorder hoveredBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: Colors.white, width: 2.5),
    );

    OutlineInputBorder focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: Color.fromRGBO(0,83,155,1), width: 2.5),
    );

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(160, 1, 33, 105), //Chatbox background color
        borderRadius: BorderRadius.circular(15), // Rounded corners for the whole chatbox
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(-2, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
                  flex: 10,
                  child: ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      // Align user messages to the right and responses to the left
                      return Align(
                        alignment: message['isUser'] ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          // For controlling the text bubble dimensions
                          padding: const EdgeInsets.all(8.0), 
                          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: message['isUser'] ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10.5),
                          ),
                          child: Text(
                            message['text'],
                            style: TextStyle(
                              color: message['isUser'] ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0, right: 5.0, left: 5.0),
            child: MouseRegion(
              onEnter: (_) => setState(() => _isTextboxHovering = true),
              onExit: (_) => setState(() => _isTextboxHovering = false),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                onSubmitted: (_) => _sendMessage(), // Calls _sendMessge when enter key is pressed
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20.0),
                  hintText: 'Enter a prompt',
                  hintStyle: const TextStyle(color: Color.fromARGB(150, 228, 228, 228)),
                  filled: true,
                  fillColor: const Color.fromARGB(160, 1, 33, 105),
                  enabledBorder: _isTextboxHovering ? hoveredBorder : regularBorder,
                  border: _isTextboxHovering ? hoveredBorder : regularBorder,
                  focusedBorder: focusedBorder,
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


