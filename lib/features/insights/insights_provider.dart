import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/compartilhamento.dart';
import '../auth/auth_provider.dart';

/// Métricas agregadas dos últimos 7 dias.
///
/// TODO: substituir pelo doc gerado por Cloud Function em
/// `insights/{empresaId}` (snapshot diário) — por enquanto mock.
final insightsProvider = FutureProvider<InsightsSnapshot>((ref) async {
  final auth = ref.watch(authStateProvider);
  if (auth is! AuthSignedIn) {
    throw StateError('Usuário não autenticado');
  }

  await Future<void>.delayed(const Duration(milliseconds: 180));
  return _mockInsights();
});

InsightsSnapshot _mockInsights() {
  return const InsightsSnapshot(
    views7d: 142,
    views7dDelta: 0.43,
    uniqueBuyers: 23,
    uniqueBuyersDelta: 0.21,
    arSessions: 31,
    arSessionsDelta: -0.08,
    avgTimeSec: 47,
    avgTimeDelta: 0.12,
    viewsSeries: [8, 14, 11, 22, 18, 32, 37],
    topProdutos: [
      TopProduto(produtoId: 'plt-est-01', views: 56, arSessions: 12),
      TopProduto(produtoId: 'vso-atl-04', views: 34, arSessions: 4),
      TopProduto(produtoId: 'elt-vrt-12', views: 23, arSessions: 4),
      TopProduto(produtoId: 'plt-est-02', views: 18, arSessions: 6),
      TopProduto(produtoId: 'vso-atl-05', views: 11, arSessions: 5),
    ],
    canais: {
      'whatsapp': 0.62,
      'email': 0.24,
      'qr': 0.09,
      'link': 0.05,
    },
  );
}
