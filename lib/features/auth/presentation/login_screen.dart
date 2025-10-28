import 'package:cashtrack/components/main_navigation.dart';
import 'package:cashtrack/features/auth/data/auth_service.dart';
import 'package:cashtrack/features/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

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
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login(BuildContext context) async {
    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha e-mail e senha.')));
      return;
    }

    final auth = Provider.of<AuthService>(context, listen: false);
    setState(() => _loading = true);

    final error = await auth.login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text.trim(),
    );

    setState(() => _loading = false);

    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Login realizado com sucesso!')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
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
          "Entrar",
          style: TextStyle(
            color: darkFontColor,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: darkFontColor,
          ),
          onPressed:
              () => Navigator.pushReplacement(
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
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: _fadeAnim.value,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 700),
                    offset: _slideAnim.value,
                    curve: Curves.easeOut,
                    child: child,
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _emailCtrl,
                    style: const TextStyle(
                      color: darkFontColor,
                      fontFamily: 'Poppins',
                    ),
                    decoration: _inputDecoration('E-mail'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    style: const TextStyle(
                      color: darkFontColor,
                      fontFamily: 'Poppins',
                    ),
                    decoration: _inputDecoration('Senha'),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkSecondaryHighlight,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _loading ? null : () => _login(context),
                      child:
                          _loading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Text(
                                "Entrar",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                ),
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
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: darkFontColor, fontFamily: 'Poppins'),
      filled: true,
      fillColor: const Color(0xFF201D1E),
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
