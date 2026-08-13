import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection {
    return _firestore.collection('users');
  }

  Future<void> createUserProfile(UserModel user) async {
    await _usersCollection.doc(user.uid).set(
          user.toMap(),
        );
  }

  Future<UserModel?> getUser(String uid) async {
    final document = await _usersCollection.doc(uid).get();

    if (!document.exists) {
      return null;
    }

    return UserModel.fromFirestore(document);
  }

  Stream<UserModel?> userStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((document) {
      if (!document.exists) {
        return null;
      }

      return UserModel.fromFirestore(document);
    });
  }

  Stream<List<UserModel>> getUsersStream() {
    return _usersCollection.orderBy('nombre').snapshots().map((snapshot) {
      return snapshot.docs
          .map((document) => UserModel.fromFirestore(document))
          .toList();
    });
  }

  Future<void> updateUser(UserModel user) async {
    await _usersCollection.doc(user.uid).update(
          user.toMap(),
        );
  }

  Future<void> updateUserRole(
    String uid,
    String role,
  ) async {
    await _usersCollection.doc(uid).update({
      'rol': role,
    });
  }

  Future<void> updateUserStatus(
    String uid,
    bool activo,
  ) async {
    await _usersCollection.doc(uid).update({
      'activo': activo,
    });
  }
}
