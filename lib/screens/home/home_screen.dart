import 'package:flutter/material.dart';

// Asegúrate de verificar las rutas de tus importaciones reales
import '../appointments/appointments_screen.dart';
import '../health/health_screen.dart';
import '../notifications/notifications_screen.dart';
import '../prescriptions/prescriptions_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  // --- PALETA DE COLORES CLÍNICA CLEAN ---
  final Color medicalBlue = const Color(
    0xFF1A5BAA,
  ); // Azul institucional unificado
  final Color unselectedGrey = const Color(0xFF9AA0A6);

  late final List<Widget> pages = [
    HomePage(
      onCardTap: (index) {
        setState(() {
          currentIndex = index;
        });
      },
    ),
    const AppointmentsScreen(),
    const HealthScreen(),
    const PrescriptionsScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: pages[currentIndex],
      // --- BOTTOM NAVIGATION BAR ULTRA CLEAN ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade100, width: 1.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: medicalBlue,
          unselectedItemColor: unselectedGrey,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
          elevation: 0, // Plano y limpio
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: "Inicio",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: "Citas",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline),
              activeIcon: Icon(Icons.favorite),
              label: "Salud",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medication_outlined),
              activeIcon: Icon(Icons.medication),
              label: "Recetas",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications),
              label: "Avisos",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: "Perfil",
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final Function(int) onCardTap;

  const HomePage({super.key, required this.onCardTap});

  // --- COLORES COMPARTIDOS ---
  final Color medicalBlue = const Color(0xFF1A5BAA);
  final Color textPrimary = const Color(0xFF202124);
  final Color textSecondary = const Color(0xFF5F6368);
  final Color surfaceColor = const Color(
    0xFFF8F9FA,
  ); // Gris casi blanco para las tarjetas

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Icon(Icons.add_moderator_outlined, color: medicalBlue, size: 24),
            const SizedBox(width: 8),
            Text(
              "HOSPITAL DIGITAL",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textSecondary,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        // 🛠️ CORRECCIÓN AQUÍ: Se usa la propiedad 'shape' para la línea inferior del AppBar
        shape: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              "Buenos días,",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              "Gestione su información clínica desde este panel.",
              style: TextStyle(fontSize: 15, color: textSecondary),
            ),
            const SizedBox(height: 32),

            // --- SECCIÓN: ACCESOS DIRECTOS ---
            Text(
              "Servicios principales",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            // Grilla limpia con tarjetas planas
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _buildCleanMenuCard(
                  icon: Icons.calendar_month_outlined,
                  title: "Mis Citas",
                  onTap: () => onCardTap(1), // Hacia AppointmentsScreen
                ),
                _buildCleanMenuCard(
                  icon: Icons.monitor_heart_outlined,
                  title: "Mi Salud",
                  onTap: () => onCardTap(2), // Hacia HealthScreen
                ),
                _buildCleanMenuCard(
                  icon: Icons.medication_outlined,
                  title: "Recetas Médicas",
                  onTap: () => onCardTap(3), // Hacia PrescriptionsScreen
                ),
                _buildCleanMenuCard(
                  icon: Icons.notifications_outlined,
                  title: "Avisos y Alertas",
                  onTap: () => onCardTap(4), // Hacia NotificationsScreen
                ),
              ],
            ),

            const SizedBox(height: 36),

            // --- SECCIÓN: PRÓXIMA CITA ---
            Text(
              "Próxima cita programada",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            // Tarjeta informativa elegante y sobria
            GestureDetector(
              onTap: () =>
                  onCardTap(1), // Te lleva directo a la pestaña de Citas
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade100, width: 1),
                ),
                child: Row(
                  children: [
                    // Indicador lateral sutil
                    Container(
                      width: 4,
                      height: 50,
                      decoration: BoxDecoration(
                        color: medicalBlue,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Dr. Juan Pérez",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Cardiología • Consultorio 302",
                            style: TextStyle(
                              fontSize: 14,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "15 Ago",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: medicalBlue,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "10:30 AM",
                          style: TextStyle(fontSize: 13, color: textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER: TARJETA DE MENÚ MINIMALISTA ---
  Widget _buildCleanMenuCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 26, color: medicalBlue),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
