import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'theme_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/task_list_screen.dart';
import 'screens/task_form_screen.dart';
import 'screens/change_password_screen.dart';
import 'config/back4app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Configure Back4App credentials (provided values). These can be
  // overwritten by a .env or secure storage when Back4AppConfig.init() runs.
  Back4AppConfig.setCredentials(
    baseUrl: 'https://parseapi.back4app.com',
    appId: 'KtERNPAKOYvoZJi8aG2FT7i0839fg4ca7QdUCYJ2',
    restApiKey: 'q1w3Il6PFBjVYYZtlBzDehUhtBG4XpI06Jt7ltZV',
  );
  // Initialize config (loads dotenv/secure storage overrides). Await so
  // services reading Back4AppConfig immediately will have correct values.
  await Back4AppConfig.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          final p = AuthProvider();
          // restore any persisted session in background
          p.init();
          return p;
        }),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(builder: (context, theme, _) {
        return MaterialApp(
          title: 'Task Management',
          themeMode: theme.mode,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.indigo,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.indigo,
            brightness: Brightness.dark,
          ),
          initialRoute: '/',
          routes: {
            '/': (_) => const LoginScreen(),
            '/register': (_) => const RegisterScreen(),
            '/tasks': (_) => const TaskListScreen(),
            '/task_form': (_) => const TaskFormScreen(),
            '/change_password': (_) => const ChangePasswordScreen(),
          },
        );
      }),
    );
  }
}
