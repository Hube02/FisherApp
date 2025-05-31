// Plik: lib/ekrany/statystyki.dart

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fischer/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Statystyki extends StatefulWidget {
  @override
  _StatystykiState createState() => _StatystykiState();
}

class _StatystykiState extends State<Statystyki> {
  final FirebaseService _firebaseService = FirebaseService();

  int _totalFiszki = 0;
  int _sredniaWynikow = 0;
  int _liczbaTestowDzienna = 0;
  int _poprawneDzienne = 0;
  int _niepoprawneDzienne = 0;
  int _totalTesty = 0;
  DateTime _todayDate = DateTime.now();
  bool _isLoading = true;

  double _fontSize = 16;
  Color _bgColor = const Color(0xff84f1ff);
  Color _cardColor = Colors.white;
  Color _cardTextColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _loadStats();
    _onDateChanged(_todayDate);
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

  Future<void> _loadDayStats(DateTime date) async {
    final statystykiZDnia = await _firebaseService.getStatystykiZDnia(date);
    setState(() {
      _niepoprawneDzienne = statystykiZDnia['niepoprawneDzienne'];
      _poprawneDzienne = statystykiZDnia['poprawneDzienne'];
      _liczbaTestowDzienna = statystykiZDnia['liczbaTestowDzienna'];
    });
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    final fiszki = await _firebaseService.getFiszkiOnce();
    final statystyki = await _firebaseService.getStatystyki();

    final total = fiszki.length;

    setState(() {
      _totalFiszki = total;
      _totalTesty = statystyki['liczbaTestow'];
      _sredniaWynikow = statystyki['sredniaWynikow'];
      _isLoading = false;
    });
  }

  Future<void> _refreshButton() async {
    _loadStats();
    _onDateChanged(_todayDate);
  }

  Timer? _debounce;

  _onDateChanged(DateTime date) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _loadDayStats(date);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statystyki nauki'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_bgColor, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Card(
                      color: _cardColor,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          'Liczba fiszek w bazie',
                          style: TextStyle(
                              fontSize: _fontSize, color: _cardTextColor),
                        ),
                        trailing: Text(
                          '$_totalFiszki',
                          style: TextStyle(
                              fontSize: _fontSize, color: _cardTextColor),
                        ),
                      ),
                    ),
                    Card(
                      color: _cardColor,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          'Liczba testów aktywowanych',
                          style: TextStyle(
                              fontSize: _fontSize, color: _cardTextColor),
                        ),
                        trailing: Text(
                          '$_totalTesty',
                          style: TextStyle(
                              fontSize: _fontSize, color: _cardTextColor),
                        ),
                      ),
                    ),
                    Card(
                      color: _cardColor,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          'Średnia wyników z testów',
                          style: TextStyle(
                              fontSize: _fontSize, color: _cardTextColor),
                        ),
                        trailing: Text(
                          '$_sredniaWynikow',
                          style: TextStyle(
                              fontSize: _fontSize, color: _cardTextColor),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Text(
                      "Wybierz dzień",
                      style: TextStyle(fontSize: 24, color: _cardTextColor),
                    ),
                    SizedBox(
                      height: 40,
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        use24hFormat: true,
                        dateOrder: DatePickerDateOrder.dmy,
                        initialDateTime: _todayDate,
                        onDateTimeChanged: (DateTime newDateTime) {
                          setState(() => _todayDate = newDateTime);
                          _onDateChanged(newDateTime);
                        },
                      ),
                    ),
                    Card(
                      color: _cardColor,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                          'Liczba testów aktywowanych',
                          style: TextStyle(
                              fontSize: _fontSize, color: _cardTextColor),
                        ),
                        trailing: Text(
                          '$_liczbaTestowDzienna',
                          style: TextStyle(
                              fontSize: _fontSize, color: _cardTextColor),
                        ),
                      ),
                    ),
                    Card(
                      color: _cardColor,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                          'Poprawne odpowiedzi',
                          style: TextStyle(
                              fontSize: _fontSize, color: _cardTextColor),
                        ),
                        trailing: Text(
                          '$_poprawneDzienne',
                          style: TextStyle(
                              fontSize: _fontSize, color: _cardTextColor),
                        ),
                      ),
                    ),
                    Card(
                      color: _cardColor,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                          'Niepoprawne odpowiedzi',
                          style: TextStyle(
                              fontSize: _fontSize, color: _cardTextColor),
                        ),
                        trailing: Text(
                          '$_niepoprawneDzienne',
                          style: TextStyle(
                              fontSize: _fontSize, color: _cardTextColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _refreshButton,
                      child: const Text('Odśwież statystyki'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
