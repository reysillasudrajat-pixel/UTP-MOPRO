import 'package:flutter/material.dart';

import 'screens/app_shell.dart';
import 'theme.dart';

void main() => runApp(const MakanYukApp());

class MakanYukApp extends StatelessWidget {
  const MakanYukApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Makan Yuk',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const AppShell(),
    );
  }
}
