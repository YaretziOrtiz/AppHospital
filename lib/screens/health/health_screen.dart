import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  // --- PALETA DE COLORES CLEAN (IDÉNTICA A HOME) ---
  final Color medicalBlue = const Color(0xFF1A5BAA);
  final Color textPrimary = const Color(0xFF202124);
  final Color textSecondary = const Color(0xFF5F6368);
  final Color surfaceColor = const Color(0xFFF8F9FA);

  // REGRESAR A LA PANTALLA ANTERIOR / HOME
  void _navigateToHome() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo limpio e idéntico al Home
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
          "MI SALUD",
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
            .collection("medical_records")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error al cargar datos de salud: ${snapshot.error}",
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
                "No hay registros médicos.",
                style: TextStyle(fontSize: 15, color: textSecondary),
              ),
            );
          }

          final medicalData =
              snapshot.data!.docs.first.data() as Map<String, dynamic>;

          String fechaRegistro = "No disponible";
          if (medicalData["fechaRegistro"] != null &&
              medicalData["fechaRegistro"] is Timestamp) {
            final DateTime date =
                (medicalData["fechaRegistro"] as Timestamp).toDate();
            fechaRegistro = "${date.day}/${date.month}/${date.year}";
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Signos Vitales",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "Act. al: $fechaRegistro",
                      style: TextStyle(color: textSecondary, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Grid o Lista de Signos Vitales Estilo Home
                _infoCleanCard(
                  icon: Icons.favorite,
                  title: "Presión arterial",
                  value: medicalData["presionArterial"] ?? "Sin datos",
                  color: Colors.pink.shade400,
                ),
                _infoCleanCard(
                  icon: Icons.water_drop,
                  title: "Glucosa",
                  value: "${medicalData["glucosa"] ?? '--'} mg/dL",
                  color: Colors.orange.shade400,
                ),
                _infoCleanCard(
                  icon: Icons.scale,
                  title: "Peso",
                  value: "${medicalData["peso"] ?? '--'} kg",
                  color: Colors.green.shade400,
                ),
                _infoCleanCard(
                  icon: Icons.height,
                  title: "Estatura",
                  value: "${medicalData["altura"] ?? '--'} m",
                  color: Colors.indigo.shade400,
                ),
                _infoCleanCard(
                  icon: Icons.monitor_heart,
                  title: "Frecuencia Cardíaca",
                  value: "${medicalData["frecuenciaCardiaca"] ?? '--'} bpm",
                  color: Colors.red.shade400,
                ),
                _infoCleanCard(
                  icon: Icons.air,
                  title: "Saturación de Oxígeno",
                  value: "${medicalData["saturacionOxigeno"] ?? '--'} %",
                  color: Colors.teal.shade400,
                ),
                _infoCleanCard(
                  icon: Icons.thermostat,
                  title: "Temperatura",
                  value: "${medicalData["temperatura"] ?? '--'} °C",
                  color: Colors.amber.shade700,
                ),

                const SizedBox(height: 28),

                Text(
                  "Diagnóstico y Tratamiento",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                // Diagnóstico Clínico Estilo Home
                _sectionCleanCard(
                  icon: Icons.assignment_outlined,
                  iconColor: medicalBlue,
                  title: "Diagnóstico Clínico",
                  description: medicalData["diagnostico"] ?? "No especificado",
                ),

                // Tratamiento Asignado Estilo Home
                _sectionCleanCard(
                  icon: Icons.medication_outlined,
                  iconColor: Colors.purple.shade400,
                  title: "Tratamiento Asignado",
                  description:
                      medicalData["tratamiento"] ?? "Ninguno prescrito",
                ),

                // Observaciones Médicas Estilo Home
                _sectionCleanCard(
                  icon: Icons.visibility_outlined,
                  iconColor: Colors.amber.shade700,
                  title: "Observaciones Médicas",
                  description:
                      medicalData["observaciones"] ?? "Sin observaciones",
                  isItalic: true,
                ),

                const SizedBox(height: 20),

                // Botón Minimalista Outlined
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Generando reporte de salud en PDF..."),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.picture_as_pdf,
                      size: 18,
                      color: medicalBlue,
                    ),
                    label: Text(
                      "Descargar Expediente",
                      style: TextStyle(
                        color: medicalBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: medicalBlue.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Tarjeta Plana de Signos Vitales con Línea Lateral Estilo Home
  Widget _infoCleanCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Icon(icon, color: color.withOpacity(0.8), size: 22),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // Tarjeta Estructurada para Secciones de Texto
  Widget _sectionCleanCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    bool isItalic = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: textSecondary,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
