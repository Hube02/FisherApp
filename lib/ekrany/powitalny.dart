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
      backgroundColor: const Color(0xFFCCF5FC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/logoFischer.jpg',
              height: 120,
            ),
            SizedBox(height: 30),
            Text(
              'Witaj w aplikacji Fischer!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Twoja aplikacja do nauki języków z fiszkami',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 40),

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

            SizedBox(height: 60),

            SizedBox(
              width: 250,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF80DEEA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Zaloguj się / Zarejestruj',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 250,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/glowny');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Color(0xFF80DEEA), width: 2),
                  ),
                ),
                child: Text(
                  'Kontynuuj bez logowania',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}