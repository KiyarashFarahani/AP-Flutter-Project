import 'package:flutter/material.dart';
import 'package:mono/login.dart';
import 'package:mono/theme.dart';
import 'package:mono/util.dart';
import 'package:mono/services/socket_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SocketManager().connect();
  runApp(const MyApp());
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
