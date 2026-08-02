class Validators {
  // Validar campos vacíos
  static String? required(String? value, {String field = "Campo"}) {
    if (value == null || value.trim().isEmpty) {
      return "$field es obligatorio";
    }

    return null;
  }

  // Validar correo electrónico
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "El correo es obligatorio";
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(value.trim())) {
      return "Ingresa un correo válido";
    }

    return null;
  }

  // Validar contraseña
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return "La contraseña es obligatoria";
    }

    if (value.length < 8) {
      return "La contraseña debe tener mínimo 8 caracteres";
    }

    return null;
  }

  // Confirmar contraseña
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return "Confirma tu contraseña";
    }

    if (value != password) {
      return "Las contraseñas no coinciden";
    }

    return null;
  }

  // Validar nombre
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "El nombre es obligatorio";
    }

    if (value.trim().length < 3) {
      return "El nombre debe tener mínimo 3 caracteres";
    }

    return null;
  }

  // Validar teléfono
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "El teléfono es obligatorio";
    }

    final phoneRegex = RegExp(r'^[0-9]{10}$');

    if (!phoneRegex.hasMatch(value.trim())) {
      return "Ingresa un teléfono válido";
    }

    return null;
  }

  // Validar código de verificación
  static String? verificationCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "El código es obligatorio";
    }

    if (value.length != 6) {
      return "El código debe tener 6 dígitos";
    }

    return null;
  }

  // Validar fecha
  static String? date(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Selecciona una fecha";
    }

    return null;
  }

  // Validar hora
  static String? time(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Selecciona una hora";
    }

    return null;
  }
}
