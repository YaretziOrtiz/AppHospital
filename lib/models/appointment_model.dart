class AppointmentModel {
  final String appointmentId;
  final String uidPaciente;
  final String uidDoctor;
  final String nombrePaciente;
  final String nombreDoctor;
  final String especialidad;
  final String fecha;
  final String hora;
  final String motivo;
  final String estado;
  final String notas;
  final DateTime? createdAt;

  AppointmentModel({
    required this.appointmentId,
    required this.uidPaciente,
    required this.uidDoctor,
    required this.nombrePaciente,
    required this.nombreDoctor,
    required this.especialidad,
    required this.fecha,
    required this.hora,
    required this.motivo,
    required this.estado,
    this.notas = "",
    this.createdAt,
  });

  // Convertir modelo a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      "appointmentId": appointmentId,
      "uidPaciente": uidPaciente,
      "uidDoctor": uidDoctor,
      "nombrePaciente": nombrePaciente,
      "nombreDoctor": nombreDoctor,
      "especialidad": especialidad,
      "fecha": fecha,
      "hora": hora,
      "motivo": motivo,
      "estado": estado,
      "notas": notas,
      "createdAt": createdAt,
    };
  }

  // Crear modelo desde Firestore
  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      appointmentId: map["appointmentId"] ?? "",

      uidPaciente: map["uidPaciente"] ?? "",

      uidDoctor: map["uidDoctor"] ?? "",

      nombrePaciente: map["nombrePaciente"] ?? "",

      nombreDoctor: map["nombreDoctor"] ?? "",

      especialidad: map["especialidad"] ?? "",

      fecha: map["fecha"] ?? "",

      hora: map["hora"] ?? "",

      motivo: map["motivo"] ?? "",

      estado: map["estado"] ?? "pending",

      notas: map["notas"] ?? "",

      createdAt: map["createdAt"] != null ? map["createdAt"].toDate() : null,
    );
  }

  // Crear copia modificando datos
  AppointmentModel copyWith({
    String? appointmentId,
    String? uidPaciente,
    String? uidDoctor,
    String? nombrePaciente,
    String? nombreDoctor,
    String? especialidad,
    String? fecha,
    String? hora,
    String? motivo,
    String? estado,
    String? notas,
    DateTime? createdAt,
  }) {
    return AppointmentModel(
      appointmentId: appointmentId ?? this.appointmentId,

      uidPaciente: uidPaciente ?? this.uidPaciente,

      uidDoctor: uidDoctor ?? this.uidDoctor,

      nombrePaciente: nombrePaciente ?? this.nombrePaciente,

      nombreDoctor: nombreDoctor ?? this.nombreDoctor,

      especialidad: especialidad ?? this.especialidad,

      fecha: fecha ?? this.fecha,

      hora: hora ?? this.hora,

      motivo: motivo ?? this.motivo,

      estado: estado ?? this.estado,

      notas: notas ?? this.notas,

      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Verificar estado de la cita
  bool get isPending => estado == "pending";

  bool get isConfirmed => estado == "confirmed";

  bool get isCompleted => estado == "completed";

  bool get isCancelled => estado == "cancelled";
}
