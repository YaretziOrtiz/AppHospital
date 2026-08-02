import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home/home_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final specialtyController = TextEditingController();
  final locationController = TextEditingController();
  final reasonController = TextEditingController();
  final obsController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  DocumentReference? selectedDoctorRef;

  // --- PALETA DE COLORES CLEAN (IDÉNTICA A HOME) ---
  final Color medicalBlue = const Color(0xFF1A5BAA);
  final Color textPrimary = const Color(0xFF202124);
  final Color textSecondary = const Color(0xFF5F6368);
  final Color surfaceColor = const Color(0xFFF8F9FA);

  @override
  void dispose() {
    specialtyController.dispose();
    locationController.dispose();
    reasonController.dispose();
    obsController.dispose();
    super.dispose();
  }

  Future<void> selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void clearFields() {
    specialtyController.clear();
    locationController.clear();
    reasonController.clear();
    obsController.clear();
    selectedDate = null;
    selectedTime = null;
    selectedDoctorRef = null;
  }

  Future<void> saveAppointment({String? docId}) async {
    if (specialtyController.text.isEmpty ||
        locationController.text.isEmpty ||
        reasonController.text.isEmpty ||
        selectedDate == null ||
        selectedTime == null ||
        selectedDoctorRef == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Completa todos los campos, incluyendo el doctor."),
        ),
      );
      return;
    }

    final finalDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    final appointmentData = {
      "consultorio": locationController.text.trim(),
      "especialidad": specialtyController.text.trim(),
      "motivo": reasonController.text.trim(),
      "observaciones": obsController.text.trim(),
      "estado": "Confirmado",
      "fecha": Timestamp.fromDate(finalDateTime),
      "doctor": selectedDoctorRef,
      "createdAt": FieldValue.serverTimestamp(),
    };

    try {
      if (docId == null) {
        await FirebaseFirestore.instance
            .collection("appointments")
            .add(appointmentData);
      } else {
        await FirebaseFirestore.instance
            .collection("appointments")
            .doc(docId)
            .update(appointmentData);
      }

      if (mounted) {
        Navigator.pop(context);
        clearFields();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error al guardar: $e")));
      }
    }
  }

  Future<void> deleteAppointment(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection("appointments")
          .doc(docId)
          .delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cita eliminada correctamente.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error al eliminar: $e")));
      }
    }
  }

  void openDialog({String? docId, Map<String, dynamic>? currentData}) {
    if (docId != null && currentData != null) {
      locationController.text = currentData["consultorio"] ?? "";
      specialtyController.text = currentData["especialidad"] ?? "";
      reasonController.text = currentData["motivo"] ?? "";
      obsController.text = currentData["observaciones"] ?? "";
      selectedDoctorRef = currentData["doctor"] as DocumentReference?;

      if (currentData["fecha"] != null && currentData["fecha"] is Timestamp) {
        final DateTime dt = (currentData["fecha"] as Timestamp).toDate();
        selectedDate = dt;
        selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
      }
    } else {
      clearFields();
    }

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              docId == null ? "Nueva cita" : "Editar cita",
              style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return const CircularProgressIndicator();
                      final docs = snapshot.data!.docs;
                      return DropdownButtonFormField<DocumentReference>(
                        decoration: const InputDecoration(
                          labelText: "Selecciona el Doctor",
                        ),
                        value: selectedDoctorRef,
                        items: docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final nombreCompleto =
                              "Dr. ${data["nombre"] ?? ""} ${data["apellidoPaterno"] ?? ""}"
                                  .trim();
                          return DropdownMenuItem<DocumentReference>(
                            value: doc.reference,
                            child: Text(
                              nombreCompleto.isEmpty
                                  ? "Sin nombre"
                                  : nombreCompleto,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedDoctorRef = value;
                          });
                        },
                      );
                    },
                  ),
                  TextField(
                    controller: specialtyController,
                    decoration: const InputDecoration(
                      labelText: "Especialidad",
                    ),
                  ),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: "Consultorio/Hospital",
                    ),
                  ),
                  TextField(
                    controller: reasonController,
                    decoration: const InputDecoration(labelText: "Motivo"),
                  ),
                  TextField(
                    controller: obsController,
                    decoration: const InputDecoration(
                      labelText: "Observaciones",
                    ),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await selectDate(context);
                      setDialogState(() {});
                    },
                    icon: Icon(
                      Icons.calendar_month_outlined,
                      color: medicalBlue,
                      size: 18,
                    ),
                    label: Text(
                      selectedDate == null
                          ? "Seleccionar fecha"
                          : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await selectTime(context);
                      setDialogState(() {});
                    },
                    icon: Icon(Icons.access_time, color: medicalBlue, size: 18),
                    label: Text(
                      selectedTime == null
                          ? "Seleccionar hora"
                          : selectedTime!.format(context),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  clearFields();
                },
                child: Text("Cancelar", style: TextStyle(color: textSecondary)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: medicalBlue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => saveAppointment(docId: docId),
                child: const Text("Guardar"),
              ),
            ],
          );
        },
      ),
    );
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
      backgroundColor: Colors.white, // Cambiado a blanco puro como Home
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
          "MIS CITAS",
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: medicalBlue,
        elevation: 2,
        onPressed: () => openDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("appointments")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Error al cargar citas: ${snapshot.error}"),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No hay citas registradas.",
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
              final doc = docs[index];
              final appointment = doc.data() as Map<String, dynamic>;
              final String docId = doc.id;

              return AppointmentCleanCard(
                docId: docId,
                appointment: appointment,
                medicalBlue: medicalBlue,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                surfaceColor: surfaceColor,
                onEdit: () =>
                    openDialog(docId: docId, currentData: appointment),
                onDelete: () => deleteAppointment(docId),
              );
            },
          );
        },
      ),
    );
  }
}

