import 'package:flutter/material.dart';
import 'login_screen.dart';

class NewPasswordScreen extends StatefulWidget {
  final String email;

  const NewPasswordScreen({super.key, required this.email});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  // --- PALETA DE COLORES CLEAN (CONSISTENTE) ---
  final Color medicalBlue = const Color(0xFF1A5BAA);
  final Color textPrimary = const Color(0xFF202124);
  final Color textSecondary = const Color(0xFF5F6368);
  final Color surfaceColor = const Color(0xFFF8F9FA);

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void updatePassword() {
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Completa todos los campos."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("La contraseña debe tener al menos 6 caracteres."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Las contraseñas no coinciden."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Aquí actualizaremos la contraseña con Firebase Authentication.

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Contraseña actualizada correctamente."),
        backgroundColor: Colors.green.shade600,
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo limpio plano
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
          "NUEVA CONTRASEÑA",
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              // Icono estilizado dentro de círculo sutil
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: medicalBlue.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.lock_outline, size: 44, color: medicalBlue),
                ),
              ),

              const SizedBox(height: 25),

              Text(
                "Crear nueva contraseña",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "Ingresa una nueva contraseña para la cuenta:",
                textAlign: TextAlign.center,
                style: TextStyle(color: textSecondary, fontSize: 14),
              ),

              const SizedBox(height: 6),

              Text(
                widget.email,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: medicalBlue,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 35),

              // Campo: Nueva Contraseña
              _buildCleanTextField(
                controller: passwordController,
                label: "Nueva contraseña",
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

              // Campo: Confirmar Contraseña
              _buildCleanTextField(
                controller: confirmPasswordController,
                label: "Confirmar contraseña",
                icon: Icons.lock_clock_outlined,
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

              const SizedBox(height: 35),

              // Botón Principal
              SizedBox(
                width: double.infinity,
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
                  onPressed: updatePassword,
                  child: const Text(
                    "Actualizar contraseña",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Botón Secundario Plano
              TextButton(
                style: TextButton.styleFrom(foregroundColor: textSecondary),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Volver",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET AUXILIAR GENERADOR DE INPUTS MINIMALISTAS ---
  Widget _buildCleanTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
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
