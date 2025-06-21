import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _credentialsKey = 'auth_credentials';

  Future<void> saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    String basicAuth = 'Basic ${base64Encode(utf8.encode('$email:$password'))}';
    await prefs.setString(_credentialsKey, basicAuth);
  }

  Future<String?> getCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_credentialsKey);
  }

  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_credentialsKey);
  }
}