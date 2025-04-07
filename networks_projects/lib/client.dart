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
    createServerConnection(9203);
  }

  void createServerConnection(int port) async {
    final socket = await Socket.connect('127.0.0.1', 9203);
    emit(Player(socket));
  }

  Map<int, String> getServerData() {
    return {};
  }

  void sendMessage(String message) {
    state.mServer?.write(message);
  }
}

void main() => runApp(
  BlocProvider(create: (context) => PlayerController(), child: MyApp()),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final playerController = context.read<PlayerController>();
    final TextEditingController textController = TextEditingController();

    playerController.init();
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
