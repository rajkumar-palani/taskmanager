import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/back4app_service.dart';
import 'auth_provider.dart';

class TaskProvider extends ChangeNotifier {
  final Back4AppService _service = Back4AppService();
  final List<Task> _tasks = [];
  List<Task> get tasks => List.unmodifiable(_tasks);

  Future<void> loadTasks(AuthProvider auth, {String? titleFilter, String? statusFilter}) async {
    if (!auth.isAuthenticated) return;
    String? where;
    final whereMap = <String, dynamic>{};
    if (titleFilter != null && titleFilter.isNotEmpty) {
      // Use Parse-compatible regex key; escape the dollar sign for Dart string interpolation
      whereMap['title'] = {'\$regex': titleFilter};
    }
    if (statusFilter != null && statusFilter.isNotEmpty) {
      whereMap['status'] = statusFilter;
    }
    if (whereMap.isNotEmpty) where = whereMapToJson(whereMap);
    final list = await _service.getTasks(auth.sessionToken!, whereJson: where);
    _tasks
      ..clear()
      ..addAll(list);
    notifyListeners();
  }

  Future<void> addTask(AuthProvider auth, Task task) async {
    if (!auth.isAuthenticated) throw Exception('Not authenticated');
    // ensure task has owner pointer so Parse records ownership
    if (task.ownerId == null && auth.userId != null) task.ownerId = auth.userId;
    final created = await _service.createTask(auth.sessionToken!, task);
    _tasks.add(created);
    notifyListeners();
  }

  Future<void> updateTask(AuthProvider auth, Task task) async {
    if (!auth.isAuthenticated) throw Exception('Not authenticated');
    await _service.updateTask(auth.sessionToken!, task);
    final idx = _tasks.indexWhere((t) => t.objectId == task.objectId);
    if (idx != -1) _tasks[idx] = task;
    notifyListeners();
  }

  Future<void> deleteTask(AuthProvider auth, String objectId) async {
    if (!auth.isAuthenticated) throw Exception('Not authenticated');
    await _service.deleteTask(auth.sessionToken!, objectId);
    _tasks.removeWhere((t) => t.objectId == objectId);
    notifyListeners();
  }

  String whereMapToJson(Map<String, dynamic> m) {
    return jsonEncode(m);
  }
}



