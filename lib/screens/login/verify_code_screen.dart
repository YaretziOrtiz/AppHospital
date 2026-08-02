import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- IMPORTACIÓN PARA COMPROBAR EN FIRESTORE
import 'new_password_screen.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;

  const VerifyCodeScreen({super.key, required this.email});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final codeController = TextEditingController();
  bool isLoading = false; // <-- Indicador de carga para la verificación

  // --- PALETA DE COLORES CLEAN (CONSISTENTE) ---
  final Color medicalBlue = const Color(0xFF1A5BAA);
  final Color textPrimary = const Color(0xFF202124);
  final Color textSecondary = const Color(0xFF5F6368);
  final Color surfaceColor = const Color(0xFFF8F9FA);

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  // Se transforma a una función asíncrona para consultar a la base de datos
  void verifyCode() async {
    final codeInput = codeController.text.trim();

    if (codeInput.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("El código debe tener 6 dígitos."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Buscamos en la colección de códigos un documento que coincida con el email y el código
      // NOTA: Cambia 'password_resets' por el nombre exacto de tu colección en Firestore si usas otra
      final querySnapshot = await FirebaseFirestore.instance
          .collection('password_resets')
          .where('email', isEqualTo: widget.email.trim())
          .where('code', isEqualTo: codeInput)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // OPCIONAL: Si el código expira por tiempo, puedes validar un campo 'expiresAt' aquí.

        // Código válido: Pasamos a la pantalla de crear la nueva contraseña
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => NewPasswordScreen(email: widget.email),
          ),
        );
      } else {
        // Código incorrecto
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "El código de verificación es incorrecto o ha expirado.",
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      // Captura de errores de conexión o permisos
      debugPrint("Error al verificar el código: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ocurrió un error: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
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
          "VERIFICAR CÓDIGO",
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

              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: medicalBlue.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_user_outlined,
                    size: 44,
                    color: medicalBlue,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Text(
                "Verificación",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "Ingresa el código de 6 dígitos enviado a:",
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

              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  letterSpacing: 8,
                  color: textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  counterText: "",
                  hintText: "000000",
                  hintStyle: TextStyle(
                    color: textSecondary.withOpacity(0.3),
                    letterSpacing: 8,
                  ),
                  filled: true,
                  fillColor: surfaceColor,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.shade100,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: medicalBlue.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // Botón Principal adaptado con estado de carga
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
                  onPressed: isLoading ? null : verifyCode,
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Verificar",
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
                onPressed: () {
                  // Lógica visual simulada de reenvío
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        "Solicitando un nuevo código de verificación...",
                      ),
                      backgroundColor: medicalBlue,
                    ),
                  );
                },
                child: Text(
                  "Reenviar código",
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
}
