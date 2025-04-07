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
  Map<int, ChatLog> mChatLog = {};
  int mIndex = 0;
  void chat(String message, String user) {
    mChatLog[mIndex] = ChatLog(message, user);
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
      9203,
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
    void processRequest(HttpRequest request) {}
    void sendData() {}
    void updateData() {}
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

void main() => runApp(
  BlocProvider(create: (context) => ServerController(), child: MyApp()),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
  void initState() {
    super.initState();
    // Start the server when the widget is initialized.
    context.read<ServerController>().connect();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServerController(),
      child: BlocBuilder<ServerController, ServerNode>(
        builder: (context, state) {
          // Use the provided 'state' directly here.
          return Scaffold(
            body: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
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
                      state.mOutputMessage,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ); // Replace with your widget tree that uses 'state'
        },
      ),
    );
  }
}
