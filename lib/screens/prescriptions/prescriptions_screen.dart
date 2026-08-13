import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home/home_screen.dart';

class PrescriptionsScreen extends StatefulWidget {
  const PrescriptionsScreen({super.key});

  @override
  State<PrescriptionsScreen> createState() => _PrescriptionsScreenState();
}

class _PrescriptionsScreenState extends State<PrescriptionsScreen> {
  // --- PALETA DE COLORES CLEAN (IDÉNTICA A HOME) ---
  final Color medicalBlue = const Color(0xFF1A5BAA);
  final Color textPrimary = const Color(0xFF202124);
  final Color textSecondary = const Color(0xFF5F6368);
  final Color surfaceColor = const Color(0xFFF8F9FA);

  // REGRESAR A LA PANTALLA ANTERIOR / HOME
  void _navigateToHome() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco plano
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
          "MIS RECETAS",
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
        stream:
            FirebaseFirestore.instance.collection("prescriptions").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error al cargar recetas: ${snapshot.error}",
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
                "No hay recetas médicas registradas.",
                style: TextStyle(fontSize: 15, color: textSecondary),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final prescriptionData =
                  docs[index].data() as Map<String, dynamic>;
              return PrescriptionCleanCard(
                prescription: prescriptionData,
                medicalBlue: medicalBlue,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                surfaceColor: surfaceColor,
              );
            },
          );
        },
      ),
    );
  }
}

// 🟢 WIDGET DE TARJETA REDISEÑADO AL ESTILO ULTRA CLEAN
class PrescriptionCleanCard extends StatelessWidget {
  final Map<String, dynamic> prescription;
  final Color medicalBlue;
  final Color textPrimary;
  final Color textSecondary;
  final Color surfaceColor;

  const PrescriptionCleanCard({
    super.key,
    required this.prescription,
    required this.medicalBlue,
    required this.textPrimary,
    required this.textSecondary,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    final doctorRef = prescription["doctor"] as DocumentReference?;

    String fechaFormateada = "Fecha no disponible";
    if (prescription["fecha"] != null && prescription["fecha"] is Timestamp) {
      final DateTime date = (prescription["fecha"] as Timestamp).toDate();
      fechaFormateada = "${date.day}/${date.month}/${date.year}";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: FutureBuilder<DocumentSnapshot>(
        future: doctorRef?.get(),
        builder: (context, doctorSnapshot) {
          String nombreDoctor = "Cargando doctor...";
          String especialidadDoctor = "Consultando especialidad...";

          if (doctorSnapshot.hasData && doctorSnapshot.data!.exists) {
            final doctorData =
                doctorSnapshot.data!.data() as Map<String, dynamic>?;
            nombreDoctor =
                "Dr. ${doctorData?["nombre"] ?? ""} ${doctorData?["apellidoPaterno"] ?? ""}"
                    .trim();
            especialidadDoctor =
                doctorData?["especialidad"] ?? "Médico Especialista";
            if (nombreDoctor == "Dr.") nombreDoctor = "Doctor Asignado";
          } else if (doctorSnapshot.hasError ||
              (doctorSnapshot.connectionState == ConnectionState.done &&
                  !doctorSnapshot.hasData)) {
            nombreDoctor = "Doctor no encontrado";
            especialidadDoctor = "No disponible";
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado con indicador lateral plano
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: medicalBlue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombreDoctor,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          especialidadDoctor,
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    fechaFormateada,
                    style: TextStyle(
                      fontSize: 13,
                      color: textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(color: Color(0xFFEAEAEA), height: 1),
              ),

              // Detalles del Medicamento Asignado
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.medication_outlined,
                    color: Colors.green.shade400,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prescription["medicamento"] ?? "No especificado",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Dosis: ${prescription["dosis"] ?? '--'}   •   Frecuencia: ${prescription["frecuencia"] ?? '--'}   •   Duración: ${prescription["duracion"] ?? '--'}",
                          style: TextStyle(
                            fontSize: 13,
                            color: textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Indicaciones Opcionales
              if (prescription["indicaciones"] != null &&
                  prescription["indicaciones"].toString().isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade100, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Indicaciones:",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        prescription["indicaciones"],
                        style: TextStyle(
                          fontSize: 13,
                          color: textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Botón Outlined Minimalista para Descarga
              SizedBox(
                width: double.infinity,
                height: 40,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Generando formato de receta médica en PDF...",
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.picture_as_pdf,
                    size: 16,
                    color: medicalBlue,
                  ),
                  label: Text(
                    "Descargar PDF",
                    style: TextStyle(
                      color: medicalBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: medicalBlue.withOpacity(0.4)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
