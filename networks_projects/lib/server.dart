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
    mIndex++;
  }
}

class ServerNode {
  HttpServer? mServer;
  SharedData mData;
  final String mOutputMessage;

  ServerNode(this.mServer, this.mData, this.mOutputMessage);
}

class ServerController extends Cubit<ServerNode> {
  ServerController()
    : super(ServerNode(null, SharedData(), "Server initializing...")) {
    connect();
  }

  Future<void> connect() async {
    // Bind the HTTP server to any IPv4 address on the specified port.
    HttpServer server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    emit(
      ServerNode(
        server,
        state.mData,
        "Server started on port $port. Ready to receive messages.",
      ),
    );

    // Listen for HTTP requests.
    server.listen((HttpRequest request) async {
      if (request.method == 'POST') {
        try {
          // Read and decode the incoming JSON payload.
          final content = await utf8.decoder.bind(request).join();
          Map<String, dynamic> data = jsonDecode(content);
          String message = data['message'] ?? "";
          String user = data['user'] ?? "Unknown";

          // Log the chat message.
          state.mData.chat(message, user);
          String logEntry = "$user: $message";
          emit(ServerNode(server, state.mData, "Received: $logEntry"));

          // Respond to the client.
          request.response
            ..statusCode = HttpStatus.ok
            ..write("Message received: $logEntry");
          await request.response.close();
        } catch (e) {
          request.response
            ..statusCode = HttpStatus.badRequest
            ..write("Invalid request: $e");
          await request.response.close();
        }
      } else if (request.method == 'GET') {
        // Return the current chat log as JSON.
        request.response.headers.contentType = ContentType.json;
        Map<String, dynamic> chatMap = {};
        state.mData.mChatLog.forEach((key, chatLog) {
          chatMap[key.toString()] = {
            'user': chatLog.mUser,
            'message': chatLog.mMessage,
          };
        });
        request.response.write(jsonEncode(chatMap));
        await request.response.close();
      } else {
        request.response
          ..statusCode = HttpStatus.methodNotAllowed
          ..write("Unsupported method");
        await request.response.close();
      }
    });
  }
}

void main() => runApp(
  BlocProvider(create: (context) => ServerController(), child: const MyApp()),
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
  Widget build(BuildContext context) {
    return BlocBuilder<ServerController, ServerNode>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(widget.title)),
          body: Center(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey),
              ),
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: SelectableText(
                  state.mOutputMessage,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
