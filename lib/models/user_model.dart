// // lib/models/user_model.dart

// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class UserModel with ChangeNotifier {
//   String _name = '';
//   String _phoneNumber = '';
//   String _role = '';
//   String _city = ''; // Add city property

//   String get name => _name;
//   String get phoneNumber => _phoneNumber;
//   String get role => _role;
//   String get city => _city; // Add getter for city

//   bool get isAdmin => _role.toLowerCase() == 'admin';

//   /// Sets the user data and saves it in `SharedPreferences`
//   void setUser(String name, String phoneNumber, String role,
//       {String? city}) async {
//     _name = name;
//     _phoneNumber = phoneNumber;
//     _role = role;
//     _city = city ?? ''; // Set city (default to empty string if null)
//     notifyListeners();

//     // Save user data to SharedPreferences
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('userName', _name);
//     await prefs.setString('phoneNumber', _phoneNumber);
//     await prefs.setString('role', _role);
//     await prefs.setString('city', _city); // Save city
//   }

//   /// Clears the user data and removes it from `SharedPreferences`
//   void clearUser() async {
//     _name = '';
//     _phoneNumber = '';
//     _role = '';
//     _city = ''; // Clear city
//     notifyListeners();

//     // Clear user data from SharedPreferences
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//   }

//   /// Loads the user data from `SharedPreferences` (if available)
//   Future<void> loadUserFromPreferences() async {
//     final prefs = await SharedPreferences.getInstance();
//     _name = prefs.getString('userName') ?? '';
//     _phoneNumber = prefs.getString('phoneNumber') ?? '';
//     _role = prefs.getString('role') ?? '';
//     _city = prefs.getString('city') ?? ''; // Load city
//     notifyListeners();
//   }
// }
