class UserModel {
  final String uid;
  final String nombre;
  final String apellido;
  final String email;
  final String telefono;
  final String fechaNacimiento;
  final String genero;
  final String rol;
  final String fotoPerfil;
  final String especialidad;
  final String cedula;
  final bool activo;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.telefono,
    required this.fechaNacimiento,
    required this.genero,
    required this.rol,
    this.fotoPerfil = "",
    this.especialidad = "",
    this.cedula = "",
    this.activo = true,
    this.createdAt,
  });

  // Convertir objeto a JSON para Firebase Firestore
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "nombre": nombre,
      "apellido": apellido,
      "email": email,
      "telefono": telefono,
      "fechaNacimiento": fechaNacimiento,
      "genero": genero,
      "rol": rol,
      "fotoPerfil": fotoPerfil,
      "especialidad": especialidad,
      "cedula": cedula,
      "activo": activo,
      "createdAt": createdAt,
    };
  }

  // Crear objeto desde Firebase Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map["uid"] ?? "",
      nombre: map["nombre"] ?? "",
      apellido: map["apellido"] ?? "",
      email: map["email"] ?? "",
      telefono: map["telefono"] ?? "",
      fechaNacimiento: map["fechaNacimiento"] ?? "",
      genero: map["genero"] ?? "",
      rol: map["rol"] ?? "patient",
      fotoPerfil: map["fotoPerfil"] ?? "",
      especialidad: map["especialidad"] ?? "",
      cedula: map["cedula"] ?? "",
      activo: map["activo"] ?? true,

      createdAt: map["createdAt"] != null ? map["createdAt"].toDate() : null,
    );
  }

  // Copiar usuario modificando campos específicos
  UserModel copyWith({
    String? uid,
    String? nombre,
    String? apellido,
    String? email,
    String? telefono,
    String? fechaNacimiento,
    String? genero,
    String? rol,
    String? fotoPerfil,
    String? especialidad,
    String? cedula,
    bool? activo,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      genero: genero ?? this.genero,
      rol: rol ?? this.rol,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      especialidad: especialidad ?? this.especialidad,
      cedula: cedula ?? this.cedula,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Nombre completo del usuario
  String get nombreCompleto {
    return "$nombre $apellido";
  }
}
