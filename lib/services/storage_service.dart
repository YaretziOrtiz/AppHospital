import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ================================
  // SUBIR IMAGEN DE PERFIL
  // ================================

  Future<String?> uploadProfileImage({
    required String uid,
    required File image,
  }) async {
    try {
      Reference reference = _storage.ref().child("profile_images/$uid.jpg");

      UploadTask uploadTask = reference.putFile(image);

      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception("Error subiendo imagen: $e");
    }
  }

  // ================================
  // SUBIR DOCUMENTOS MÉDICOS
  // ================================

  Future<String?> uploadMedicalDocument({
    required String uidPaciente,
    required File file,
    required String fileName,
  }) async {
    try {
      Reference reference = _storage.ref().child(
        "medical_documents/$uidPaciente/$fileName",
      );

      UploadTask uploadTask = reference.putFile(file);

      TaskSnapshot snapshot = await uploadTask;

      String url = await snapshot.ref.getDownloadURL();

      return url;
    } catch (e) {
      throw Exception("Error subiendo documento: $e");
    }
  }

  // ================================
  // ELIMINAR ARCHIVO
  // ================================

  Future<void> deleteFile(String url) async {
    try {
      Reference reference = _storage.refFromURL(url);

      await reference.delete();
    } catch (e) {
      throw Exception("Error eliminando archivo: $e");
    }
  }

  // ================================
  // OBTENER URL DE ARCHIVO
  // ================================

  Future<String?> getFileUrl(String path) async {
    try {
      Reference reference = _storage.ref(path);

      String url = await reference.getDownloadURL();

      return url;
    } catch (e) {
      return null;
    }
  }
}
