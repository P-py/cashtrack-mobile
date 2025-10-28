import 'package:cashtrack_mobile/screens/auth_check_screen.dart';
import 'package:cashtrack_mobile/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cashtrack',
      theme: ThemeData(fontFamily: 'Poppins'),
      home: const AuthCheckScreen(),
    );
  }
}

