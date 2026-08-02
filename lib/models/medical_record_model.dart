class MedicalRecordModel {
  final String recordId;
  final String uidPaciente;
  final String nombrePaciente;

  // Información médica general
  final String tipoSangre;
  final String alergias;
  final String enfermedades;
  final String antecedentes;

  // Información de consulta
  final String diagnostico;
  final String tratamiento;
  final String observaciones;

  final String uidDoctor;
  final String nombreDoctor;
  final String especialidad;

  final DateTime? fechaConsulta;
  final DateTime? createdAt;

  MedicalRecordModel({
    required this.recordId,
    required this.uidPaciente,
    required this.nombrePaciente,
    this.tipoSangre = "",
    this.alergias = "",
    this.enfermedades = "",
    this.antecedentes = "",
    this.diagnostico = "",
    this.tratamiento = "",
    this.observaciones = "",
    this.uidDoctor = "",
    this.nombreDoctor = "",
    this.especialidad = "",
    this.fechaConsulta,
    this.createdAt,
  });

  // Convertir modelo a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      "recordId": recordId,
      "uidPaciente": uidPaciente,
      "nombrePaciente": nombrePaciente,
      "tipoSangre": tipoSangre,
      "alergias": alergias,
      "enfermedades": enfermedades,
      "antecedentes": antecedentes,
      "diagnostico": diagnostico,
      "tratamiento": tratamiento,
      "observaciones": observaciones,
      "uidDoctor": uidDoctor,
      "nombreDoctor": nombreDoctor,
      "especialidad": especialidad,
      "fechaConsulta": fechaConsulta,
      "createdAt": createdAt,
    };
  }

  // Crear modelo desde Firestore
  factory MedicalRecordModel.fromMap(Map<String, dynamic> map) {
    return MedicalRecordModel(
      recordId: map["recordId"] ?? "",

      uidPaciente: map["uidPaciente"] ?? "",

      nombrePaciente: map["nombrePaciente"] ?? "",

      tipoSangre: map["tipoSangre"] ?? "",

      alergias: map["alergias"] ?? "",

      enfermedades: map["enfermedades"] ?? "",

      antecedentes: map["antecedentes"] ?? "",

      diagnostico: map["diagnostico"] ?? "",

      tratamiento: map["tratamiento"] ?? "",

      observaciones: map["observaciones"] ?? "",

      uidDoctor: map["uidDoctor"] ?? "",

      nombreDoctor: map["nombreDoctor"] ?? "",

      especialidad: map["especialidad"] ?? "",

      fechaConsulta: map["fechaConsulta"] != null
          ? map["fechaConsulta"].toDate()
          : null,

      createdAt: map["createdAt"] != null ? map["createdAt"].toDate() : null,
    );
  }

  // Copiar expediente con cambios
  MedicalRecordModel copyWith({
    String? recordId,
    String? uidPaciente,
    String? nombrePaciente,
    String? tipoSangre,
    String? alergias,
    String? enfermedades,
    String? antecedentes,
    String? diagnostico,
    String? tratamiento,
    String? observaciones,
    String? uidDoctor,
    String? nombreDoctor,
    String? especialidad,
    DateTime? fechaConsulta,
    DateTime? createdAt,
  }) {
    return MedicalRecordModel(
      recordId: recordId ?? this.recordId,

      uidPaciente: uidPaciente ?? this.uidPaciente,

      nombrePaciente: nombrePaciente ?? this.nombrePaciente,

      tipoSangre: tipoSangre ?? this.tipoSangre,

      alergias: alergias ?? this.alergias,

      enfermedades: enfermedades ?? this.enfermedades,

      antecedentes: antecedentes ?? this.antecedentes,

      diagnostico: diagnostico ?? this.diagnostico,

      tratamiento: tratamiento ?? this.tratamiento,

      observaciones: observaciones ?? this.observaciones,

      uidDoctor: uidDoctor ?? this.uidDoctor,

      nombreDoctor: nombreDoctor ?? this.nombreDoctor,

      especialidad: especialidad ?? this.especialidad,

      fechaConsulta: fechaConsulta ?? this.fechaConsulta,

      createdAt: createdAt ?? this.createdAt,
    );
  }
}
