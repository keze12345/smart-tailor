import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  Map<String, dynamic>? currentUser;

  void setUser(Map<String, dynamic> user) {
    currentUser = user;
    notifyListeners();
  }

  void clearUser() {
    currentUser = null;
    notifyListeners();
  }

  bool get isLoggedIn => currentUser != null;
  bool get isTailor => currentUser?['role'] == 'tailor';
  int get userId => currentUser?['id'] ?? 0;
}
