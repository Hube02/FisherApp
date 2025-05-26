// Plik: lib/ekrany/test.dart

import 'package:flutter/material.dart';
import 'dart:math';
import 'package:fischer/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Test extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> with SingleTickerProviderStateMixin {
  bool isFlipped = false;
  bool isChecked = false;
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

  Set<String> bledneFiszkiId = {};

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
    _loadFiszki();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = (prefs.getDouble('fontSize') ?? 16).clamp(12, 25);
      _bgColor = Color(prefs.getInt('bgColor') ?? 0xff84f1ff);
      _cardColor = Color(prefs.getInt('cardColor') ?? Colors.white.value);
      _cardTextColor =
          Color(prefs.getInt('cardTextColor') ?? Colors.black.value);
    });
  }

  void _loadFiszki() async {
    try {
      final wszystkieFiszki = await _firebaseService.getFiszkiOnce();
      final bledneIds = await _firebaseService.getBledneFiszki();

      List<Map<String, dynamic>> wybrane = [];
      final bledne =
          wszystkieFiszki.where((f) => bledneIds.contains(f['id'])).toList();
      wybrane.addAll(bledne);

      final losowe =
          wszystkieFiszki.where((f) => !bledneIds.contains(f['id'])).toList();
      losowe.shuffle();

      for (var f in losowe) {
        if (wybrane.length >= 15) break;
        wybrane.add(f);
      }

      setState(() {
        fiszki = wybrane.take(15).toList();
        isLoading = false;
        errorMessage = '';
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Błąd ładowania fiszek: $e';
      });
    }
  }

  void flipAndCheck() {
    if (isChecked || userAnswer.trim().isEmpty) return;

    final correctAnswer = fiszki[currentIndex]['en']!.toLowerCase().trim();
    final user = userAnswer.toLowerCase().trim();
    final isCorrect = _normalize(user) == _normalize(correctAnswer);

    setState(() {
      isFlipped = true;
      isChecked = true;

      if (isCorrect) {
        resultsIcons.add(Icon(Icons.check_circle, color: Colors.green));
        correct++;
        _firebaseService.usunBlednaFiszke(fiszki[currentIndex]['id']);
      } else {
        resultsIcons.add(Icon(Icons.cancel, color: Colors.red));
        incorrect++;
        bledneFiszkiId.add(fiszki[currentIndex]['id']);
        _firebaseService.zapiszBlednaFiszke(fiszki[currentIndex]['id']);
      }

      _controller.forward();
    });
  }

  void nextCard() {
    if (!isChecked) return;

    if (currentIndex + 1 >= fiszki.length) {
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
                Navigator.pushNamedAndRemoveUntil(
                    context, '/glowny', (route) => false);
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
        isChecked = false;
        _controller.reset();
        _textController.clear();
        userAnswer = '';
      });
    }
  }

  String _normalize(String input) {
    final replacements = {
      "i'm": "i am",
      "you're": "you are",
      "he's": "he is",
      "she's": "she is",
      "it's": "it is",
      "we're": "we are",
      "they're": "they are",
      "can't": "cannot",
      "won't": "will not",
      "don't": "do not",
      "doesn't": "does not",
      "didn't": "did not",
      "isn't": "is not",
      "aren't": "are not",
    };

    String cleaned = input
        .toLowerCase()
        .replaceAll(RegExp("[.,!?\"'`]"), '') // 👈 brak `r""`
        .trim();

    replacements.forEach((short, full) {
      cleaned = cleaned.replaceAll(short, full);
    });

    return cleaned;
  }

  Future<void> _saveTestResults() async {
    try {
      await _firebaseService.zapiszWynikTestu(correct, correct + incorrect);
    } catch (e) {
      print('Błąd zapisu wyniku: $e');
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
          child: Center(child: CircularProgressIndicator()),
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
          child: Center(child: Text(errorMessage)),
        ),
      );
    }

    final fiszka = fiszki[currentIndex];
    final tekstPl = fiszka['pl'];
    final tekstEn = fiszka['en'];

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
            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Text(
                    'Fiszka ${currentIndex + 1} z ${fiszki.length}',
                    style: TextStyle(
                        fontSize: _fontSize, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
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
                          margin: EdgeInsets.all(20),
                          padding: EdgeInsets.all(20),
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: _cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.rotationY(isUnder ? pi : 0),
                              child: Text(
                                displayText,
                                style: TextStyle(
                                  fontSize: _fontSize + 8,
                                  fontWeight: FontWeight.bold,
                                  color: _cardTextColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: resultsIcons,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextField(
                      controller: _textController,
                      onChanged: (val) => setState(() => userAnswer = val),
                      enabled: !isChecked,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: userAnswer.trim().isEmpty || isChecked
                            ? null
                            : flipAndCheck,
                        child: Text('Sprawdź',
                            style: TextStyle(fontSize: _fontSize)),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: isChecked ? nextCard : null,
                        child: Text('Dalej',
                            style: TextStyle(fontSize: _fontSize)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 40,
              left: 10,
              child: IconButton(
                icon: Icon(Icons.close, size: 28, color: Colors.black),
                tooltip: 'Przerwij test',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Przerwać test?'),
                      content: Text('Twoje odpowiedzi nie zostaną zapisane.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Anuluj'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/glowny', (route) => false);
                          },
                          child: Text('Tak, przerwij'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
