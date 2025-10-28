import 'dart:ui';
import 'package:cashtrack_mobile/features/auth/presentation/login_screen.dart';
import 'package:cashtrack_mobile/features/auth/presentation/signup_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const darkMainBg = Color(0xFF2A2728);
    const darkSecondaryBg = Color(0xFF201D1E);
    const darkFontColor = Color(0xFFC0B7B1);
    const darkPrimaryHighlight = Color(0xFFC69C72);
    const darkSecondaryHighlight = Color(0xFF8E6E53);

    return Scaffold(
      backgroundColor: darkMainBg,
      body: SafeArea(
        child: Stack(
          children: [
            // 🔹 Imagem de fundo com blur e preto e branco
            Positioned.fill(
              child: ColorFiltered(
                colorFilter: const ColorFilter.matrix([
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0, 0, 0, 1, 0,
                ]),
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Image.asset(
                    'assets/images/background.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // 🔹 Overlay escuro para manter o contraste geral
            Positioned.fill(
              child: Container(
                color: const Color.fromRGBO(32, 29, 30, 0.65),
              ),
            ),

            // 🔹 Gradiente superior (atrás do logo)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 150,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF201D1E), // sólido no topo
                      Color.fromRGBO(32, 29, 30, 0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // 🔹 Gradiente inferior (transição para os botões)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 160,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color.fromRGBO(32, 29, 30, 0.5),
                      Color(0xFF201D1E),
                    ],
                  ),
                ),
              ),
            ),

            // 🔹 Conteúdo principal
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // logo no topo direito
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: darkSecondaryBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 40,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 80),

                // texto central
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: const [
                      Text(
                        'Bem-vindo ao Cashtrack',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: darkPrimaryHighlight,
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Gerencie suas finanças de forma fácil e intuitiva — e o melhor, com um projeto OpenSource!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: darkFontColor,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // 🔹 Rodapé sólido com botões
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  decoration: const BoxDecoration(
                    color: darkSecondaryBg,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                          onPressed: () {
                            Navigator.of(context).push(PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 700),
                              reverseTransitionDuration: const Duration(milliseconds: 700),
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  const SignUpScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                final offsetAnim = Tween<Offset>(
                                  begin: const Offset(0, 0.1), // sobe levemente
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

                                final fadeAnim =
                                    CurvedAnimation(parent: animation, curve: Curves.easeInOut);

                                return SlideTransition(
                                  position: offsetAnim,
                                  child: FadeTransition(
                                    opacity: fadeAnim,
                                    child: child,
                                  ),
                                );
                              },
                            ));
                          },
                          child: const Text(
                            'Sign up',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side:
                                const BorderSide(color: darkSecondaryHighlight),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 700),
                              reverseTransitionDuration: const Duration(milliseconds: 700),
                              pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                final offsetAnim = Tween<Offset>(
                                  begin: const Offset(0, 0.1), // começa levemente abaixo
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

                                final fadeAnim = CurvedAnimation(parent: animation, curve: Curves.easeInOut);

                                return SlideTransition(
                                  position: offsetAnim,
                                  child: FadeTransition(
                                    opacity: fadeAnim,
                                    child: child,
                                  ),
                                );
                              },
                            ));
                          },
                          child: const Text(
                            'Log in',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: darkFontColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
