import 'package:flutter/material.dart';
import 'package:mono/theme.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text('Account', style: textTheme.titleLarge)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(),
      ),
    );
  }
}
