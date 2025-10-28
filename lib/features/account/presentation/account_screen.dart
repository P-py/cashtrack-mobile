import 'dart:convert';
import 'package:cashtrack/features/auth/data/auth_service.dart';
import 'package:cashtrack/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final String baseUrl = 'https://cash-track-api-production.up.railway.app';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();

  bool loading = true;
  bool saving = false;
  bool error = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthService>(context, listen: false);
      auth.checkTokenExpiryProactively(context);
    });
    _loadAccount();
  }

  Future<void> _loadAccount() async {
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      await auth.loadTokenIfNeeded(context);
      final headers = auth.authHeaders;

      final res = await http.get(Uri.parse('$baseUrl/users/account'), headers: headers);
      if (res.statusCode != 200) throw Exception('Erro ao carregar conta');

      final data = jsonDecode(res.body);
      usernameCtrl.text = data['username'] ?? '';
      emailCtrl.text = data['email'] ?? '';

      setState(() => loading = false);
    } catch (e) {
      debugPrint('Erro: $e');
      setState(() {
        error = true;
        loading = false;
      });
    }
  }

  Future<void> _updateAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF201D1E),
        title: const Text(
          'Confirmação de segurança',
          style: TextStyle(color: Color(0xFFC0B7B1)),
        ),
        content: const Text(
          '⚠️ Ao atualizar suas informações de conta, '
          'você será desconectado e precisará fazer login novamente.\n\n'
          'Deseja continuar?',
          style: TextStyle(color: Color(0xFFC0B7B1), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Continuar',
              style: TextStyle(color: Color(0xFF8E6E53)),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return; // Usuário desistiu
    setState(() => saving = true);
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      final headers = {...auth.authHeaders, 'Content-Type': 'application/json'};
      debugPrint('Headers: $headers');

      final url = '$baseUrl/users';
      final body = {
        "username": usernameCtrl.text.trim(),
        "email": emailCtrl.text.trim(),
      };
      debugPrint('Body: $body');

      final res = await http.put(Uri.parse(url), headers: headers, body: jsonEncode(body));
      debugPrint('Response: ${res.body}');

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Conta atualizada com sucesso!')),
        );

        await Future.delayed(const Duration(seconds: 1)); // UX suave

        final auth = Provider.of<AuthService>(context, listen: false);
        await auth.logout(context);

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        throw Exception('Erro HTTP ${res.statusCode}');
      }
    } catch (e, stack) {
      debugPrint(stack.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌Erro ao atualizar conta. Tente novamente mais tarde.')),
      );
    } finally {
      setState(() => saving = false);
    }
  }

  Future<void> _deleteAccount() async {
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF201D1E),
        title: const Text(
          'Tem certeza?',
          style: TextStyle(color: Color(0xFFC0B7B1)),
        ),
        content: const Text(
          'Você está prestes a excluir permanentemente sua conta. '
          'Essa ação não pode ser desfeita.\n\nDeseja continuar?',
          style: TextStyle(color: Color(0xFFC0B7B1)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Continuar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (firstConfirm != true) return; // o usuário desistiu

    // Segunda verificação: o usuário deve digitar "EXCLUIR"
    final confirmCtrl = TextEditingController();
    final secondConfirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF201D1E),
        title: const Text(
          'Confirmação final',
          style: TextStyle(color: Color(0xFFC0B7B1)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Para confirmar, digite "EXCLUIR" no campo abaixo:',
              style: TextStyle(color: Color(0xFFC0B7B1)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Digite EXCLUIR',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF2A2728),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF8E6E53)),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              if (confirmCtrl.text.trim().toUpperCase() == 'EXCLUIR') {
                Navigator.pop(ctx, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('⚠️ Digite EXCLUIR corretamente para confirmar.'),
                  ),
                );
              }
            },
            child: const Text('Confirmar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (secondConfirm != true) return;

    // Request real para exclusão
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      final headers = auth.authHeaders;
      final url = '$baseUrl/users/delete-my-account';

      final res = await http.delete(Uri.parse(url), headers: headers);

      if (res.statusCode == 204 || res.statusCode == 200) {
        await auth.logout(context);
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        throw Exception('Erro HTTP ${res.statusCode}');
      }
    } catch (e, stack) {
      debugPrint(stack.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌Erro ao excluir conta. Tente novamente mais tarde.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    const darkMainBg = Color(0xFF2A2728);
    const darkSecondaryBg = Color(0xFF201D1E);
    const darkFontColor = Color(0xFFC0B7B1);
    const highlightColor = Color(0xFF8E6E53);

    return Scaffold(
      backgroundColor: darkMainBg,
      appBar: AppBar(
        backgroundColor: darkSecondaryBg,
        elevation: 0,
        title: const Text(
          "Minha Conta",
          style: TextStyle(
            color: darkFontColor,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: highlightColor),
            onPressed: () async {
              final auth = Provider.of<AuthService>(context, listen: false);
              await auth.logout(context);
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: loading
    ? const Center(
        child: CircularProgressIndicator(color: highlightColor),
      )
    : error
        ? const Center(
            child: Text(
              'Erro ao carregar conta',
              style: TextStyle(color: darkFontColor),
            ),
          )
        : SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // 🔔 ALERTA DE SEGURANÇA
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: highlightColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: highlightColor.withOpacity(0.3),
                        ),
                      ),
                      child: const Text(
                        '⚠️ Por segurança, ao alterar seus dados, '
                        'você será desconectado e precisará fazer login novamente.',
                        style: TextStyle(
                          color: darkFontColor,
                          fontSize: 13,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // CAMPOS
                    _buildTextField(
                      controller: usernameCtrl,
                      label: "Nome de Usuário",
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: emailCtrl,
                      label: "E-mail",
                      inputType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 30),

                    // BOTÕES
                    ElevatedButton(
                      onPressed: saving ? null : _updateAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: highlightColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Salvar Alterações",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: _deleteAccount,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Excluir Conta",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFC0B7B1)),
        filled: true,
        fillColor: const Color(0xFF2A2728),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF8E6E53)),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Campo obrigatório';
        return null;
      },
    );
  }
}
