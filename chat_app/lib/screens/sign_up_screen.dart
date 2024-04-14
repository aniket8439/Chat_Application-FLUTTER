import 'package:flutter/material.dart';
import 'package:chat_app/services/api_service.dart';

import 'login_screen.dart'; // Import ApiService

class SignUpScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _signUp(BuildContext context) async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    final response = await ApiService().signUp(username, password);

    if (response['statusCode'] == 201) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Sign Up Failed'),
            content: Text('Error: ${response['body']['message']}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.blue,
                  Colors.red,
                ],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Create an Account',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.08,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  AnimatedOpacity(
                    opacity: 1,
                    duration: Duration(seconds: 1),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              prefixIcon: Icon(Icons.person),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              prefixIcon: Icon(Icons.lock),
                            ),
                            obscureText: true,
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                          ElevatedButton(
                            onPressed: () {
                              _signUp(context);
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.deepPurple),
                            ),
                            child: Text('Sign Up', style: TextStyle(color: Colors.white)),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Already have an account? Log In',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
