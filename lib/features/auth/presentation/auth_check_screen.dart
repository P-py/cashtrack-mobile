import 'package:cashtrack_mobile/components/main_navigation.dart';
import 'package:cashtrack_mobile/features/auth/data/auth_service.dart';
import 'package:cashtrack_mobile/features/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    await auth.loadTokenIfNeeded(context);

    if (!mounted) return;

    if (auth.isAuthenticated) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF2A2728),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF8E6E53)),
      ),
    );
  }
}
