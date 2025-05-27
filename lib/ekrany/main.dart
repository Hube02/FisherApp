import 'package:fischer/ekrany/login.dart';
import 'package:fischer/ekrany/nauka.dart';
import 'package:flutter/material.dart';
import 'package:fischer/ekrany/glowny.dart';
import 'package:fischer/ekrany/powitalny.dart';
import 'package:fischer/ekrany/test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fischer/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print('Firebase zainicjalizowany pomyślnie');

    await FirebaseService().initAuthState();
  } catch (e) {
    print('Błąd inicjalizacji Firebase: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fischer App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFCCF5FC),
      ),
      initialRoute: '/powitalny',
      routes: {
        '/powitalny': (context) => Powitalny(),
        '/login': (context) => Login(),
        '/glowny': (context) => Glowny(),
        '/nauka': (context) => Nauka(),
        '/test': (context) => Test(),
      },
    );
  }
}