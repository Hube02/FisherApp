import 'package:flutter/material.dart';
import 'package:fischer/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Glowny extends StatefulWidget {
  @override
  _GlownyState createState() => _GlownyState();
}

class _GlownyState extends State<Glowny> {
  final FirebaseService _firebaseService = FirebaseService();

  double _fontSize = 16;
  Color _bgColor = const Color(0xff84f1ff);
  Color _tileColor = Colors.cyan;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPreferences();
    });
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      double loadedFontSize = prefs.getDouble('fontSize') ?? 16;
      _fontSize = loadedFontSize.clamp(12, 25);
      _bgColor = Color(prefs.getInt('bgColor') ?? Color(0xff84f1ff).value);
      _tileColor = Color(prefs.getInt('tileColor') ?? Colors.cyan.value);
    });
  }

  Widget _buildGridButton(
      BuildContext context, String title, String subtitle, Color color,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: _fontSize, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: _fontSize - 3, fontStyle: FontStyle.italic),
              ),
            ],
          ),
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
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
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
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: Text('Anuluj'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final pl = plController.text.trim();
                          final en = enController.text.trim();
                          if (pl.isNotEmpty && en.isNotEmpty) {
                            setState(() => isLoading = true);
                            try {
                              await _firebaseService.dodajFiszke(pl, en);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Fiszka dodana pomyślnie!')));
                              Navigator.pop(context);
                            } catch (e) {
                              setState(() => isLoading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Błąd: $e')));
                            }
                          }
                        },
                  child: isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text('Dodaj'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showFiszkiCountDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    int availableCount = await _firebaseService.getFiszkiCount();

    showDialog(
      context: context,
      builder: (context) {
        String errorMessage = '';
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Wybierz liczbę fiszek'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Dostępnych fiszek: $availableCount'),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Liczba fiszek'),
                  ),
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(errorMessage,
                          style: TextStyle(color: Colors.red)),
                    ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Anuluj')),
                ElevatedButton(
                  onPressed: () {
                    final entered = int.tryParse(controller.text);
                    if (entered == null || entered <= 0) {
                      setState(() => errorMessage = 'Wprowadź poprawną liczbę');
                    } else if (entered > availableCount) {
                      setState(() => errorMessage =
                          'Maksymalnie możesz wybrać $availableCount fiszek');
                    } else {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/nauka',
                          arguments: entered);
                    }
                  },
                  child: Text('Rozpocznij'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Wylogowanie'),
        content: Text('Czy na pewno chcesz się wylogować?'),
        actions: [
          TextButton(
            child: Text('Anuluj'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            child: Text('Wyloguj'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firebaseService.signOut();
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        Navigator.pushNamedAndRemoveUntil(
            context, '/powitalny', (route) => false);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd podczas wylogowywania: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isUserLoggedIn = _firebaseService.isUserLoggedIn;
    final String userEmail =
        isUserLoggedIn ? _firebaseService.currentUserEmail ?? 'użytkownik' : '';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [_bgColor, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    isUserLoggedIn
                        ? 'Witaj, $userEmail!'
                        : 'Witaj w panelu głównym!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Image.asset('images/logoFischer.jpg', height: 50),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 8.0), // 👈 obniża przycisk
                  child: TextButton.icon(
                    icon: Icon(Icons.exit_to_app),
                    label: Text(isUserLoggedIn ? 'Wyloguj' : 'Wróć'),
                    onPressed: () => _signOut(context),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.7,
                padding: EdgeInsets.all(10),
                children: [
                  _buildGridButton(context, "Nauka",
                      "Klikaj fiszki i ucz się języka!", _tileColor, onTap: () {
                    showFiszkiCountDialog(context);
                  }),
                  _buildGridButton(
                      context, "Test", "Sprawdź ile się nauczyłeś", Colors.lime,
                      onTap: () {
                    Navigator.pushNamed(context, '/test');
                  }),
                  _buildGridButton(
                      context,
                      "Dodaj fiszkę",
                      "Dodaj swoją fiszkę i korzystaj z niej",
                      Colors.redAccent, onTap: () {
                    showAddFlashcardDialog(context);
                  }),
                  _buildGridButton(
                      context,
                      "Zarządzaj fiszkami",
                      "Edytuj lub usuń swoje fiszki",
                      Colors.deepPurpleAccent, onTap: () {
                    Navigator.pushNamed(context, '/zarzadzaj');
                  }),
                  _buildGridButton(context, "Statystyki",
                      "Zobacz jak robisz postępy", Colors.yellow, onTap: () {
                    Navigator.pushNamed(context, '/statystyki');

                    // przyszłe statystyki
                  }),
                  _buildGridButton(
                      context,
                      "Personalizacja",
                      "Ustaw kolory i wygląd",
                      Colors.tealAccent, onTap: () async {
                    await Navigator.pushNamed(context, '/personalizacja');
                    await _loadPreferences();
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
