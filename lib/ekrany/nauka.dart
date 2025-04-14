import 'package:flutter/material.dart';
import 'dart:math';

class Nauka extends StatefulWidget {
  @override
  _NaukaState createState() => _NaukaState();
}

class _NaukaState extends State<Nauka> with SingleTickerProviderStateMixin {
  bool isFlipped = false;
  int currentIndex = 0;

  final List<Map<String, String>> fiszki = [
    {'pl': 'Kot', 'en': 'Cat'},
    {'pl': 'Pies', 'en': 'Dog'},
    {'pl': 'Dom', 'en': 'House'},
  ];

  late AnimationController _controller;
  late Animation<double> _animation;

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
    setState(() {
      currentIndex = (currentIndex + 1) % fiszki.length;
      isFlipped = false;
      _controller.reset();
    });
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

    final String tekstPl = fiszki[currentIndex]['pl']!;
    final String tekstEn = fiszki[currentIndex]['en']!;

    return Scaffold(
      backgroundColor: const Color(0xFFCCF5FC),
      body: Stack(
        children: [
          // Strzałka "wstecz"
          Positioned(
            top: 30,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.arrow_back, size: 30),
              onPressed: () {
                Navigator.pop(context); // lub dowolna logika powrotu
              },
            ),
          ),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nagłówek
                Padding(
                  padding: const EdgeInsets.only(top: 40.0, bottom: 50),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Sprawdź swoją wiedzę!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Image.asset(
                        'images/logoFischer.jpg',
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),

                // Fiszka
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(isUnder ? pi : 0),
                          child: Text(
                            displayText,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // Przycisk "Sprawdź"
                ElevatedButton(
                  onPressed: flipCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF80DEEA),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Sprawdź',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Przycisk "Dalej"
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
                  child: const Text(
                    'Dalej',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
