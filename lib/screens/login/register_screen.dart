import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  // --- PALETA DE COLORES CLEAN ---
  final Color medicalBlue = const Color(0xFF1A5BAA);
  final Color textPrimary = const Color(0xFF202124);
  final Color textSecondary = const Color(0xFF5F6368);
  final Color surfaceColor = const Color(0xFFF8F9FA);

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE REGISTRO CON FIREBASE ---
  Future<void> _registerUser() async {
    // Validaciones básicas de formulario
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      _showSnackBar("Por favor completa todos los campos", Colors.orangeAccent);
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showSnackBar("Las contraseñas no coinciden", Colors.redAccent);
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1. Crear usuario en Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      String uid = userCredential.user!.uid;

      // 2. Insertar en Firestore respetando la estructura exacta de tu base de datos
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'TipoSangre': "O+",
        'activo': true,
        'alergias': "Ninguna",
        'apellidoMaterno': "",
        'apellidoPaterno': "",
        'createAt': FieldValue.serverTimestamp(),
        'direccion': "",
        'edad': 0,
        'email': emailController.text.trim(),
        'fechaNacimiento': FieldValue.serverTimestamp(),
        'fotoPerfil': "",
        'nombre': nameController.text.trim(),
        'rol': "administrador",
        'sexo': "Femenino",
        'telefono': phoneController.text.trim(),
      });

      if (mounted) {
        _showSnackBar("Usuario registrado exitosamente", Colors.green);
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String mensaje = "Error al registrar el usuario";
      if (e.code == 'weak-password') {
        mensaje = "La contraseña debe tener al menos 6 caracteres";
      } else if (e.code == 'email-already-in-use') {
        mensaje = "Este correo electrónico ya está registrado";
      } else if (e.code == 'invalid-email') {
        mensaje = "El correo electrónico no es válido";
      }
      if (mounted) _showSnackBar(mensaje, Colors.redAccent);
    } catch (e) {
      if (mounted) _showSnackBar("Error inesperado: $e", Colors.redAccent);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "CREAR CUENTA",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        shape: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: medicalBlue.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_add_alt_1_outlined,
                    size: 40,
                    color: medicalBlue,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                "Registro de Usuario",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                "Completa los datos para crear tu cuenta",
                textAlign: TextAlign.center,
                style: TextStyle(color: textSecondary, fontSize: 14),
              ),

              const SizedBox(height: 32),

              _buildCleanTextField(
                controller: nameController,
                label: "Nombre completo",
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 16),

              _buildCleanTextField(
                controller: emailController,
                label: "Correo electrónico",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              _buildCleanTextField(
                controller: phoneController,
                label: "Teléfono",
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 16),

              _buildCleanTextField(
                controller: passwordController,
                label: "Contraseña",
                icon: Icons.lock_outline,
                obscureText: obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: textSecondary.withOpacity(0.7),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 16),

              _buildCleanTextField(
                controller: confirmPasswordController,
                label: "Confirmar contraseña",
                icon: Icons.lock_reset_outlined,
                obscureText: obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: textSecondary.withOpacity(0.7),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      obscureConfirmPassword = !obscureConfirmPassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 36),

              // Botón Principal con indicador de carga
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: medicalBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isLoading ? null : _registerUser,
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Crear cuenta",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              TextButton(
                style: TextButton.styleFrom(foregroundColor: medicalBlue),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "¿Ya tienes cuenta? Inicia sesión",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: medicalBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCleanTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 15,
        color: textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: textSecondary.withOpacity(0.8),
          fontSize: 13,
        ),
        floatingLabelStyle: TextStyle(
          color: medicalBlue,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        filled: true,
        fillColor: surfaceColor,
        prefixIcon: Icon(icon, color: textSecondary.withOpacity(0.7), size: 20),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: medicalBlue.withOpacity(0.4),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
