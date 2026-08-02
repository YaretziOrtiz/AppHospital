import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Importa tus pantallas reales aquí
import 'forgot_password.dart';
import 'register_screen.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;

  bool obscurePassword = true;
  bool loading = false;

  // Definición de colores basados en tu paleta original
  final Color primaryBlue = const Color(
    0xff1976D2,
  ); // Azul profesional para acciones
  final Color lightBlueGrey = const Color(
    0xffE1F5FE,
  ); // Azul muy claro para fondos de input
  final Color textPrimary = Colors.black87;
  final Color textSecondary = Colors.grey.shade600;

  Future<void> login() async {
    setState(() => loading = true);

    try {
      await auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Error al iniciar sesión";
      if (e.code == "user-not-found") {
        message = "El usuario no existe";
      } else if (e.code == "wrong-password") {
        message = "Contraseña incorrecta";
      } else if (e.code == "invalid-credential") {
        message = "Correo o contraseña incorrectos";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco puro para máxima limpieza
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 400,
              ), // Ancho máximo contenido
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- ICONO SUTIL ---
                  Icon(
                    Icons.medical_services_outlined,
                    size: 50,
                    color: primaryBlue.withOpacity(0.7),
                  ),
                  const SizedBox(height: 30),

                  // --- TEXTO DE BIENVENIDA SOBRIO ---
                  Text(
                    "Bienvenido/a",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Por favor, introduce tus credenciales médicas para acceder.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // --- CAMPO CORREO ---
                  _buildFlatTextField(
                    controller: emailController,
                    hint: "Correo institucional",
                    icon: Icons.email_outlined,
                  ),

                  const SizedBox(height: 15),

                  // --- CAMPO CONTRASEÑA ---
                  _buildFlatTextField(
                    controller: passwordController,
                    hint: "Contraseña",
                    icon: Icons.lock_outline,
                    obscureText: obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  // --- OLVIDASTE CONTRASEÑA ---
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPassword(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: textSecondary,
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.all(4),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        "¿Olvidaste tu contraseña?",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  // --- BOTÓN INGRESAR SÓLIDO ---
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0, // Sin sombra para un look plano
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            8,
                          ), // Bordes más serios
                        ),
                      ),
                      onPressed: loading ? null : login,
                      child: loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "INICIAR SESIÓN",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- SECCIÓN REGISTRO ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "¿No tienes cuenta?",
                        style: TextStyle(color: textSecondary, fontSize: 14),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: primaryBlue,
                        ),
                        child: const Text(
                          "Crear una",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER PARA CONSTRUIR INPUTS PLANOS (FLAT) ---
  Widget _buildFlatTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100, // Fondo gris muy suave
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 15, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 22),
          suffixIcon: suffixIcon,
          border: InputBorder.none, // Eliminamos borde predeterminado
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          // Sutil línea inferior al enfocar para guía del usuario
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primaryBlue, width: 1.5),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
