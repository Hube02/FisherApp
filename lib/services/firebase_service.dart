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

  // Gettery
  FirebaseFirestore get db => _db;
  FirebaseAuth get auth => _auth;

  // ===== FISZKI =====

  // Pobierz wszystkie fiszki
  Stream<List<Map<String, dynamic>>> getFiszki() {
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
    await _db.collection('fiszki').add({
      'pl': pl,
      'en': en,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Usuń fiszkę
  Future<void> usunFiszke(String id) async {
    await _db.collection('fiszki').doc(id).delete();
  }

  // ===== STATYSTYKI =====

  // Zapisz wynik testu
  Future<void> zapiszWynikTestu(int poprawne, int wszystkie) async {
    await _db.collection('wyniki').add({
      'poprawne': poprawne,
      'wszystkie': wszystkie,
      'procent': (poprawne / wszystkie * 100).round(),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Pobierz statystyki
  Future<Map<String, dynamic>> getStatystyki() async {
    // Pobierz wszystkie wyniki testów
    final wyniki = await _db.collection('wyniki').get();

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
      final data = doc.data();
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