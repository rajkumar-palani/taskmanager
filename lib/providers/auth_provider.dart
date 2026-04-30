import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/back4app_service.dart';

class AuthProvider extends ChangeNotifier {
  final Back4AppService _service = Back4AppService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? sessionToken;
  String? userId;
  String? username;
  bool get isAuthenticated => sessionToken != null;

  static const _kSessionTokenKey = 'BACK4APP_SESSION_TOKEN';
  static const _kUserIdKey = 'BACK4APP_USER_ID';

  Future<void> register(String email, String password) async {
    final res = await _service.signUp(email, password);
    // signUp returns objectId on success
    userId = res['objectId'];
    // After signup, login to obtain session token
    final login = await _service.login(email, password);
    sessionToken = login['sessionToken'];
    username = email;
    // persist token and user id
    await _storage.write(key: _kSessionTokenKey, value: sessionToken);
    if (userId != null) await _storage.write(key: _kUserIdKey, value: userId);
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final res = await _service.login(email, password);
    sessionToken = res['sessionToken'];
    userId = res['objectId'];
    username = email;
    await _storage.write(key: _kSessionTokenKey, value: sessionToken);
    if (userId != null) await _storage.write(key: _kUserIdKey, value: userId);
    notifyListeners();
  }

  Future<void> logout() async {
    sessionToken = null;
    userId = null;
    username = null;
    await _storage.delete(key: _kSessionTokenKey);
    await _storage.delete(key: _kUserIdKey);
    notifyListeners();
  }

  Future<void> changePassword(String newPassword) async {
    if (sessionToken == null || userId == null) throw Exception('Not authenticated');
    await _service.changePassword(sessionToken!, userId!, newPassword);
  }

  /// Load any persisted session token/userId from secure storage. Call at startup.
  Future<void> init() async {
    final token = await _storage.read(key: _kSessionTokenKey);
    final uid = await _storage.read(key: _kUserIdKey);
    if (token != null) {
      sessionToken = token;
      userId = uid;
      // optionally fetch username or user info if needed
      notifyListeners();
    }
  }
}

