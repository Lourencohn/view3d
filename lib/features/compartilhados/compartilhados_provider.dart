import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/compartilhamento.dart';
import '../auth/auth_provider.dart';

/// Lista de compartilhamentos do vendedor logado.
///
/// TODO: trocar pelo stream real:
/// ```
/// db.collection('compartilhamentos')
///   .where('empresaId', isEqualTo: usuario.empresaId)
///   .where('uid', isEqualTo: usuario.uid)
///   .orderBy('dataHora', descending: true)
///   .snapshots()
/// ```
/// Por enquanto retorna dados mock — ver `_mockShares()`.
final compartilhamentosProvider =
    FutureProvider<List<Compartilhamento>>((ref) async {
  final auth = ref.watch(authStateProvider);
  if (auth is! AuthSignedIn) return const [];

  // Simula latência de rede leve para a UI mostrar loading uma vez.
  await Future<void>.delayed(const Duration(milliseconds: 120));
  return _mockShares(uid: auth.usuario.uid, empresaId: auth.usuario.empresaId);
});

/// Filtro por canal (null = todos).
final canalFilterProvider = StateProvider<Canal?>((ref) => null);

final compartilhamentosFiltradosProvider =
    Provider<AsyncValue<List<Compartilhamento>>>((ref) {
  final all = ref.watch(compartilhamentosProvider);
  final canal = ref.watch(canalFilterProvider);
  return all.whenData((list) {
    if (canal == null) return list;
    return list.where((c) => c.canal == canal).toList();
  });
});

// ─────────────────────────────────────────────────────────
// Mock — substituir por Firestore quando coleção existir
// ─────────────────────────────────────────────────────────
List<Compartilhamento> _mockShares({
  required String uid,
  required String empresaId,
}) {
  final now = DateTime.now();
  DateTime mins(int n) => now.subtract(Duration(minutes: n));
  DateTime hours(int n) => now.subtract(Duration(hours: n));
  DateTime days(int n) => now.subtract(Duration(days: n));

  return [
    Compartilhamento(
      id: 's1', produtoId: 'plt-est-01', empresaId: empresaId, uid: uid,
      canal: Canal.whatsapp,
      comprador: 'Luísa · Studio Vermelho',
      contato: '+55 11 9 8870-4421',
      dataHora: mins(18), views: 7, arSessions: 2, ultimoAcesso: mins(4),
    ),
    Compartilhamento(
      id: 's2', produtoId: 'vso-atl-04', empresaId: empresaId, uid: uid,
      canal: Canal.whatsapp,
      comprador: 'Café Tigela',
      contato: '+55 21 9 9224-1108',
      dataHora: hours(3), views: 12, arSessions: 0, ultimoAcesso: hours(1),
    ),
    Compartilhamento(
      id: 's3', produtoId: 'plt-est-02', empresaId: empresaId, uid: uid,
      canal: Canal.email,
      comprador: 'Hotel Cardume',
      contato: 'compras@cardume.co',
      dataHora: hours(7), views: 4, arSessions: 1, ultimoAcesso: hours(6),
    ),
    Compartilhamento(
      id: 's4', produtoId: 'elt-vrt-12', empresaId: empresaId, uid: uid,
      canal: Canal.qr,
      contato: 'feira NRF',
      dataHora: days(1), views: 23, arSessions: 4, ultimoAcesso: hours(20),
    ),
    Compartilhamento(
      id: 's5', produtoId: 'vso-atl-05', empresaId: empresaId, uid: uid,
      canal: Canal.whatsapp,
      comprador: 'Pousada Maré',
      contato: '+55 71 9 9988-2230',
      dataHora: days(2), views: 9, arSessions: 0, ultimoAcesso: days(1),
    ),
    Compartilhamento(
      id: 's6', produtoId: 'plt-est-01', empresaId: empresaId, uid: uid,
      canal: Canal.link,
      comprador: 'Restaurante Olho de Boi',
      contato: 'olho-de-boi.com.br',
      dataHora: days(3), views: 18, arSessions: 3, ultimoAcesso: days(1),
    ),
    Compartilhamento(
      id: 's7', produtoId: 'col-trn-07', empresaId: empresaId, uid: uid,
      canal: Canal.email,
      comprador: 'Galeria Sub',
      contato: 'oi@galeria.sub',
      dataHora: days(5), views: 2, arSessions: 0, ultimoAcesso: days(5),
    ),
    Compartilhamento(
      id: 's8', produtoId: 'plt-est-01', empresaId: empresaId, uid: uid,
      canal: Canal.whatsapp,
      comprador: 'Atelier 14',
      contato: '+55 11 9 8830-6712',
      dataHora: days(6), views: 31, arSessions: 7, ultimoAcesso: days(2),
    ),
  ];
}
