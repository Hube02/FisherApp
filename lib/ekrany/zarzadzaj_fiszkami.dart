// Plik: lib/ekrany/zarzadzaj_fiszkami.dart

import 'package:flutter/material.dart';
import 'package:fischer/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ZarzadzajFiszkami extends StatefulWidget {
  @override
  _ZarzadzajFiszkamiState createState() => _ZarzadzajFiszkamiState();
}

class _ZarzadzajFiszkamiState extends State<ZarzadzajFiszkami> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> fiszki = [];
  bool isLoading = true;

  double _fontSize = 16;
  Color _bgColor = const Color(0xff84f1ff);
  Color _cardColor = Colors.white;
  Color _cardTextColor = Colors.black;

  @override
  void initState() {
    super.initState();
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

  Future<void> _loadFiszki() async {
    final data = await _firebaseService.getFiszkiOnce();
    setState(() {
      fiszki = data;
      isLoading = false;
    });
  }

  void _showEditDialog(Map<String, dynamic> fiszka) {
    final TextEditingController plController =
        TextEditingController(text: fiszka['pl']);
    final TextEditingController enController =
        TextEditingController(text: fiszka['en']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edytuj fiszkę'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: plController,
              decoration: InputDecoration(labelText: 'PL'),
            ),
            TextField(
              controller: enController,
              decoration: InputDecoration(labelText: 'EN'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Anuluj')),
          ElevatedButton(
            onPressed: () async {
              await _firebaseService.edytujFiszke(
                  fiszka['id'], plController.text, enController.text);
              Navigator.pop(context);
              _loadFiszki();
            },
            child: Text('Zapisz'),
          )
        ],
      ),
    );
  }

  void _usunFiszke(String id) async {
    await _firebaseService.usunFiszke(id);
    _loadFiszki();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Zarządzaj fiszkami')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_bgColor, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: fiszki.length,
                itemBuilder: (context, index) {
                  final fiszka = fiszki[index];
                  return Card(
                    color: _cardColor,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(fiszka['pl'],
                          style: TextStyle(
                              fontSize: _fontSize, color: _cardTextColor)),
                      subtitle: Text(fiszka['en'],
                          style: TextStyle(
                              fontSize: _fontSize - 2,
                              color: _cardTextColor.withOpacity(0.7))),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditDialog(fiszka),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _usunFiszke(fiszka['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
