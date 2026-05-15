import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/produto.dart';
import '../auth/auth_provider.dart';

/// Stream dos produtos ativos da empresa do usuário logado.
/// Filtra por `empresaId` (multi-tenancy obrigatória) + `ativo == true`.
final produtosProvider = StreamProvider<List<Produto>>((ref) {
  final auth = ref.watch(authStateProvider);
  final db = ref.watch(firestoreProvider);

  if (auth is! AuthSignedIn) return Stream.value(const []);

  return db
      .collection('produtos')
      .where('empresaId', isEqualTo: auth.usuario.empresaId)
      .where('ativo', isEqualTo: true)
      .orderBy('criadoEm', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(Produto.fromFirestore).toList());
});

/// Filtro por categoria — driver do que aparece no catálogo.
final categoriaFilterProvider = StateProvider<String?>((ref) => null);

/// Lista final aplicando o filtro.
final produtosFiltradosProvider = Provider<AsyncValue<List<Produto>>>((ref) {
  final produtos = ref.watch(produtosProvider);
  final cat = ref.watch(categoriaFilterProvider);

  return produtos.whenData((list) {
    if (cat == null || cat.isEmpty) return list;
    return list.where((p) => p.categoria == cat).toList();
  });
});

/// Produto específico por id — usado nas telas de detalhe / QR.
final produtoByIdProvider =
    StreamProvider.family<Produto?, String>((ref, id) {
  final db = ref.watch(firestoreProvider);
  return db.collection('produtos').doc(id).snapshots().map(
        (doc) => doc.exists ? Produto.fromFirestore(doc) : null,
      );
});
