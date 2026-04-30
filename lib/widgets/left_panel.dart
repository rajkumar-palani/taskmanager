import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme_provider.dart';
import '../config/back4app_config.dart';

class LeftPanel extends StatelessWidget {
  final VoidCallback onTaskList;
  final VoidCallback onChangePassword;
  final VoidCallback onLogout;

  const LeftPanel({super.key, required this.onTaskList, required this.onChangePassword, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(auth.username ?? 'Guest'),
              accountEmail: Text(auth.username ?? ''),
              currentAccountPicture: CircleAvatar(child: Text((auth.username ?? 'G').substring(0, 1).toUpperCase())),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Task List'),
              onTap: onTaskList,
            ),
            ListTile(
              leading: const Icon(Icons.lock_reset),
              title: const Text('Change Password'),
              onTap: onChangePassword,
            ),
            const Divider(),
            ListTile(
              leading: Icon(theme.mode == ThemeMode.light ? Icons.light_mode : Icons.dark_mode),
              title: const Text('Toggle Theme'),
              trailing: Switch(
                value: theme.mode == ThemeMode.dark,
                onChanged: (_) => theme.toggle(),
              ),
              onTap: () => theme.toggle(),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text('App Version: ${Back4AppConfig.appVersion}', style: Theme.of(context).textTheme.bodySmall),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log out'),
              onTap: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}

