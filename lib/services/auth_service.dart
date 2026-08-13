import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    }
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser {
    return _auth.currentUser;
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Este correo ya está registrado.';

      case 'invalid-email':
        return 'El correo electrónico no es válido.';

      case 'weak-password':
        return 'La contraseña es demasiado débil.';

      case 'user-not-found':
        return 'No existe una cuenta con este correo.';

      case 'wrong-password':
        return 'La contraseña es incorrecta.';

      case 'invalid-credential':
        return 'El correo o la contraseña son incorrectos.';

      case 'user-disabled':
        return 'Esta cuenta está deshabilitada.';

      case 'too-many-requests':
        return 'Demasiados intentos. Intenta nuevamente más tarde.';

      default:
        return 'Ocurrió un error. Intenta nuevamente.';
    }
  }
}
