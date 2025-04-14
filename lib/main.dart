import 'package:fischer/ekrany/nauka.dart';
import 'package:flutter/material.dart';
import 'package:fischer/ekrany/glowny.dart';
import 'package:fischer/ekrany/powitalny.dart';
import 'package:fischer/ekrany/test.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/powitalny',
      routes: {
        '/powitalny': (context) => Powitalny(),
        '/glowny': (context) => Glowny(),
        '/nauka': (context) => Nauka(),
        '/test': (context) => Test(),
      },
    );
  }
}
