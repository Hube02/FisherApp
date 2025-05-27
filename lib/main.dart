import 'package:fischer/ekrany/login.dart';
import 'package:fischer/ekrany/statystyki.dart';
import 'package:fischer/ekrany/personalizacja.dart';
import 'package:fischer/ekrany/nauka.dart';
import 'package:flutter/material.dart';
import 'package:fischer/ekrany/glowny.dart';
import 'package:fischer/ekrany/powitalny.dart';
import 'package:fischer/ekrany/test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fischer/services/firebase_service.dart';
import 'package:fischer/ekrany/zarzadzaj_fiszkami.dart';

void main() async {
  // Inicjalizacja Flutter i Firebase
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print('Firebase zainicjalizowany pomyślnie');

    // Initialize auth state
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
        '/zarzadzaj': (context) => ZarzadzajFiszkami(),
        '/personalizacja': (context) => Personalizacja(),
        '/statystyki': (context) => Statystyki(),

// DODANE
      },
    );
  }
}
