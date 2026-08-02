import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home/home_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // --- PALETA DE COLORES CLEAN (IDÉNTICA A TU DISEÑO BASE) ---
  final Color medicalBlue = const Color(0xFF1A5BAA);
  final Color textPrimary = const Color(0xFF202124);
  final Color textSecondary = const Color(0xFF5F6368);
  final Color surfaceColor = const Color(0xFFF8F9FA);

  // 🎨 Función auxiliar adaptada a la paleta minimalista
  Map<String, dynamic> _getStyleByType(String? type) {
    switch (type?.toLowerCase()) {
      case 'cita':
        return {
          "icon": Icons.calendar_today_outlined,
          "color": const Color(0xFF1A5BAA),
        };
      case 'receta':
      case 'medicación':
        return {
          "icon": Icons.medication_outlined,
          "color": Colors.green.shade600,
        };
      case 'laboratorio':
      case 'estudio':
        return {
          "icon": Icons.science_outlined,
          "color": Colors.orange.shade700,
        };
      default:
        return {
          "icon": Icons.notifications_outlined,
          "color": Colors.indigo.shade600,
        };
    }
  }

  void _navigateToHome() {
    final homeState = context.findAncestorStateOfType<State<HomeScreen>>();
    if (homeState != null) {
      (homeState as dynamic).setState(() {
        (homeState as dynamic).currentIndex = 0;
      });
    }
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
          onPressed: _navigateToHome,
        ),
        title: Text(
          "NOTIFICACIONES",
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("notifications")
            .orderBy("fecha", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error al cargar notificaciones: ${snapshot.error}",
                style: TextStyle(color: textSecondary),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No tienes notificaciones.",
                style: TextStyle(fontSize: 15, color: textSecondary),
              ),
            );
          }

          final notificationDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            itemCount: notificationDocs.length,
            itemBuilder: (context, index) {
              final id = notificationDocs[index].id;
              final data =
                  notificationDocs[index].data() as Map<String, dynamic>;

              final style = _getStyleByType(data["tipo"]);
              final bool isRead = data["leída"] ?? false;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isRead ? surfaceColor : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isRead
                        ? Colors.grey.shade100
                        : medicalBlue.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (style["color"] as Color).withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          style["icon"] as IconData,
                          color: style["color"] as Color,
                          size: 20,
                        ),
                      ),
                      // Indicador de "No leído" en forma de punto azul minimalista
                      if (!isRead)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: medicalBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    data["titulo"] ?? "Sin título",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                      color: isRead
                          ? textPrimary.withOpacity(0.8)
                          : textPrimary,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      data["mensaje"] ?? "Sin mensaje disponible.",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isRead
                            ? FontWeight.normal
                            : FontWeight.w500,
                        color: isRead
                            ? textSecondary
                            : textPrimary.withOpacity(0.9),
                        height: 1.3,
                      ),
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: textSecondary.withOpacity(0.5),
                    size: 18,
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(data["titulo"] ?? "Notificación"),
                        backgroundColor: medicalBlue,
                      ),
                    );

                    // Actualiza el estado a leído en la base de datos de manera silenciosa
                    FirebaseFirestore.instance
                        .collection("notifications")
                        .doc(id)
                        .update({"leída": true});
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
