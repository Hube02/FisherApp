// Plik: lib/ekrany/nauka.dart

import 'package:flutter/material.dart';
import 'dart:math';
import 'package:fischer/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Nauka extends StatefulWidget {
  @override
  _NaukaState createState() => _NaukaState();
}

class _NaukaState extends State<Nauka> with SingleTickerProviderStateMixin {
  bool isFlipped = false;
  int currentIndex = 0;
  bool isLoading = true;
  String errorMessage = '';

  List<Map<String, dynamic>> fiszki = [];
  final FirebaseService _firebaseService = FirebaseService();

  late AnimationController _controller;
  late Animation<double> _animation;

  int liczbaDoNauki = 0;

  double _fontSize = 16;
  Color _bgColor = const Color(0xff84f1ff);
  Color _cardColor = Colors.white;
  Color _cardTextColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _loadPrefs();
  }

  void _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = (prefs.getDouble('fontSize') ?? 16).clamp(12, 25);
      _bgColor = Color(prefs.getInt('bgColor') ?? 0xff84f1ff);
      _cardColor = Color(prefs.getInt('cardColor') ?? Colors.white.value);
      _cardTextColor =
          Color(prefs.getInt('cardTextColor') ?? Colors.black.value);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    liczbaDoNauki = args is int ? args : 0;
    _loadFiszki();
  }

  void _loadFiszki() async {
    try {
      final allFiszki = await _firebaseService.getFiszkiOnce();
      if (allFiszki.isEmpty) {
        setState(() {
          fiszki = [
            {'pl': 'Kot', 'en': 'Cat', 'id': '1'},
            {'pl': 'Pies', 'en': 'Dog', 'id': '2'},
            {'pl': 'Dom', 'en': 'House', 'id': '3'},
          ];
          isLoading = false;
        });
        return;
      }

      final shuffled = [...allFiszki]..shuffle();
      final wybrane = shuffled.take(liczbaDoNauki).toList();

      setState(() {
        fiszki = wybrane;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Błąd ładowania fiszek: $e';
      });
    }
  }

  void flipCard() {
    if (!isFlipped) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      isFlipped = !isFlipped;
    });
  }

  void nextCard() {
    if (currentIndex + 1 >= fiszki.length) {
      Navigator.pop(context);
    } else {
      setState(() {
        currentIndex++;
        isFlipped = false;
        _controller.reset();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double cardWidth = screenWidth > 1100 ? 1000 : screenWidth * 0.9;
    final double cardHeight = screenHeight > 600 ? 400 : screenHeight * 0.5;

    if (isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_bgColor, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Ładowanie fiszek...'),
              ],
            ),
          ),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_bgColor, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: 16),
                Text(errorMessage),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                      errorMessage = '';
                    });
                    _loadFiszki();
                  },
                  child: Text('Spróbuj ponownie'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final tekstPl = fiszki[currentIndex]['pl'] ?? 'Brak tekstu';
    final tekstEn = fiszki[currentIndex]['en'] ?? 'Brak tłumaczenia';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_bgColor, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 30,
              left: 20,
              child: IconButton(
                icon: Icon(Icons.arrow_back, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0, bottom: 30),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Sprawdź swoją wiedzę!',
                          style: TextStyle(
                              fontSize: _fontSize + 10,
                              fontWeight: FontWeight.w800,
                              fontStyle: FontStyle.italic),
                        ),
                        SizedBox(width: 12),
                        Image.asset('images/logoFischer.jpg',
                            width: 60, height: 60),
                      ],
                    ),
                  ),
                  Text('Fiszka ${currentIndex + 1} z ${fiszki.length}',
                      style: TextStyle(
                          fontSize: _fontSize, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      final angle = _animation.value * pi;
                      final isUnder = angle > pi / 2;
                      final displayText = isUnder ? tekstEn : tekstPl;

                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(angle),
                        child: Container(
                          width: cardWidth,
                          height: cardHeight,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(isUnder ? pi : 0),
                            child: Text(
                              displayText,
                              style: TextStyle(
                                fontSize: _fontSize + 8,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                color: _cardTextColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: flipCard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF80DEEA),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Sprawdź',
                        style: TextStyle(
                          fontSize: _fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        )),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: nextCard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Color(0xFF80DEEA), width: 2),
                      ),
                    ),
                    child: Text('Dalej',
                        style: TextStyle(
                          fontSize: _fontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
