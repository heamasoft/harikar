// providers/user_provider.dart

import 'package:flutter/material.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  void setUser(String userName, String phoneNumber) {
    _user = User(userName: userName, phoneNumber: phoneNumber);
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
