import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../appointments/appointments_screen.dart';
import '../health/health_screen.dart';
import '../profile/profile_screen.dart';
import '../admin/users_management_screen.dart';
import '../prescriptions/prescriptions_screen.dart';
import '../notifications/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Stream para los datos del usuario actual
  Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .snapshots();
  }

  void _navigateToScreen(int index, bool isPatient, bool isAdmin) {
    if (index == 0) {
      setState(() {
        _currentIndex = 0;
      });
      return;
    }

    Widget targetScreen;

    if (isPatient) {
      // Para el PACIENTE, los índices son:
      // 0: Inicio, 1: Mi salud, 2: Perfil
      switch (index) {
        case 1:
          targetScreen = const HealthScreen();
          break;
        case 2:
          targetScreen = const ProfileScreen();
          break;
        default:
          return;
      }
    } else {
      // Para DOCTOR y ADMINISTRADOR:
      // 0: Inicio, 1: Citas, 2: Mi salud, 3: Perfil, 4: Usuarios (Solo Admin)
      switch (index) {
        case 1:
          targetScreen = const AppointmentsScreen();
          break;
        case 2:
          targetScreen = const HealthScreen();
          break;
        case 3:
          targetScreen = const ProfileScreen();
          break;
        case 4:
          if (isAdmin) {
            targetScreen = const UsersManagementScreen();
          } else {
            return;
          }
          break;
        default:
          return;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => targetScreen),
    ).then((_) {
      if (mounted) {
        setState(() {
          _currentIndex = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _userStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4A97E8),
              ),
            ),
          );
        }

        final data = snapshot.data?.data();
        final String nombre = data?['nombre'] ?? 'Usuario';
        final String apellidoPaterno = data?['apellidoPaterno'] ?? '';
        final String fotoPerfil = data?['fotoPerfil'] ?? '';
        final String rol =
            (data?['rol'] ?? 'paciente').toString().toLowerCase();

        final bool isAdmin = rol == 'administrador' || rol == 'admin';
        final bool isDoctor =
            rol == 'doctor' || rol == 'médico' || rol == 'medico';
        final bool isPatient = !isAdmin && !isDoctor;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF1A5BAA),
            unselectedItemColor: Colors.grey,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            iconSize: 22,
            onTap: (index) => _navigateToScreen(index, isPatient, isAdmin),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Inicio",
              ),
              // Si es paciente, NO se muestra la pestaña de Citas
              if (!isPatient)
                const BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month),
                  label: "Citas",
                ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: "Mi salud",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: "Perfil",
              ),
              // SOLO el administrador puede ver el botón de Gestión de Usuarios
              if (isAdmin)
                const BottomNavigationBarItem(
                  icon: Icon(Icons.admin_panel_settings),
                  label: "Usuarios",
                ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // =====================================================
                  // ENCABEZADO / PERFIL Y NOTIFICACIONES
                  // =====================================================
                  Stack(
                    children: [
                      Container(
                        height: 145,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4A97E8),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.elliptical(250, 55),
                            bottomRight: Radius.elliptical(250, 55),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 18,
                        child: IconButton(
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 18,
                          right: 18,
                          top: 65,
                        ),
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfileScreen(),
                                ),
                              );
                            },
                            child: Container(
                              height: 75,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFA9CDEE),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "BIENVENIDO (${rol.toUpperCase()})",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "$nombre $apellidoPaterno"
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Colors.white,
                                    backgroundImage: fotoPerfil.isNotEmpty
                                        ? NetworkImage(fotoPerfil)
                                        : null,
                                    child: fotoPerfil.isEmpty
                                        ? const Icon(
                                            Icons.person,
                                            size: 34,
                                            color: Color(0xFF1A5BAA),
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // =====================================================
                  // PRÓXIMA CITA (Oculto para pacientes)
                  // =====================================================
                  if (!isPatient) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AppointmentsScreen(),
                              ),
                            );
                          },
                          child: const SizedBox(
                            height: 80,
                            child: Row(
                              children: [
                                SizedBox(width: 15),
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Color(0xFFEAF4FF),
                                  child: Icon(
                                    Icons.medical_services,
                                    color: Color(0xFF1A5BAA),
                                    size: 28,
                                  ),
                                ),
                                SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Próxima cita",
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      "Cardiología",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      "Martes, 28 Marzo",
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // =====================================================
                  // MIS RECETAS / RESULTADOS DE LABORATORIO
                  // =====================================================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      children: [
                        Expanded(
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PrescriptionsScreen(),
                                  ),
                                );
                              },
                              child: const SizedBox(
                                height: 95,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.description,
                                      color: Color(0xFF1A5BAA),
                                      size: 34,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "Mis recetas",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HealthScreen(),
                                  ),
                                );
                              },
                              child: const SizedBox(
                                height: 95,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.analytics,
                                      color: Color(0xFF1A5BAA),
                                      size: 34,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "Resultados de\nlaboratorio",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // =====================================================
                  // MÓDULO EXCLUSIVO DE GESTIÓN (Solo Administrador)
                  // O PERFIL (Para Doctor y Paciente)
                  // =====================================================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          if (isAdmin) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const UsersManagementScreen(),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileScreen(),
                              ),
                            );
                          }
                        },
                        child: Container(
                          height: 95,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFA9CDEE),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isAdmin
                                      ? Icons.admin_panel_settings
                                      : Icons.account_circle,
                                  color: const Color(0xFF1A5BAA),
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isAdmin
                                          ? "Gestión de Usuarios"
                                          : "Mi Perfil de Usuario",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A5BAA),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isAdmin
                                          ? "Administrar roles (Doctor, Paciente, Admin)"
                                          : "Ver y editar mis datos personales",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF202124),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 18,
                                color: Color(0xFF1A5BAA),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