// --- TARJETA RE-DISEÑADA ESTILO HOME ---
class AppointmentCleanCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> appointment;
  final Color medicalBlue;
  final Color textPrimary;
  final Color textSecondary;
  final Color surfaceColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AppointmentCleanCard({
    super.key,
    required this.docId,
    required this.appointment,
    required this.medicalBlue,
    required this.textPrimary,
    required this.textSecondary,
    required this.surfaceColor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final doctorRef = appointment["doctor"] as DocumentReference?;

    String diaMes = "-- --";
    String horaMinuto = "--:--";

    if (appointment["fecha"] != null && appointment["fecha"] is Timestamp) {
      final DateTime date = (appointment["fecha"] as Timestamp).toDate();
      final meses = [
        'Ene',
        'Feb',
        'Mar',
        'Abr',
        'May',
        'Jun',
        'Jul',
        'Ago',
        'Sep',
        'Oct',
        'Nov',
        'Dic',
      ];
      diaMes = "${date.day} ${meses[date.month - 1]}";
      horaMinuto =
          "${date.hour}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}";
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

          if (doctorSnapshot.hasData && doctorSnapshot.data!.exists) {
            final doctorData =
                doctorSnapshot.data!.data() as Map<String, dynamic>?;
            nombreDoctor =
                "Dr. ${doctorData?["nombre"] ?? ""} ${doctorData?["apellidoPaterno"] ?? ""}"
                    .trim();
            if (nombreDoctor == "Dr.") nombreDoctor = "Doctor Asignado";
          } else if (doctorSnapshot.hasError ||
              (doctorSnapshot.connectionState == ConnectionState.done &&
                  !doctorSnapshot.hasData)) {
            nombreDoctor = "Doctor no encontrado";
          }

          return Row(
            children: [
              Container(
                width: 4,
                height: 75,
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
                      nombreDoctor,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${appointment["especialidad"] ?? "General"} • ${appointment["consultorio"] ?? "No especificado"}",
                      style: TextStyle(
                        fontSize: 13,
                        color: textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Motivo: ${appointment["motivo"] ?? ""}",
                      style: TextStyle(
                        fontSize: 12,
                        color: textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    diaMes,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: medicalBlue,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    horaMinuto,
                    style: TextStyle(fontSize: 12, color: textSecondary),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, size: 20, color: textSecondary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onSelected: (value) {
                      if (value == "Editar") onEdit();
                      if (value == "Eliminar") onDelete();
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: "Editar", child: Text("Editar")),
                      PopupMenuItem(value: "Eliminar", child: Text("Eliminar")),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
