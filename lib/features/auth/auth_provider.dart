import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/usuario.dart';

/// Cliente Supabase compartilhado.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Stream interno do Supabase Auth (eventos signIn/signOut/refresh).
final _authChangesProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseClientProvider).auth.onAuthStateChange;
});

/// Sessão atual — começa pelo cache (currentSession) e reage ao stream.
final sessionProvider = Provider<Session?>((ref) {
  final stream = ref.watch(_authChangesProvider);
  return stream.maybeWhen(
    data: (s) => s.session,
    orElse: () => ref.watch(supabaseClientProvider).auth.currentSession,
  );
});

/// Perfil do usuário logado — `public.profiles` linkado a `auth.users`.
final usuarioProvider = FutureProvider<Usuario?>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session == null) return null;
  final client = ref.watch(supabaseClientProvider);
  final user = session.user;

  final row = await client
      .from('profiles')
      .select()
      .eq('id', user.id)
      .maybeSingle();
  if (row == null) return null;
  return Usuario.fromJson({
    ...row,
    'id': user.id,
    'email': user.email ?? row['email'] ?? '',
  });
});

/// Estado consolidado de auth — consumido pelo router e telas.
sealed class AppAuthState {
  const AppAuthState();
}

class AuthLoading extends AppAuthState {
  const AuthLoading();
}

class AuthSignedOut extends AppAuthState {
  const AuthSignedOut();
}

class AuthSignedIn extends AppAuthState {
  final Usuario usuario;
  const AuthSignedIn(this.usuario);
}

final authStateProvider = Provider<AppAuthState>((ref) {
  final authStream = ref.watch(_authChangesProvider);
  final session = ref.watch(sessionProvider);

  if (session == null) {
    return authStream.maybeWhen(
      loading: () => const AuthLoading(),
      orElse: () => const AuthSignedOut(),
    );
  }

  final usuario = ref.watch(usuarioProvider);
  return usuario.when(
    loading: () => const AuthLoading(),
    error: (_, __) => const AuthSignedOut(),
    data: (u) => u == null ? const AuthLoading() : AuthSignedIn(u),
  );
});

class AuthController {
  AuthController(this._client);
  final SupabaseClient _client;

  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } on AuthException catch (e) {
      throw AuthFailure.fromMessage(e.message);
    }
  }

  Future<void> signOut() => _client.auth.signOut();
}

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref.watch(supabaseClientProvider));
});

class AuthFailure implements Exception {
  final String message;
  AuthFailure(this.message);

  factory AuthFailure.fromMessage(String raw) {
    final m = raw.toLowerCase();
    if (m.contains('invalid login') ||
        m.contains('invalid_credentials') ||
        m.contains('invalid credentials')) {
      return AuthFailure('E-mail ou senha incorretos.');
    }
    if (m.contains('email not confirmed')) {
      return AuthFailure(
          'E-mail não confirmado. Verifique sua caixa de entrada.');
    }
    if (m.contains('rate limit') || m.contains('too many')) {
      return AuthFailure(
          'Muitas tentativas. Aguarde um momento e tente de novo.');
    }
    if (m.contains('network') || m.contains('failed to connect')) {
      return AuthFailure(
          'Sem conexão. Verifique sua internet e tente de novo.');
    }
    return AuthFailure(raw);
  }

  @override
  String toString() => message;
}
