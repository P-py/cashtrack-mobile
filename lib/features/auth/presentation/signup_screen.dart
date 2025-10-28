import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cashtrack_mobile/features/auth/data/auth_service.dart';
import 'package:cashtrack_mobile/features/auth/presentation/login_screen.dart';
import 'package:cashtrack_mobile/features/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  bool _validateFields() {
    if (_nameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _passwordCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Preencha todos os campos obrigatórios.'),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _handleRegister() async {
    if (!_validateFields()) return;
    FocusScope.of(context).unfocus();

    setState(() => _loading = true);
    final auth = context.read<AuthService>();
    final error = await auth.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
    );

    setState(() => _loading = false);

    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Cadastro realizado com sucesso!')),
      );

      await Future.delayed(const Duration(milliseconds: 800));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const darkMainBg = Color(0xFF2A2728);
    const darkFontColor = Color(0xFFC0B7B1);
    const darkSecondaryHighlight = Color(0xFF8E6E53);

    return Scaffold(
      backgroundColor: darkMainBg,
      appBar: AppBar(
        backgroundColor: darkMainBg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Cadastrar",
          style: TextStyle(
            color: darkFontColor,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: darkFontColor),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: child,
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(
                        color: darkFontColor, fontFamily: 'Poppins'),
                    decoration: _inputDecoration('Nome *'),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: _emailCtrl,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                        color: darkFontColor, fontFamily: 'Poppins'),
                    decoration: _inputDecoration('E-mail *'),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleRegister(),
                    style: const TextStyle(
                        color: darkFontColor, fontFamily: 'Poppins'),
                    decoration: _inputDecoration('Senha *').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: darkFontColor.withValues(alpha: .7),
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkSecondaryHighlight,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _loading ? null : _handleRegister,
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Cadastrar",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    const darkFontColor = Color(0xFFC0B7B1);
    const darkPrimaryHighlight = Color(0xFFC69C72);
    const darkSecondaryHighlight = Color(0xFF8E6E53);
    const darkFieldBg = Color(0xFF201D1E);

    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: darkFontColor,
        fontFamily: 'Poppins',
      ),
      filled: true,
      fillColor: darkFieldBg,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkSecondaryHighlight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkPrimaryHighlight, width: 2),
      ),
    );
  }
}
