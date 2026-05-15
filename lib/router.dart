import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/catalogo/catalogo_screen.dart';
import 'features/produto/detalhe_screen.dart';
import 'features/produto/qr_screen.dart';
import 'shared/widgets/loading_widget.dart';

/// Roteamento do app — redireciona baseado no estado de autenticação.
///
/// Provider exposto: `appRouterProvider`. Use-o em MaterialApp.router.
final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterRefresh(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      final loc = state.matchedLocation;
      final atLogin = loc == '/login';
      final atSplash = loc == '/';

      if (auth is AuthLoading) {
        // Mantém na splash enquanto carrega.
        return atSplash ? null : '/';
      }
      if (auth is AuthSignedOut) {
        return atLogin ? null : '/login';
      }
      if (auth is AuthSignedIn) {
        if (atLogin || atSplash) return '/catalogo';
        return null;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const _SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/catalogo',
        builder: (_, __) => const CatalogoScreen(),
        routes: [
          // Mantemos /produto/:id como rota top-level também por
          // praticidade de deep-linking.
        ],
      ),
      GoRoute(
        path: '/produto/:id',
        builder: (_, state) => DetalheScreen(
          produtoId: state.pathParameters['id']!,
        ),
        routes: [
          GoRoute(
            path: 'qr',
            builder: (_, state) => QrScreen(
              produtoId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
    ],
  );
});

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LoadingWidget(message: 'Carregando…'),
    );
  }
}

/// Adapta o `authStateProvider` em `Listenable` para o GoRouter recarregar
/// as rotas quando o estado muda.
class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(this._ref) {
    _ref.listen<AuthState>(authStateProvider, (_, __) => notifyListeners());
  }
  // ignore: unused_field
  final Ref _ref;
}
