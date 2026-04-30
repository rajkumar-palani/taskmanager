import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/back4app_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _change() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      await auth.changePassword(_passCtrl.text);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed')));
      Navigator.pop(context);
    } catch (e) {
      String message;
      if (e is ParseApiException) {
        message = Back4AppService.mapParseErrorToMessage(e);
      } else {
        message = e.toString();
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $message')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _passCtrl,
                decoration: const InputDecoration(labelText: 'New Password'),
                obscureText: true,
                validator: (v) => (v == null || v.isEmpty) ? 'Enter new password' : null,
              ),
              const Spacer(),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _loading ? null : _change, child: const Text('Change')))
            ],
          ),
        ),
      ),
    );
  }
}

