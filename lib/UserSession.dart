import 'package:flutter/material.dart';

class UserSession extends ChangeNotifier {
  String? _userId;
  String? _wifiName;

  // Getter to read the ID
  String? get userId => _userId;

  String? get wifiName => _wifiName;

  // Method to set the ID (e.g., after Login)
  void setUserId(String id) {
    _userId = id;
    notifyListeners(); // This tells every page to update its UI
  }

  void PickWifiName(String wifiName) {
    _wifiName = wifiName;
    // You can store the WiFi name if needed
    notifyListeners();
  }

  // Method to clear (e.g., Logout)
  void logout() {
    _userId = null;
    notifyListeners();
  }
}