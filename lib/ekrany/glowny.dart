import 'package:fischer/ekrany/test.dart';
import 'package:flutter/material.dart';

class Glowny extends StatelessWidget {
  Widget _buildTile(String title, String subtitle, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(subtitle,
                style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  void showAddFlashcardDialog(BuildContext context) {
    final TextEditingController plController = TextEditingController();
    final TextEditingController enController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Dodaj nową fiszkę'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: plController,
                decoration: InputDecoration(
                  labelText: 'Tekst po polsku',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: enController,
                decoration: InputDecoration(
                  labelText: 'Tekst po angielsku',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // zamyka okno
              },
              child: Text('Anuluj'),
            ),
            ElevatedButton(
              onPressed: () {
                final pl = plController.text.trim();
                final en = enController.text.trim();
                if (pl.isNotEmpty && en.isNotEmpty) {
                  print('Dodano fiszkę: $pl → $en');
                  Navigator.pop(context);
                }
              },
              child: Text('Dodaj'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final screenWidth = constraints.maxWidth;

        // Wysokość nagłówka (tekst + obrazek + padding)
        final headerHeight = 180.0;

        // Dostępna wysokość na kafelki
        final gridHeight = screenHeight - headerHeight;

        // Ustalmy proporcje, żeby się ładnie zmieściło i nie było zbyt małe
        final tileWidth = (screenWidth - 80) / 2; // 80 = padding + spacing
        final tileHeight = (gridHeight - 40) / 2; // 40 = spacing

        return Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff84f1ff), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Witaj w panelu głównym!',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  Image.asset('images/logoFischer.jpg', height: 50),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/powitalny');
                    },
                    child: Text('Wyloguj'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                height: gridHeight,
                child: Center(
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: [
                      SizedBox(
                        width: tileWidth,
                        height: tileHeight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/nauka');
                          },
                          child: _buildTile(
                            "Nauka",
                            "Klikaj fiszki i ucz się języka!",
                            Colors.cyan,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: tileWidth,
                        height: tileHeight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/test');
                          },
                          child: _buildTile(
                            "Test",
                            "Sprawdź ile się nauczyłeś",
                            Colors.lime,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: tileWidth,
                        height: tileHeight,
                        child: TextButton(
                          onPressed: () {
                            showAddFlashcardDialog(context);
                          },
                          child: _buildTile(
                            "Dodaj fiszkę",
                            "Dodaj swoją fiszkę i korzystaj z niej",
                            Colors.redAccent,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: tileWidth,
                        height: tileHeight,
                        child: TextButton(
                          onPressed: () {},
                          child: _buildTile(
                            "Statystyki",
                            "Zobacz jak robisz postępy",
                            Colors.yellow,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}
