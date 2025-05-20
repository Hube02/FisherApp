import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  // Singleton
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Firebase instances
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // In-memory user state
  String? _currentUserId;
  String? _currentUserEmail;

  // Gettery
  FirebaseFirestore get db => _db;
  FirebaseAuth get auth => _auth;

  // Custom user data
  bool get isUserLoggedIn => _currentUserId != null;
  String? get currentUserId => _currentUserId;
  String? get currentUserEmail => _currentUserEmail;

  // ===== AUTENTYKACJA =====

  // Initialize auth state - without SharedPreferences
  Future<void> initAuthState() async {
    // We'll just initialize with null values
    _currentUserId = null;
    _currentUserEmail = null;
    print('Auth initialized: No user');
  }

  // Logowanie
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Try to find the user in Firestore
      final querySnapshot = await _db
          .collection('users')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: _hashPassword(password))
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Nieprawidłowy email lub hasło');
      }

      final userDoc = querySnapshot.docs.first;
      _currentUserId = userDoc.id;
      _currentUserEmail = email;

      return true;
    } catch (e) {
      print('Login error: $e');
      throw Exception('Błąd logowania: ${_simplifyError(e.toString())}');
    }
  }

  // Rejestracja
  Future<bool> registerWithEmailAndPassword(String email, String password) async {
    try {
      // Check if user already exists
      final querySnapshot = await _db
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        throw Exception('Email jest już używany przez inne konto');
      }

      // Create a new user document
      final userRef = await _db.collection('users').add({
        'email': email,
        'password': _hashPassword(password),
        'createdAt': FieldValue.serverTimestamp(),
      });

      _currentUserId = userRef.id;
      _currentUserEmail = email;

      return true;
    } catch (e) {
      print('Registration error: $e');
      throw Exception('Błąd rejestracji: ${_simplifyError(e.toString())}');
    }
  }

  // Simplified password hashing - Note: In a real app, use proper hashing
  String _hashPassword(String password) {
    // This is NOT secure, just for demonstration purposes
    // In a real app, use a proper hashing library
    return password;
  }

  // Helper to simplify error messages
  String _simplifyError(String errorMsg) {
    if (errorMsg.contains('user-not-found') || errorMsg.contains('Nieprawidłowy email lub hasło')) {
      return 'Nieprawidłowy email lub hasło';
    } else if (errorMsg.contains('wrong-password')) {
      return 'Nieprawidłowe hasło';
    } else if (errorMsg.contains('email-already-in-use') || errorMsg.contains('Email jest już używany')) {
      return 'Email jest już używany przez inne konto';
    } else if (errorMsg.contains('weak-password')) {
      return 'Hasło jest zbyt słabe';
    } else if (errorMsg.contains('invalid-email')) {
      return 'Nieprawidłowy format adresu email';
    } else {
      return errorMsg;
    }
  }

  // Wylogowanie
  Future<void> signOut() async {
    try {
      _currentUserId = null;
      _currentUserEmail = null;
    } catch (e) {
      throw Exception('Błąd wylogowania: ${e.toString()}');
    }
  }

  // ===== FISZKI =====

  // Pobierz wszystkie fiszki
  Stream<List<Map<String, dynamic>>> getFiszki() {
    // Jeśli użytkownik jest zalogowany, pobierz tylko jego fiszki
    if (_currentUserId != null) {
      return _db
          .collection('users')
          .doc(_currentUserId)
          .collection('fiszki')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    }

    // Jeśli użytkownik nie jest zalogowany, pobierz publiczne fiszki
    return _db.collection('fiszki').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Dodaj fiszkę
  Future<void> dodajFiszke(String pl, String en) async {
    // Jeśli użytkownik jest zalogowany, dodaj fiszkę do jego kolekcji
    if (_currentUserId != null) {
      await _db
          .collection('users')
          .doc(_currentUserId)
          .collection('fiszki')
          .add({
        'pl': pl,
        'en': en,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      // Jeśli użytkownik nie jest zalogowany, dodaj fiszkę do publicznej kolekcji
      await _db.collection('fiszki').add({
        'pl': pl,
        'en': en,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  // Usuń fiszkę
  Future<void> usunFiszke(String id) async {
    if (_currentUserId != null) {
      await _db
          .collection('users')
          .doc(_currentUserId)
          .collection('fiszki')
          .doc(id)
          .delete();
    } else {
      await _db.collection('fiszki').doc(id).delete();
    }
  }

  // ===== STATYSTYKI =====

  // Zapisz wynik testu
  Future<void> zapiszWynikTestu(int poprawne, int wszystkie) async {
    final data = {
      'poprawne': poprawne,
      'wszystkie': wszystkie,
      'procent': (poprawne / wszystkie * 100).round(),
      'timestamp': FieldValue.serverTimestamp(),
    };

    if (_currentUserId != null) {
      await _db
          .collection('users')
          .doc(_currentUserId)
          .collection('wyniki')
          .add(data);
    } else {
      await _db.collection('wyniki').add(data);
    }
  }

  // Pobierz statystyki
  Future<Map<String, dynamic>> getStatystyki() async {
    QuerySnapshot wyniki;

    if (_currentUserId != null) {
      wyniki = await _db
          .collection('users')
          .doc(_currentUserId)
          .collection('wyniki')
          .get();
    } else {
      wyniki = await _db.collection('wyniki').get();
    }

    if (wyniki.docs.isEmpty) {
      return {
        'liczbaTestow': 0,
        'sredniaWynikow': 0,
        'najlepszyWynik': 0,
      };
    }

    int liczbaTestow = wyniki.docs.length;
    int sumaWynikow = 0;
    int najlepszyWynik = 0;

    for (var doc in wyniki.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final procent = data['procent'] as int;
      sumaWynikow += procent;

      if (procent > najlepszyWynik) {
        najlepszyWynik = procent;
      }
    }

    return {
      'liczbaTestow': liczbaTestow,
      'sredniaWynikow': (sumaWynikow / liczbaTestow).round(),
      'najlepszyWynik': najlepszyWynik,
    };
  }
}