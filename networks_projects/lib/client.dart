import "dart:io";
import 'package:flutter/material.dart';
import "package:flutter_bloc/flutter_bloc.dart";
import 'dart:convert';

const port = int.fromEnvironment('APP_PORT', defaultValue: 9203);

class Player {
  Socket? mServer;
  Player(this.mServer);
}

class PlayerController extends Cubit<Player> {
  PlayerController() : super(Player(null));

  void init() {
    createServerConnection(port);
  }

  void createServerConnection(port) async {
    final socket = await Socket.connect('localhost', port);
    await Future.delayed(const Duration(seconds: 2));
    emit(Player(socket));
  }

  void getServerData() {}
  void sendMessage(String message) {
    state.mServer?.write(message);
  }
}

void main() =>
    BlocProvider(create: (context) => PlayerController(), child: MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final playerController = context.read<PlayerController>();
    final TextEditingController textController = TextEditingController();

    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: textController,
                  autofocus: true,
                  decoration: const InputDecoration(filled: true),
                ),
              ),
              FloatingActionButton(
                onPressed: () {
                  playerController.sendMessage(textController.text);
                },
                child: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
