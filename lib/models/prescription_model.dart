class PrescriptionModel {
  final String prescriptionId;
  final String uidPaciente;
  final String nombrePaciente;

  final String uidDoctor;
  final String nombreDoctor;

  final String diagnostico;
  final String indicaciones;

  // Datos del medicamento
  final String medicamento;
  final String dosis;
  final String frecuencia;
  final String duracion;

  final String estado;

  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final DateTime? createdAt;

  PrescriptionModel({
    required this.prescriptionId,
    required this.uidPaciente,
    required this.nombrePaciente,
    required this.uidDoctor,
    required this.nombreDoctor,
    this.diagnostico = "",
    this.indicaciones = "",
    required this.medicamento,
    required this.dosis,
    required this.frecuencia,
    required this.duracion,
    this.estado = "active",
    this.fechaInicio,
    this.fechaFin,
    this.createdAt,
  });

  // Convertir modelo a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      "prescriptionId": prescriptionId,
      "uidPaciente": uidPaciente,
      "nombrePaciente": nombrePaciente,
      "uidDoctor": uidDoctor,
      "nombreDoctor": nombreDoctor,
      "diagnostico": diagnostico,
      "indicaciones": indicaciones,
      "medicamento": medicamento,
      "dosis": dosis,
      "frecuencia": frecuencia,
      "duracion": duracion,
      "estado": estado,
      "fechaInicio": fechaInicio,
      "fechaFin": fechaFin,
      "createdAt": createdAt,
    };
  }

  // Crear modelo desde Firestore
  factory PrescriptionModel.fromMap(Map<String, dynamic> map) {
    return PrescriptionModel(
      prescriptionId: map["prescriptionId"] ?? "",

      uidPaciente: map["uidPaciente"] ?? "",

      nombrePaciente: map["nombrePaciente"] ?? "",

      uidDoctor: map["uidDoctor"] ?? "",

      nombreDoctor: map["nombreDoctor"] ?? "",

      diagnostico: map["diagnostico"] ?? "",

      indicaciones: map["indicaciones"] ?? "",

      medicamento: map["medicamento"] ?? "",

      dosis: map["dosis"] ?? "",

      frecuencia: map["frecuencia"] ?? "",

      duracion: map["duracion"] ?? "",

      estado: map["estado"] ?? "active",

      fechaInicio: map["fechaInicio"] != null
          ? map["fechaInicio"].toDate()
          : null,

      fechaFin: map["fechaFin"] != null ? map["fechaFin"].toDate() : null,

      createdAt: map["createdAt"] != null ? map["createdAt"].toDate() : null,
    );
  }

  // Copiar receta con cambios
  PrescriptionModel copyWith({
    String? prescriptionId,
    String? uidPaciente,
    String? nombrePaciente,
    String? uidDoctor,
    String? nombreDoctor,
    String? diagnostico,
    String? indicaciones,
    String? medicamento,
    String? dosis,
    String? frecuencia,
    String? duracion,
    String? estado,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    DateTime? createdAt,
  }) {
    return PrescriptionModel(
      prescriptionId: prescriptionId ?? this.prescriptionId,

      uidPaciente: uidPaciente ?? this.uidPaciente,

      nombrePaciente: nombrePaciente ?? this.nombrePaciente,

      uidDoctor: uidDoctor ?? this.uidDoctor,

      nombreDoctor: nombreDoctor ?? this.nombreDoctor,

      diagnostico: diagnostico ?? this.diagnostico,

      indicaciones: indicaciones ?? this.indicaciones,

      medicamento: medicamento ?? this.medicamento,

      dosis: dosis ?? this.dosis,

      frecuencia: frecuencia ?? this.frecuencia,

      duracion: duracion ?? this.duracion,

      estado: estado ?? this.estado,

      fechaInicio: fechaInicio ?? this.fechaInicio,

      fechaFin: fechaFin ?? this.fechaFin,

      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Estado de la receta
  bool get isActive => estado == "active";

  bool get isCompleted => estado == "completed";

  bool get isCancelled => estado == "cancelled";
}
