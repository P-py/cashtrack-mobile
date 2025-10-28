import 'dart:convert';
import 'package:cashtrack_mobile/core/app_config.dart';
import 'package:cashtrack_mobile/core/theme/app_theme.dart';
import 'package:cashtrack_mobile/core/utils/api_service.dart';
import 'package:cashtrack_mobile/core/utils/logger.dart';
import 'package:cashtrack_mobile/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService extends ChangeNotifier {
  String? _token;
  String? get token => _token;
  bool get isAuthenticated => _token != null;

  late final ApiService _api;
  final String baseUrl = AppConfig.baseUrl;

  AuthService._();

  static Future<AuthService> init() async {
    final service = AuthService._();
    await service._loadToken();
    service._api = ApiService(baseUrl: service.baseUrl, auth: service);
    return service;
  }

  Map<String, String> get authHeaders => {
        'Content-Type': 'application/json',
        if (_token != null)
          'Authorization': _token!.startsWith('Bearer ')
              ? _token!
              : 'Bearer $_token',
      };

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('access_token');
    notifyListeners();
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
    _token = token;
    notifyListeners();
  }

  Future<void> logout(BuildContext context, {bool soft = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    _token = null;
    notifyListeners();

    if (context.mounted) {
      if (soft) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.darkTheme.colorScheme.primary,
            content: const Text('⚠️ Sua sessão expirou. Faça login novamente.'),
            duration: const Duration(seconds: 4),
          ),
        );
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  bool isTokenExpired() {
    if (_token == null) return true;
    try {
      return JwtDecoder.isExpired(_token!);
    } catch (_) {
      return true;
    }
  }

  Future<void> loadTokenIfNeeded(BuildContext context) async {
    if (_token == null) {
      await _loadToken();
    }

    if (_token == null) {
      appLog('[AuthService] Nenhum token encontrado — usuário novo.');
      return;
    }

    if (isTokenExpired()) {
      appLog('[AuthService] Token expirado, realizando logout suave.');
      await logout(context, soft: true);
    }
  }

  Future<String?> login(String email, String password) async {
    final resp = await _api.post('/auth', {
      'email': email,
      'password': password,
    });

    if (resp.statusCode == 200 || resp.statusCode == 204) {
      final token = resp.headers['authorization'] ??
          (jsonDecode(resp.body)['token'] ?? '');
      if (token.isNotEmpty) {
        await _saveToken(token);
        return null;
      } else {
        return 'Token não encontrado.';
      }
    } else {
      return 'Erro ${resp.statusCode}: ${resp.body}';
    }
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final resp = await _api.post('/users', {
      'username': name,
      'email': email,
      'password': password,
    });

    if (resp.statusCode == 201) {
      return null;
    } else {
      return 'Erro ${resp.statusCode}: ${resp.reasonPhrase ?? resp.body}';
    }
  }

  void checkTokenExpiryProactively(BuildContext context) {
    if (_token == null) return;

    try {
      final expirationDate = JwtDecoder.getExpirationDate(_token!);
      final now = DateTime.now();
      final remaining = expirationDate.difference(now);

      if (remaining > Duration.zero && remaining <= const Duration(minutes: 2)) {
        _showExpiryBanner(context);
      } else if (remaining.isNegative) {
        logout(context, soft: true);
      }
    } catch (e) {
      appLog('[AuthService] Falha ao decodificar token: $e');
    }
  }

  void _showExpiryBanner(BuildContext context) {
    if (context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearMaterialBanners();
      messenger.showMaterialBanner(
        MaterialBanner(
          backgroundColor: AppTheme.darkTheme.colorScheme.secondary,
          content: const Text(
            '⚠️ Sua sessão vai expirar em breve. Salve suas alterações!',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text('Sair agora', style: TextStyle(color: Colors.white)),
              onPressed: () {
                messenger.hideCurrentMaterialBanner();
                logout(context, soft: true);
              },
            ),
          ],
        ),
      );
    }
  }
}
