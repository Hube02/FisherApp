import 'package:flutter/material.dart';
import 'dart:math';
import 'package:fischer/services/firebase_service.dart';

class Test extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> with SingleTickerProviderStateMixin {
  bool isFlipped = false;
  int currentIndex = 0;
  String userAnswer = '';
  final List<Icon> resultsIcons = [];
  int correct = 0;
  int incorrect = 0;
  bool isLoading = true;
  String errorMessage = '';

  List<Map<String, dynamic>> fiszki = [];
  final FirebaseService _firebaseService = FirebaseService();

  late AnimationController _controller;
  late Animation<double> _animation;
  final TextEditingController _textController = TextEditingController();

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

    _loadFiszki();
  }

  // Funkcja do ładowania fiszek z Firebase
  void _loadFiszki() {
    _firebaseService.getFiszki().listen((data) {
      if (mounted) {
        setState(() {
          fiszki = data;
          isLoading = false;
          errorMessage = '';

          // Jeśli nie ma fiszek, ustaw domyślne
          if (fiszki.isEmpty) {
            fiszki = [
              {'pl': 'Kot', 'en': 'Cat', 'id': '1'},
              {'pl': 'Pies', 'en': 'Dog', 'id': '2'},
              {'pl': 'Dom', 'en': 'House', 'id': '3'},
            ];
          }
        });
      }
    }, onError: (error) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Błąd ładowania fiszek: $error';
          // Ustaw domyślne fiszki w przypadku błędu
          fiszki = [
            {'pl': 'Kot', 'en': 'Cat', 'id': '1'},
            {'pl': 'Pies', 'en': 'Dog', 'id': '2'},
            {'pl': 'Dom', 'en': 'House', 'id': '3'},
          ];
        });
      }
    });
  }

  void flipAndCheck() {
    if (fiszki.isEmpty) return;

    String correctAnswer = fiszki[currentIndex]['en']!.toLowerCase().trim();
    String user = userAnswer.toLowerCase().trim();

    if (!isFlipped) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    setState(() {
      isFlipped = !isFlipped;

      if (user == correctAnswer) {
        resultsIcons
            .add(Icon(Icons.check_circle, color: Colors.green, size: 30));
        correct++;
      } else {
        resultsIcons.add(Icon(Icons.cancel, color: Colors.red, size: 30));
        incorrect++;
      }
    });
  }

  void nextCard() {
    if (fiszki.isEmpty) return;

    if (currentIndex + 1 >= fiszki.length) {
      // Koniec testu
      _saveTestResults();
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Test zakończony!"),
          content: Text(
              "Poprawne odpowiedzi: $correct\nBłędne odpowiedzi: $incorrect"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // powrót do menu
              },
              child: Text("Zakończ"),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        currentIndex++;
        isFlipped = false;
        _controller.reset();
        _textController.clear();
        userAnswer = '';
      });
    }
  }

  // Zapisz wyniki testu
  Future<void> _saveTestResults() async {
    try {
      await _firebaseService.zapiszWynikTestu(correct, correct + incorrect);
    } catch (e) {
      print('Błąd zapisywania wyników: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double cardWidth = screenWidth > 1100 ? 900 : screenWidth * 0.8;
    final double cardHeight = screenHeight > 600 ? 400 : screenHeight * 0.5;

    // Pokaż ładowanie jeśli dane są pobierane
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFCCF5FC),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Ładowanie fiszek...'),
            ],
          ),
        ),
      );
    }

    // Pokaż komunikat o błędzie jeśli wystąpił
    if (errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFCCF5FC),
        body: Center(
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
      );
    }

    if (fiszki.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFCCF5FC),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 48, color: Colors.blue),
              SizedBox(height: 16),
              Text('Brak fiszek do nauki. Dodaj najpierw fiszki!'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Wróć do menu'),
              ),
            ],
          ),
        ),
      );
    }

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
                Navigator.pop(context);
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
                        'Czas na naukę!',
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

                // Fiszka + kontener na historię wyników
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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

                    const SizedBox(width: 20),

                    // Historia wyników
                    Container(
                      width: 60,
                      height: cardHeight,
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: resultsIcons,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Pole tekstowe + przycisk "Sprawdź"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pole tekstowe
                      Flexible(
                        child: Container(
                          width: 300,
                          child: TextField(
                            controller: _textController,
                            onChanged: (value) => userAnswer = value,
                            decoration: InputDecoration(
                              hintText: 'Wpisz tłumaczenie...',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Przycisk "Sprawdź"
                      ElevatedButton(
                        onPressed: flipAndCheck,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF80DEEA),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 16),
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
                    ],
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