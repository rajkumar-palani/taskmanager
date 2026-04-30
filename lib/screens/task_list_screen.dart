import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/left_panel.dart';
import 'task_form_screen.dart';
import '../services/back4app_service.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String? _titleFilter;
  String? _statusFilter;
  final _titleCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      await Provider.of<TaskProvider>(context, listen: false).loadTasks(auth);
    } catch (e) {
      String message;
      if (e is ParseApiException) {
        message = Back4AppService.mapParseErrorToMessage(e);
      } else {
        message = e.toString();
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Load failed: $message')));
    }
  }

  Future<void> _applyFilters() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      await Provider.of<TaskProvider>(context, listen: false).loadTasks(auth,
          titleFilter: _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim(), statusFilter: _statusFilter);
    } catch (e) {
      String message;
      if (e is ParseApiException) {
        message = Back4AppService.mapParseErrorToMessage(e);
      } else {
        message = e.toString();
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Filter failed: $message')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final tasks = Provider.of<TaskProvider>(context).tasks;
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      drawer: LeftPanel(
        onTaskList: () => Navigator.popUntil(context, ModalRoute.withName('/tasks')),
        onChangePassword: () => Navigator.pushNamed(context, '/change_password'),
        onLogout: () async {
          await auth.logout();
          Navigator.pushReplacementNamed(context, '/');
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _titleCtrl,
                        decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Filter by title'),
                        onSubmitted: (_) => _applyFilters(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _statusFilter,
                      hint: const Text('Status'),
                      items: const [
                        DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                        DropdownMenuItem(value: 'InProgress', child: Text('In Progress')),
                        DropdownMenuItem(value: 'Complete', child: Text('Complete')),
                      ],
                      onChanged: (v) => setState(() {
                        _statusFilter = v;
                        _applyFilters();
                      }),
                    ),
                    IconButton(onPressed: () => setState(() { _statusFilter = null; _titleCtrl.clear(); _applyFilters(); }), icon: const Icon(Icons.clear)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                child: tasks.isEmpty
                    ? ListView(
                        children: [Center(child: Padding(padding: const EdgeInsets.all(24.0), child: Text('No tasks found. Pull to refresh or add a new task.')))],
                      )
                    : ListView.separated(
                        itemCount: tasks.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final t = tasks[index];
                          return ListTile(
                            title: Text(t.title),
                            subtitle: Text(t.description),
                            trailing: Chip(label: Text(t.status)),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TaskFormScreen(task: t))).then((v) => _load()),
                            onLongPress: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Delete Task'),
                                  content: const Text('Are you sure you want to delete this task?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                try {
                                  await Provider.of<TaskProvider>(context, listen: false).deleteTask(auth, t.objectId!);
                                  _load();
                                } catch (e) {
                                  String message;
                                  if (e is ParseApiException) {
                                    message = Back4AppService.mapParseErrorToMessage(e);
                                  } else {
                                    message = e.toString();
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $message')));
                                }
                              }
                            },
                          );
                        },
                      ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TaskFormScreen())).then((v) => _load()),
        child: const Icon(Icons.add),
      ),
    );
  }
}


