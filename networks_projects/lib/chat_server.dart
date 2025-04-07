import "dart:io";
import 'package:flutter/material.dart';
import "package:flutter_bloc/flutter_bloc.dart";
import 'dart:convert';

const port = int.fromEnvironment('APP_PORT', defaultValue: 9203);

class ChatData {
  String mMessage;
  String mUser;
  ChatData(this.mMessage, this.mUser);
}

class SharedData {
  SharedData();
  List<ChatData> mChatLog = [];
  void chat(String message, String user) {
    mChatLog.add(ChatData(message, user));
  }
}

class ServerNode {
  Socket? mFirstPlayer;
  Socket? mSecondPlayer;
  final SharedData mData;
  final String mOutputMessage;

  ServerNode(
    this.mFirstPlayer,
    this.mSecondPlayer,
    this.mData,
    this.mOutputMessage,
  );
}

class ServerController extends Cubit<ServerNode> {
  ServerController()
    : super(
        ServerNode(null, null, SharedData(), "Waiting on Players to connect!"),
      );

  Future<void> connect() async {
    ServerSocket? server = await ServerSocket.bind(
      InternetAddress.anyIPv4,
      port,
    );

    emit(
      ServerNode(
        null,
        null,
        state.mData,
        "Server started, waiting for players...",
      ),
    );

    server.listen((client) {
      if (state.mFirstPlayer == null) {
        emit(
          ServerNode(
            client,
            state.mSecondPlayer,
            state.mData,
            "First Player Connected, Awaiting second player...",
          ),
        );
        _listenToClient(client, "Player 1");
      } else if (state.mSecondPlayer == null) {
        emit(
          ServerNode(
            state.mFirstPlayer,
            client,
            state.mData,
            "Both Players Connected!",
          ),
        );
        _listenToClient(client, "Player 2");
      } else {
        client.write('Server full!\n');
        client.close();
      }
    });
  }

  void _listenToClient(Socket client, String playerID) {
    client.listen(
      (data) {
        final message = utf8.decode(data).trim();
        final logEntry = "$playerID: $message";

        final updatedLog = List<String>.from(state.chatLog)..add(logEntry);
        emit(
          ServerNode(
            state.mFirstPlayer,
            state.mSecondPlayer,
            "Message Received from $playerID",
            updatedLog,
          ),
        );

        // Broadcasting message to both players
        state.mFirstPlayer?.write("$logEntry\n");
        state.mSecondPlayer?.write("$logEntry\n");
      },
      onDone: () {
        emit(ServerNode(null, null, "$playerID disconnected.", state.chatLog));
      },
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Networking Labs',
      theme: ThemeData(),
      home: const NetworkingMasterNode(title: 'Chatter Lab'),
    );
  }
}

class NetworkingMasterNode extends StatefulWidget {
  const NetworkingMasterNode({super.key, required this.title});
  final String title;

  @override
  State<NetworkingMasterNode> createState() => _NetworkingMasterPage();
}

class _NetworkingMasterPage extends State<NetworkingMasterNode> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
