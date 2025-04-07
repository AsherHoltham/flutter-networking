import "dart:io";
import 'package:flutter/material.dart';
import "package:flutter_bloc/flutter_bloc.dart";
import 'dart:convert';

const port = int.fromEnvironment('APP_PORT', defaultValue: 9203);

class ChatLog {
  String mMessage;
  String mUser;
  ChatLog(this.mMessage, this.mUser);
}

class SharedData {
  SharedData();
  List<ChatLog> mChatLog = [];
  void chat(String message, String user) {
    mChatLog.add(ChatLog(message, user));
  }
}

class ServerNode {
  Socket? mFirstPlayer;
  Socket? mSecondPlayer;
  SharedData mData;
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
        _listenToClient(client, "Player 1 Joined");
      } else if (state.mSecondPlayer == null) {
        emit(
          ServerNode(
            state.mFirstPlayer,
            client,
            state.mData,
            "Both Players Connected!",
          ),
        );
        _listenToClient(client, "Player 2 Joined");
      } else {
        client.write('Server full!\n');
        client.close();
      }
    });
  }

  void _listenToClient(Socket client, String playerID) {
    client.listen((data) {
      final String message = utf8.decode(data).trim();
      final String logEntry = "$playerID: $message";

      state.mData.chat(message, playerID);
      emit(
        ServerNode(
          state.mFirstPlayer,
          state.mSecondPlayer,
          state.mData,
          "Message Received from $playerID",
        ),
      );

      // Broadcasting message to both players
      state.mFirstPlayer?.write("$logEntry\n");
      state.mSecondPlayer?.write("$logEntry\n");
    });
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
      title: 'Server',
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
    return BlocProvider(
      create: (_) => ServerController(),
      child: BlocBuilder<ServerController, ServerNode>(
        builder: (context, state) {
          // Use the provided 'state' directly here.
          return Scaffold(
            body: Text(state.mOutputMessage),
          ); // Replace with your widget tree that uses 'state'
        },
      ),
    );
  }
}
