import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/back4app_service.dart';

class AuthProvider extends ChangeNotifier {
  final Back4AppService _service = Back4AppService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? sessionToken;
  String? userId;
  String? username;
  String? email;
  bool get isAuthenticated => sessionToken != null;

  static const _kSessionTokenKey = 'BACK4APP_SESSION_TOKEN';
  static const _kUserIdKey = 'BACK4APP_USER_ID';

  Future<void> register(String name, String email, String password) async {
    final res = await _service.signUp(email, password, name: name);
    // signUp returns objectId on success
    userId = res['objectId'];
    // After signup, login to obtain session token
    final login = await _service.login(email, password);
    sessionToken = login['sessionToken'];
    // store email and display name when available
    this.email = email;
    username = (login['name'] ?? login['username'] ?? name ?? email) as String?;
    // If backend didn't return name/email on login, try fetching the user object
    try {
      if ((username == null || username!.isEmpty) && sessionToken != null && userId != null) {
        final user = await _service.getUser(sessionToken!, userId!);
        username = (user['name'] ?? user['username'] ?? username) as String?;
        this.email = (user['email'] ?? this.email) as String?;
      }
    } catch (_) {}
    // persist token and user id
    await _storage.write(key: _kSessionTokenKey, value: sessionToken);
    if (userId != null) await _storage.write(key: _kUserIdKey, value: userId);
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final res = await _service.login(email, password);
    sessionToken = res['sessionToken'];
    userId = res['objectId'];
    // Use provided fields if available
    this.email = (res['email'] ?? email) as String?;
    username = (res['name'] ?? res['username'] ?? email) as String?;
    // Attempt to fetch user details if name/email not present
    try {
      if ((username == null || username!.isEmpty || this.email == null || this.email!.isEmpty) && sessionToken != null && userId != null) {
        final user = await _service.getUser(sessionToken!, userId!);
        username = (user['name'] ?? user['username'] ?? username) as String?;
        this.email = (user['email'] ?? this.email) as String?;
      }
    } catch (_) {}
    await _storage.write(key: _kSessionTokenKey, value: sessionToken);
    if (userId != null) await _storage.write(key: _kUserIdKey, value: userId);
    notifyListeners();
  }

  Future<void> logout() async {
    sessionToken = null;
    userId = null;
    username = null;
    email = null;
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

