class AppConstants {
  // Nombre de la aplicación
  static const String appName = "MedLink";

  // Información general
  static const String appVersion = "1.0.0";

  // Firebase Collections
  static const String usersCollection = "users";
  static const String appointmentsCollection = "appointments";
  static const String medicalRecordsCollection = "medical_records";
  static const String prescriptionsCollection = "prescriptions";
  static const String notificationsCollection = "notifications";
  static const String specialtiesCollection = "specialties";


  // Roles de usuario
  static const String patientRole = "patient";
  static const String doctorRole = "doctor";
  static const String adminRole = "admin";


  // Estados de citas
  static const String appointmentPending = "pending";
  static const String appointmentConfirmed = "confirmed";
  static const String appointmentCompleted = "completed";
  static const String appointmentCancelled = "cancelled";


  // Tipos de notificaciones
  static const String notificationAppointment = "appointment";
  static const String notificationReminder = "reminder";
  static const String notificationSystem = "system";


  // Mensajes generales
  static const String errorMessage =
      "Ocurrió un error, intenta nuevamente.";

  static const String connectionError =
      "No hay conexión a internet.";

  static const String requiredField =
      "Este campo es obligatorio.";


  // Duraciones de animaciones
  static const Duration animationDuration =
      Duration(milliseconds: 300);

  static const Duration splashDuration =
      Duration(seconds: 2);


  // Tamaños generales de UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  static const double borderRadius = 12.0;
  static const double cardElevation = 3.0;


  // Límites
  static const int verificationCodeLength = 6;

  static const int maxNameLength = 50;

  static const int maxDescriptionLength = 250;
}