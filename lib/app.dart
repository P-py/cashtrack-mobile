import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/app_config.dart';
import 'features/auth/presentation/auth_check_screen.dart';

class CashtrackApp extends StatelessWidget {
  const CashtrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConfig.appName,
        theme: AppTheme.darkTheme,
        home: const AuthCheckScreen(),
    );
  }
}
