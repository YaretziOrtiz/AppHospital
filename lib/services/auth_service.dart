import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;

  // Registro de usuario
  Future<User?> register(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print("Usuario registrado");
      print("UID Firebase Auth: ${result.user!.uid}");
      print("Correo: ${result.user!.email}");

      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Error al registrar usuario");
    }
  }

  // Inicio de sesión
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      print("==========================");
      print("LOGIN CORRECTO");
      print("UID Firebase Auth: ${result.user!.uid}");
      print("Correo: ${result.user!.email}");
      print("==========================");

      return result.user;
    } on FirebaseAuthException catch (e) {
      print("ERROR FIREBASE AUTH");
      print(e.code);
      print(e.message);

      throw Exception(e.message ?? "Error al iniciar sesión");
    }
  }

  // Enviar correo de verificación
  Future<void> sendEmailVerification() async {
    User? user = _auth.currentUser;

    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();

      print("Correo de verificación enviado a ${user.email}");
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();

    print("Sesión cerrada");
  }
}
