import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final Timestamp? fechaNacimiento;
  final int edad;
  final String sexo;
  final String telefono;
  final String email;
  final String direccion;
  final String tipoSangre;
  final String alergias;
  final String fotoPerfil;
  final String rol;
  final bool activo;
  final Timestamp? createdAt;

  UserModel({
    required this.uid,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    this.fechaNacimiento,
    required this.edad,
    required this.sexo,
    required this.telefono,
    required this.email,
    required this.direccion,
    required this.tipoSangre,
    required this.alergias,
    required this.fotoPerfil,
    required this.rol,
    required this.activo,
    this.createdAt,
  });

  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return UserModel(
      uid: document.id,
      nombre: data['nombre'] ?? '',
      apellidoPaterno: data['apellidoPaterno'] ?? '',
      apellidoMaterno: data['apellidoMaterno'] ?? '',
      fechaNacimiento: data['fechaNacimiento'] as Timestamp?,
      edad: data['edad'] ?? 0,
      sexo: data['sexo'] ?? '',
      telefono: data['telefono'] ?? '',
      email: data['email'] ?? '',
      direccion: data['direccion'] ?? '',
      tipoSangre: data['tipoSangre'] ?? '',
      alergias: data['alergias'] ?? '',
      fotoPerfil: data['fotoPerfil'] ?? '',
      rol: data['rol'] ?? 'paciente',
      activo: data['activo'] ?? true,
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno,
      'fechaNacimiento': fechaNacimiento,
      'edad': edad,
      'sexo': sexo,
      'telefono': telefono,
      'email': email,
      'direccion': direccion,
      'tipoSangre': tipoSangre,
      'alergias': alergias,
      'fotoPerfil': fotoPerfil,
      'rol': rol,
      'activo': activo,
      'createdAt': createdAt,
    };
  }

  UserModel copyWith({
    String? uid,
    String? nombre,
    String? apellidoPaterno,
    String? apellidoMaterno,
    Timestamp? fechaNacimiento,
    int? edad,
    String? sexo,
    String? telefono,
    String? email,
    String? direccion,
    String? tipoSangre,
    String? alergias,
    String? fotoPerfil,
    String? rol,
    bool? activo,
    Timestamp? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      nombre: nombre ?? this.nombre,
      apellidoPaterno: apellidoPaterno ?? this.apellidoPaterno,
      apellidoMaterno: apellidoMaterno ?? this.apellidoMaterno,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      edad: edad ?? this.edad,
      sexo: sexo ?? this.sexo,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      direccion: direccion ?? this.direccion,
      tipoSangre: tipoSangre ?? this.tipoSangre,
      alergias: alergias ?? this.alergias,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      rol: rol ?? this.rol,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get nombreCompleto {
    return '$nombre $apellidoPaterno $apellidoMaterno';
  }
}
