import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/usuario.dart';

/// Estado de autenticação consumido em todo o app.
///
/// - [firebaseUserProvider] expõe o stream de FirebaseAuth
/// - [usuarioProvider] carrega o documento `usuarios/{uid}` correspondente
/// - [authStateProvider] devolve um AuthState consolidado (estado + usuário)
/// - [authControllerProvider] expõe ações: signIn, signOut

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Stream do usuário do Firebase (User?).
final firebaseUserProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

/// Carrega o documento `usuarios/{uid}` quando há sessão.
final usuarioProvider = StreamProvider<Usuario?>((ref) {
  final userAsync = ref.watch(firebaseUserProvider);
  final db = ref.watch(firestoreProvider);

  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return db
          .collection('usuarios')
          .doc(user.uid)
          .snapshots()
          .map((doc) => doc.exists ? Usuario.fromFirestore(doc) : null);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => Stream.value(null),
  );
});

/// Estado consolidado: 'loading' enquanto carrega o doc do usuário,
/// 'signedOut' se não tem sessão, 'signedIn' com usuário pronto.
sealed class AuthState {
  const AuthState();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSignedOut extends AuthState {
  const AuthSignedOut();
}

class AuthSignedIn extends AuthState {
  final Usuario usuario;
  const AuthSignedIn(this.usuario);
}

final authStateProvider = Provider<AuthState>((ref) {
  final user = ref.watch(firebaseUserProvider);
  final usuario = ref.watch(usuarioProvider);

  return user.when(
    loading: () => const AuthLoading(),
    error: (_, __) => const AuthSignedOut(),
    data: (u) {
      if (u == null) return const AuthSignedOut();
      return usuario.when(
        loading: () => const AuthLoading(),
        error: (_, __) => const AuthSignedOut(),
        data: (doc) =>
            doc == null ? const AuthLoading() : AuthSignedIn(doc),
      );
    },
  );
});

class AuthController {
  AuthController(this._auth);
  final FirebaseAuth _auth;

  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromCode(e.code, e.message);
    }
  }

  Future<void> signOut() => _auth.signOut();
}

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref.watch(firebaseAuthProvider));
});

class AuthFailure implements Exception {
  final String code;
  final String message;
  AuthFailure(this.code, this.message);

  factory AuthFailure.fromCode(String code, String? raw) {
    switch (code) {
      case 'invalid-email':
        return AuthFailure(code, 'E-mail inválido.');
      case 'user-disabled':
        return AuthFailure(code, 'Conta desativada. Procure o administrador.');
      case 'user-not-found':
      case 'invalid-credential':
      case 'wrong-password':
        return AuthFailure(code, 'E-mail ou senha incorretos.');
      case 'too-many-requests':
        return AuthFailure(
          code,
          'Muitas tentativas. Aguarde um momento e tente de novo.',
        );
      case 'network-request-failed':
        return AuthFailure(
          code,
          'Sem conexão. Verifique sua internet e tente de novo.',
        );
      default:
        return AuthFailure(code, raw ?? 'Não foi possível entrar.');
    }
  }

  @override
  String toString() => message;
}
