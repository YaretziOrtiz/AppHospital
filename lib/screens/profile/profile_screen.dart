import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../login/login_screen.dart';
import '../home/home_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // --- PALETA DE COLORES CLEAN (IDÉNTICA A HOME Y PESTAÑAS ANTERIORES) ---
  final Color medicalBlue = const Color(0xFF1A5BAA);
  final Color textPrimary = const Color(0xFF202124);
  final Color textSecondary = const Color(0xFF5F6368);
  final Color surfaceColor = const Color(0xFFF8F9FA);

  // Función para enviar el correo de restablecimiento de contraseña
  Future<void> _cambiarContrasena(BuildContext context, String? email) async {
    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "No se encontró un correo válido para restablecer la contraseña.",
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Se ha enviado un correo a $email para restablecer tu contraseña.",
            ),
            backgroundColor: Colors.green.shade600,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al enviar el correo: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _navigateToHome(BuildContext context) {
    final homeState = context.findAncestorStateOfType<State<HomeScreen>>();
    if (homeState != null) {
      (homeState as dynamic).setState(() {
        (homeState as dynamic).currentIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            "Usuario no autenticado",
            style: TextStyle(color: textSecondary),
          ),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc("JEsqUxkKPaushkSUn3I7")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: TextStyle(color: textSecondary),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Text(
                "No existe información del usuario",
                style: TextStyle(color: textSecondary),
              ),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final userEmail = data["email"] ?? user.email;

        String fechaNacimientoStr = "No registrada";
        if (data["fechaNacimiento"] != null &&
            data["fechaNacimiento"] is Timestamp) {
          final DateTime date = (data["fechaNacimiento"] as Timestamp).toDate();
          fechaNacimientoStr = "${date.day}/${date.month}/${date.year}";
        }

        return Scaffold(
          backgroundColor:
              Colors.white, // Fondo limpio e idéntico a todo el ecosistema
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: textPrimary,
            elevation: 0,
            centerTitle: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              color: textPrimary,
              onPressed: () => _navigateToHome(context),
            ),
            title: Text(
              "MI PERFIL",
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
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 24.0,
            ),
            child: Column(
              children: [
                // Cabecera de Perfil Minimalista
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: medicalBlue.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              data["fotoPerfil"] != null &&
                                  data["fotoPerfil"].toString().isNotEmpty
                              ? NetworkImage(data["fotoPerfil"])
                              : null,
                          backgroundColor: surfaceColor,
                          child:
                              data["fotoPerfil"] == null ||
                                  data["fotoPerfil"].toString().isEmpty
                              ? Icon(
                                  Icons.person_outline,
                                  size: 50,
                                  color: textSecondary,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "${data["nombre"] ?? ""} ${data["apellidoPaterno"] ?? ""}"
                            .trim(),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data["rol"] ?? "Paciente",
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Bloque 1: Información Personal (Planos, Estilo Home)
                Container(
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade100, width: 1),
                  ),
                  child: Column(
                    children: [
                      _buildCleanTile(
                        icon: Icons.email_outlined,
                        iconColor: medicalBlue,
                        title: "Correo electrónico",
                        subtitle: userEmail ?? "No disponible",
                      ),
                      _buildDivider(),
                      _buildCleanTile(
                        icon: Icons.location_on_outlined,
                        iconColor: Colors.green.shade400,
                        title: "Dirección residencia",
                        subtitle: data["direccion"] ?? "No registrada",
                      ),
                      _buildDivider(),
                      _buildCleanTile(
                        icon: Icons.cake_outlined,
                        iconColor: Colors.orange.shade400,
                        title: "Fecha de nacimiento",
                        subtitle: fechaNacimientoStr,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Bloque 2: Ajustes y Cuenta (Planos, Estilo Home)
                Container(
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade100, width: 1),
                  ),
                  child: Column(
                    children: [
                      _buildActionTile(
                        icon: Icons.edit_outlined,
                        iconColor: medicalBlue,
                        title: "Editar perfil",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditProfileScreen(currentData: data),
                            ),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildActionTile(
                        icon: Icons.lock_reset_outlined,
                        iconColor: Colors.amber.shade700,
                        title: "Cambiar contraseña",
                        onTap: () => _cambiarContrasena(context, userEmail),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                // Botón Cerrar Sesión Outlined Minimalista
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFFE57373),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      foregroundColor: const Color(0xFFD32F2F),
                    ),
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text(
                      "Cerrar Sesión",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- WIDGETS AUXILIARES PARA EL ACABADO CLEAN ---
  Widget _buildCleanTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: textSecondary.withOpacity(0.5),
        size: 18,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(color: Color(0xFFEAEAEA), height: 1),
    );
  }
}
