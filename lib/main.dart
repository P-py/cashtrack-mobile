import 'package:cashtrack_mobile/app.dart';
import 'package:cashtrack_mobile/features/auth/data/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa AuthService antes de rodar o app
  final authService = await AuthService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authService),
      ],
      child: const CashtrackApp(),
    ),
  );
}
