import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/catalogo/catalogo_screen.dart';
import 'features/compartilhados/compartilhados_screen.dart';
import 'features/conta/conta_screen.dart';
import 'features/home/home_shell.dart';
import 'features/insights/insights_screen.dart';
import 'features/produto/detalhe_screen.dart';
import 'features/produto/qr_screen.dart';
import 'shared/widgets/loading_widget.dart';

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
      GoRoute(path: '/', builder: (_, __) => const _SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/catalogo',
              builder: (_, __) => const CatalogoScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/compartilhados',
              builder: (_, __) => const CompartilhadosScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/insights',
              builder: (_, __) => const InsightsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/conta',
              builder: (_, __) => const ContaScreen(),
            ),
          ]),
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

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    ref.listen<AppAuthState>(authStateProvider, (_, __) => notifyListeners());
  }
}
