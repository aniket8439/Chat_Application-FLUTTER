import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:web_socket_channel/io.dart';
import 'package:chat_app/screens/login_screen.dart';

class ChatScreen extends StatefulWidget {
  final String username;

  ChatScreen({required this.username});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final channel = IOWebSocketChannel.connect('ws://10.0.2.2:7777');
  final Box<String> _messageBox = Hive.box<String>('chat_messages');
  List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    channel.stream.listen((message) {
      setState(() {
        _messages.add(utf8.decode(message));
      });
    });
  }

  void _sendMessage(String message) {
    final username = widget.username;
    final messageWithUsername = '$username: $message';
    channel.sink.add(messageWithUsername);
    _messageBox.add(messageWithUsername);
  }

  void _logout(BuildContext context) {
    channel.sink.close();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  void _clearChat() {
    _messageBox.clear();
    setState(() {
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat Room 💬',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.green,
        actions: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => _logout(context),
                      child: Text('Logout', style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(height: 5),
                    TextButton(
                      onPressed: () => _clearChat(),
                      child: Text('Clear Chat', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                );
              } else {
                return Row(
                  children: [
                    TextButton(
                      onPressed: () => _logout(context),
                      child: Text('Logout', style: TextStyle(color: Colors.red,fontWeight: FontWeight.w900,)),
                    ),
                    TextButton(
                      onPressed: () => _clearChat(),
                      child: Text('Clear Chat', style: TextStyle(color: Colors.yellow,fontWeight: FontWeight.w900)),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),


      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green, Colors.indigo],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ValueListenableBuilder(
                    valueListenable: _messageBox.listenable(),
                    builder: (context, Box<String> box, _) {
                      return ListView.builder(
                        itemCount: box.length,
                        itemBuilder: (context, index) {
                          final message = box.getAt(index);
                          return WaterEffectMessage(message: message ?? '');
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.5),
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send,color: Colors.white,),
                    onPressed: () {
                      _sendMessage(_messageController.text);
                      _messageController.clear();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    channel.sink.close();
    super.dispose();
  }
}

class WaterEffectMessage extends StatelessWidget {
  final String message;

  WaterEffectMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          RippleAnimation(
            child: Container(
              padding: EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text(
                message,
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}





class RippleAnimation extends StatefulWidget {
  final Widget child;

  RippleAnimation({required this.child});

  @override
  _RippleAnimationState createState() => _RippleAnimationState();
}

class _RippleAnimationState extends State<RippleAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.blueAccent.withOpacity(0.5 - _animationController.value * 0.5),
              ),
              child: widget.child,
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
