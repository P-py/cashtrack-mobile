import 'package:flutter/material.dart';

class SessionExpiryBanner extends StatelessWidget {
  final VoidCallback onLogout;

  const SessionExpiryBanner({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      backgroundColor: const Color(0xFF8E6E53),
      content: const Text(
        '⚠️ Sua sessão vai expirar em breve. Salve seu progresso.',
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: onLogout,
          child: const Text(
            'Sair agora',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
