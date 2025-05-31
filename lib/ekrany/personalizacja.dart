// Plik: lib/ekrany/personalizacja.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Personalizacja extends StatefulWidget {
  @override
  _PersonalizacjaState createState() => _PersonalizacjaState();
}

class _PersonalizacjaState extends State<Personalizacja> {
  double _fontSize = 16;
  Color _bgColor = Colors.lightBlue.shade50;
  Color _cardColor = Colors.white;
  Color _cardTextColor = Colors.black;

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
      _cardColor = Color(prefs.getInt('cardColor') ?? Colors.white.value);
      _cardTextColor =
          Color(prefs.getInt('cardTextColor') ?? Colors.black.value);
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', _fontSize);
    await prefs.setInt('bgColor', _bgColor.value);
    await prefs.setInt('cardColor', _cardColor.value);
    await prefs.setInt('cardTextColor', _cardTextColor.value);
  }

  Future<void> _resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', 16);
    await prefs.setInt('bgColor', 0xff84f1ff);
    await prefs.setInt('cardColor', Colors.white.value);
    await prefs.setInt('cardTextColor', Colors.black.value);
    _loadPrefs();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Przywrócono domyślne ustawienia!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_bgColor, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                title: Text('Personalizacja'),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      Text('Rozmiar tekstu: ${_fontSize.toInt()}'),
                      Slider(
                        min: 12,
                        max: 25,
                        value: _fontSize,
                        onChanged: (val) => setState(() => _fontSize = val),
                      ),
                      SizedBox(height: 20),
                      _buildColorPicker('Kolor tła aplikacji', _bgColor,
                          (color) => _bgColor = color),
                      _buildColorPicker('Kolor fiszki', _cardColor,
                          (color) => _cardColor = color),
                      _buildColorPicker('Kolor tekstu fiszki', _cardTextColor,
                          (color) => _cardTextColor = color),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () async {
                          await _savePrefs();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ustawienia zapisane!')),
                          );
                        },
                        child: Text('Zapisz zmiany'),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _resetToDefaults,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300),
                        child: Text('Przywróć domyślne'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorPicker(
      String title, Color currentColor, Function(Color) onColorPicked) {
    final List<Color> gentleColors = [
      Color(0xFF4FC3F7), // Light Blue
      Color(0xFFF06292), // Pink
      Color(0xFF81C784), // Green
      Color(0xFFFFD54F), // Amber
      Color(0xFF9575CD), // Deep Purple
      Color(0xFF4DB6AC), // Teal
      Color(0xFFFFA726), // Orange
      Color(0xFF7986CB), // Indigo
      Color(0xFF4DD0E1), // Cyan
      Color(0xFFDCE775), // Lime
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: gentleColors.map((color) {
            return GestureDetector(
              onTap: () => setState(() => onColorPicked(color)),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(
                    color: currentColor == color
                        ? Colors.black
                        : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
