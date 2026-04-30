import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../services/back4app_service.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;
  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  String _status = 'Pending';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.task?.title ?? '');
    _descCtrl = TextEditingController(text: widget.task?.description ?? '');
    _status = widget.task?.status ?? 'Pending';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final tasks = Provider.of<TaskProvider>(context, listen: false);
    try {
      final t = Task(
        objectId: widget.task?.objectId,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        status: _status,
      );
      if (widget.task == null) {
        await tasks.addTask(auth, t);
      } else {
        await tasks.updateTask(auth, t);
      }
      Navigator.pop(context, true);
    } catch (e) {
      String message;
      if (e is ParseApiException) {
        message = Back4AppService.mapParseErrorToMessage(e);
      } else {
        message = e.toString();
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $message')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.task == null ? 'Create Task' : 'Edit Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v == null || v.isEmpty ? 'Enter title' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _status,
                items: const [
                  DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'InProgress', child: Text('In Progress')),
                  DropdownMenuItem(value: 'Complete', child: Text('Complete')),
                ],
                onChanged: (v) => setState(() => _status = v ?? 'Pending'),
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: _loading ? null : _save, child: const Text('Save')),
              )
            ],
          ),
        ),
      ),
    );
  }
}

