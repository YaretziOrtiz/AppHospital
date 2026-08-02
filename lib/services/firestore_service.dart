import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import '../models/appointment_model.dart';
import '../models/medical_record_model.dart';
import '../models/prescription_model.dart';

import '../utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================================
  // USUARIOS
  // ================================

  // Obtener usuario por UID
  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (!doc.exists) {
        return null;
      }

      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception("Error obteniendo usuario: $e");
    }
  }

  // Actualizar usuario
  Future<void> updateUser(UserModel user) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .update(user.toMap());
  }

  // ================================
  // CITAS MÉDICAS
  // ================================

  // Crear cita
  Future<void> createAppointment(AppointmentModel appointment) async {
    await _firestore
        .collection(AppConstants.appointmentsCollection)
        .doc(appointment.appointmentId)
        .set(appointment.toMap());
  }

  // Obtener citas del paciente
  Stream<List<AppointmentModel>> getPatientAppointments(String uidPaciente) {
    return _firestore
        .collection(AppConstants.appointmentsCollection)
        .where("uidPaciente", isEqualTo: uidPaciente)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => AppointmentModel.fromMap(doc.data()))
              .toList();
        });
  }

  // Actualizar cita
  Future<void> updateAppointment(AppointmentModel appointment) async {
    await _firestore
        .collection(AppConstants.appointmentsCollection)
        .doc(appointment.appointmentId)
        .update(appointment.toMap());
  }

  // Eliminar cita
  Future<void> deleteAppointment(String appointmentId) async {
    await _firestore
        .collection(AppConstants.appointmentsCollection)
        .doc(appointmentId)
        .delete();
  }

  // ================================
  // EXPEDIENTES MÉDICOS
  // ================================

  // Crear expediente
  Future<void> createMedicalRecord(MedicalRecordModel record) async {
    await _firestore
        .collection(AppConstants.medicalRecordsCollection)
        .doc(record.recordId)
        .set(record.toMap());
  }

  // Obtener expediente del paciente
  Stream<List<MedicalRecordModel>> getMedicalRecords(String uidPaciente) {
    return _firestore
        .collection(AppConstants.medicalRecordsCollection)
        .where("uidPaciente", isEqualTo: uidPaciente)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MedicalRecordModel.fromMap(doc.data()))
              .toList();
        });
  }

  // ================================
  // RECETAS MÉDICAS
  // ================================

  // Crear receta
  Future<void> createPrescription(PrescriptionModel prescription) async {
    await _firestore
        .collection(AppConstants.prescriptionsCollection)
        .doc(prescription.prescriptionId)
        .set(prescription.toMap());
  }

  // Obtener recetas del paciente
  Stream<List<PrescriptionModel>> getPatientPrescriptions(String uidPaciente) {
    return _firestore
        .collection(AppConstants.prescriptionsCollection)
        .where("uidPaciente", isEqualTo: uidPaciente)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => PrescriptionModel.fromMap(doc.data()))
              .toList();
        });
  }

  // Actualizar receta
  Future<void> updatePrescription(PrescriptionModel prescription) async {
    await _firestore
        .collection(AppConstants.prescriptionsCollection)
        .doc(prescription.prescriptionId)
        .update(prescription.toMap());
  }

  // ================================
  // NOTIFICACIONES
  // ================================

  // Crear notificación
  Future<void> createNotification({
    required String notificationId,
    required String uidPaciente,
    required String titulo,
    required String mensaje,
    required String tipo,
  }) async {
    await _firestore
        .collection(AppConstants.notificationsCollection)
        .doc(notificationId)
        .set({
          "notificationId": notificationId,

          "uidPaciente": uidPaciente,

          "titulo": titulo,

          "mensaje": mensaje,

          "tipo": tipo,

          "leida": false,

          "createdAt": DateTime.now(),
        });
  }

  // Marcar notificación como leída
  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore
        .collection(AppConstants.notificationsCollection)
        .doc(notificationId)
        .update({"leida": true});
  }
}
