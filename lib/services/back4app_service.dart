import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/back4app_config.dart';
import '../models/task.dart';

class ParseApiException implements Exception {
  final int? code;
  final String message;
  final int status;
  ParseApiException(this.code, this.message, this.status);

  @override
  String toString() => 'ParseApiException($status${code != null ? ', code=$code' : ''}): $message';
}

class Back4AppService {
  Map<String, String> _makeHeaders({String? sessionToken}) {
    final headers = <String, String>{
      'X-Parse-Application-Id': Back4AppConfig.appId,
      'X-Parse-REST-API-Key': Back4AppConfig.restApiKey,
      'Content-Type': 'application/json',
    };
    if (sessionToken != null && sessionToken.isNotEmpty) {
      headers['X-Parse-Session-Token'] = sessionToken;
    }
    return headers;
  }

  // Users
  Future<Map<String, dynamic>> signUp(String email, String password) async {
    final url = Uri.parse('${Back4AppConfig.baseUrl}/users');
    final body = jsonEncode({'username': email, 'password': password, 'email': email});
    final resp = await http.post(url, headers: _makeHeaders(), body: body);
    if (resp.statusCode == 201) {
      return jsonDecode(resp.body);
    }
    _handleError(resp);
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('${Back4AppConfig.baseUrl}/login?username=${Uri.encodeComponent(username)}&password=${Uri.encodeComponent(password)}');
    final resp = await http.get(url, headers: _makeHeaders());
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    }
    _handleError(resp);
  }

  Future<void> changePassword(String sessionToken, String userId, String newPassword) async {
    final url = Uri.parse('${Back4AppConfig.baseUrl}/users/$userId');
    final resp = await http.put(url, headers: _makeHeaders(sessionToken: sessionToken), body: jsonEncode({'password': newPassword}));
    if (resp.statusCode == 200) return;
    _handleError(resp);
  }

  // Tasks (Parse class: Task)
  Future<Task> createTask(String sessionToken, Task task) async {
    final url = Uri.parse('${Back4AppConfig.baseUrl}/classes/Task');
    // Build object body and include an ACL so the task is private to the owner by default.
    final bodyMap = Map<String, dynamic>.from(task.toParse());
    if (task.ownerId != null) {
      bodyMap['ACL'] = {
        task.ownerId!: {'read': true, 'write': true}
      };
    }
    final resp = await http.post(url, headers: _makeHeaders(sessionToken: sessionToken), body: jsonEncode(bodyMap));
    if (resp.statusCode == 201) {
      final map = jsonDecode(resp.body) as Map<String, dynamic>;
      return Task(objectId: map['objectId'], title: task.title, description: task.description, status: task.status);
    }
    _handleError(resp);
  }

  /// Map a ParseApiException to a user-friendly message.
  static String mapParseErrorToMessage(ParseApiException e) {
    final code = e.code;
    switch (code) {
      case 101:
        return 'Invalid username or password.';
      case 202:
        return 'Username already taken.';
      case 203:
        return 'Email already in use.';
      case 125:
        return 'Invalid email address.';
      case 209:
        return 'Session token invalid. Please log in again.';
      default:
        if (e.message.isNotEmpty) return e.message;
        return 'An unexpected error occurred (status ${e.status}).';
    }
  }

  Future<List<Task>> getTasks(String sessionToken, {String? whereJson}) async {
    var urlStr = '${Back4AppConfig.baseUrl}/classes/Task';
    if (whereJson != null) urlStr += '?where=${Uri.encodeComponent(whereJson)}';
    final url = Uri.parse(urlStr);
    final resp = await http.get(url, headers: _makeHeaders(sessionToken: sessionToken));
    if (resp.statusCode == 200) {
      final map = jsonDecode(resp.body) as Map<String, dynamic>;
      final results = (map['results'] as List).cast<Map<String, dynamic>>();
      return results.map((m) => Task.fromParse(m)).toList();
    }
    _handleError(resp);
  }

  Future<void> updateTask(String sessionToken, Task task) async {
    if (task.objectId == null) throw Exception('Task id is required to update');
    final url = Uri.parse('${Back4AppConfig.baseUrl}/classes/Task/${task.objectId}');
    final resp = await http.put(url, headers: _makeHeaders(sessionToken: sessionToken), body: jsonEncode(task.toParse()));
    if (resp.statusCode == 200) return;
    _handleError(resp);
  }

  Future<void> deleteTask(String sessionToken, String objectId) async {
    final url = Uri.parse('${Back4AppConfig.baseUrl}/classes/Task/$objectId');
    final resp = await http.delete(url, headers: _makeHeaders(sessionToken: sessionToken));
    if (resp.statusCode == 200) return;
    _handleError(resp);
  }

  Never _handleError(http.Response resp) {
    try {
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final message = body['error'] ?? body['message'] ?? resp.body;
      final code = body['code'] is int ? body['code'] as int : null;
      throw ParseApiException(code, message.toString(), resp.statusCode);
    } catch (e) {
      // If body is not JSON or parsing failed, throw a generic exception
      throw ParseApiException(null, resp.body, resp.statusCode);
    }
  }
}

