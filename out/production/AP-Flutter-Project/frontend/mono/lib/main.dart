import 'package:flutter/material.dart';
import 'package:mono/login.dart';
import 'package:mono/socket_client.dart';
import 'package:mono/theme.dart';
import 'package:mono/util.dart';

void main() async {
  final client = SocketClient();
  await client.connect();
  client.sendTestMessage();

  // Keep app alive for a few seconds to receive response
  await Future.delayed(Duration(seconds: 3));
  exit(0);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;
    TextTheme textTheme = createTextTheme(context, "Roboto", "Space Mono");

    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp(
      title: 'Mono',
      theme: brightness == Brightness.light ? theme.light() : theme.dark(),
      home: const Login(),
    );
  }
}
