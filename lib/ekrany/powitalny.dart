import 'package:flutter/material.dart';

class Powitalny extends StatefulWidget {
  @override
  State<Powitalny> createState() => _PowitalnyState();
}

class _PowitalnyState extends State<Powitalny> {
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController registerLoginController = TextEditingController();
  final TextEditingController registerPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 1200;

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Expanded(
                      child: isMobile
                          ? Column(
                              children: [
                                _leftSide(),
                                _rightSide(),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(flex: 4, child: _leftSide()),
                                Expanded(flex: 1, child: _rightSide()),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _leftSide() {
    return Container(
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xff84f1ff), Colors.white],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tytuł aplikacji
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Fischer',
                style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 20),
              Image.asset('images/logoFischer.jpg', height: 80),
            ],
          ),
          SizedBox(height: 40),

          // Górna sekcja
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            spacing: 80,
            runSpacing: 40,
            children: [
              _infoBlock(),
              SizedBox(
                width: 150,
              ),
              Image.asset('images/logoFischer.jpg',
                  height: 200, fit: BoxFit.contain),
            ],
          ),
          SizedBox(height: 40),

          // Dolna sekcja
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 80,
            runSpacing: 40,
            children: [
              Image.asset('images/logoFischer.jpg',
                  height: 200, fit: BoxFit.contain),
              SizedBox(
                width: 150,
              ),
              _infoBlock(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('📚 Co oferuje aplikacja?', style: TextStyle(fontSize: 30)),
        SizedBox(height: 18),
        Text('• Setki fiszek z angielskimi słówkami i zwrotami'),
        Text('• Setki fiszek z angielskimi słówkami i zwrotami'),
        Text('• Setki fiszek z angielskimi słówkami i zwrotami'),
        Text('• Setki fiszek z angielskimi słówkami i zwrotami'),
      ],
    );
  }

  Widget _rightSide() {
    return Container(
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xFF5FB9D2), Color(0xFF9EF0FF)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Zaloguj się i zacznij naukę!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          TextField(
            controller: loginController,
            decoration: InputDecoration(
              hintText: 'Login',
              filled: true,
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Hasło',
              filled: true,
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/glowny'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF80DEEA),
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Zaloguj',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
          ),
          SizedBox(height: 30),
          Text('lub', style: TextStyle(fontSize: 16)),
          SizedBox(height: 20),
          Text(
            'Dołącz do nas i zarejestruj się!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          TextField(
            controller: registerLoginController,
            decoration: InputDecoration(
              hintText: 'Login',
              filled: true,
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: registerPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Hasło',
              filled: true,
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Color(0xFF80DEEA), width: 2),
              ),
            ),
            child: Text('Zarejestruj',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
