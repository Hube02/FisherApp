import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

class Powitalny extends StatefulWidget {
  @override
  _PowitalnyState createState() => _PowitalnyState();
}

class _PowitalnyState extends State<Powitalny> {
  bool _isFirebaseConnected = false;

  @override
  void initState() {
    super.initState();
    _checkFirebase();
  }

  // Sprawdź czy Firebase działa
  Future<void> _checkFirebase() async {
    try {
      setState(() {
        _isFirebaseConnected = Firebase.apps.isNotEmpty;
      });
    } catch (e) {
      print('Błąd sprawdzania Firebase: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ekran Powitalny'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Witaj w aplikacji Fischer!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Status Firebase
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _isFirebaseConnected ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isFirebaseConnected ? Icons.check_circle : Icons.error,
                    color: _isFirebaseConnected ? Colors.green : Colors.red,
                  ),
                  SizedBox(width: 10),
                  Text(_isFirebaseConnected
                      ? 'Firebase jest połączony!'
                      : 'Firebase nie jest połączony'),
                ],
              ),
            ),

            SizedBox(height: 40),

            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/glowny');
              },
              child: Text('Przejdź dalej'),
            ),
          ],
        ),
      ),
    );
  }
}