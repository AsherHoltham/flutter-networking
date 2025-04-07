import "dart:io";
import 'package:flutter/material.dart';
import "package:flutter_bloc/flutter_bloc.dart";

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

class NodeData {
  final String mUserID;
  NodeData(this.mUserID);
  SharedData mData = SharedData();

  void chat(String message) {
    mData.chat(message, mUserID);
  }
}

class ServerNode {
  Socket? mFirstPlayer;
  Socket? mSecondPlayer;
  final String mOutputMessage;

  ServerNode(this.mFirstPlayer, this.mSecondPlayer, this.mOutputMessage);
}

class ServerController extends Cubit<ServerNode> {
  ServerController() : super(ServerNode(null, null));

  Future<void> connect() async {
    final server = await ServerSocket.bind(InternetAddress.anyIPv4, 9203);

    server.listen((client) {
      if (state.mFirstPlayer == null) {
        emit(ServerNode(client, state.mSecondPlayer));
        connect();
      } else if (state.mSecondPlayer == null) {
        emit(ServerNode(state.mFirstPlayer, client));
      }
    });
  }
}

class ClientNode extends StatelessWidget {
  const ClientNode({super.key});

  @override
  Widget build(BuildContext bc) {
    return Container();
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
  State<NetworkingMasterNode> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<NetworkingMasterNode> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
