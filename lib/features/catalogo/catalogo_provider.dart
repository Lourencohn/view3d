import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/produto.dart';
import '../auth/auth_provider.dart';

/// Stream dos produtos da empresa do usuário logado.
/// Filtra por `empresa_id` (multi-tenancy) e `ativo == true` (cliente-side
/// porque o realtime stream do Supabase aceita um único filter eq).
final produtosProvider = StreamProvider<List<Produto>>((ref) {
  final auth = ref.watch(authStateProvider);
  final client = ref.watch(supabaseClientProvider);

  if (auth is! AuthSignedIn) return Stream.value(const []);

  return client
      .from('produtos')
      .stream(primaryKey: ['id'])
      .eq('empresa_id', auth.usuario.empresaId)
      .order('criado_em', ascending: false)
      .map((rows) => rows
          .where((r) => r['ativo'] == true)
          .map(Produto.fromJson)
          .toList());
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
  final client = ref.watch(supabaseClientProvider);
  return client
      .from('produtos')
      .stream(primaryKey: ['id'])
      .eq('id', id)
      .map((rows) => rows.isEmpty ? null : Produto.fromJson(rows.first));
});
