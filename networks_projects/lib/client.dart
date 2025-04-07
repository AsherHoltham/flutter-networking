import "dart:io";
import 'package:flutter/material.dart';
import "package:flutter_bloc/flutter_bloc.dart";
import 'dart:convert';

class Player {
  Socket? mServer;
  Player(this.mServer);
}

class PlayerController extends Cubit<Player> {
  PlayerController() : super(Player(null));

  void SendMessage(String message) {}
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PlayerController(),
      child: BlocBuilder<PlayerController, Player>(
        builder: (context, state) {
          // Use the provided 'state' directly here.
          return Scaffold(
            body: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey),
              ),
              constraints: const BoxConstraints(
                maxHeight: 200, // Limits the height; adjust as needed.
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  "Player 1",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ); // Replace with your widget tree that uses 'state'
        },
      ),
    );
  }
}
