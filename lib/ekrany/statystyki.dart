// Plik: lib/ekrany/statystyki.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Statystyki extends StatefulWidget {
  @override
  _StatystykiState createState() => _StatystykiState();
}

class _StatystykiState extends State<Statystyki> {
  double _fontSize = 16;
  Color _bgColor = const Color(0xff84f1ff);

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = (prefs.getDouble('fontSize') ?? 16).clamp(12, 25);
      _bgColor = Color(prefs.getInt('bgColor') ?? 0xff84f1ff);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Statystyki"),
        backgroundColor: _bgColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_bgColor, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Text(
            "Tu będą statystyki użytkownika!",
            style: TextStyle(
              fontSize: _fontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
