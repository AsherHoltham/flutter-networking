import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Player 1',
      home: Scaffold(
        appBar: AppBar(title: Text('Bare Bones App')),
        body: Center(child: Text('Hello, Flutter!')),
      ),
    );
  }
}
