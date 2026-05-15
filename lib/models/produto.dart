import 'package:cloud_firestore/cloud_firestore.dart';

/// Produto 3D — metadados + URL pública do GLB.
class Produto {
  final String id;
  final String nome;
  final String descricao;
  final String categoria;
  final String empresaId;

  /// URL pública do arquivo .glb no Firebase Storage.
  final String glbUrl;

  /// URL pública da página do viewer (compartilhável):
  /// `https://viewer.showcas3d.app/v/{id}`
  final String viewerUrl;

  /// Opcional — URL de thumbnail PNG/JPG. Se nulo, a UI mostra placeholder.
  final String? thumbUrl;

  final bool ativo;
  final DateTime criadoEm;

  // Campos opcionais usados na UI; expandir conforme catálogo evolui.
  final String? sku;
  final String? cor;
  final String? dimensoes;
  final String? peso;
  final String? materiais;
  final String? preco;

  const Produto({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.categoria,
    required this.empresaId,
    required this.glbUrl,
    required this.viewerUrl,
    required this.ativo,
    required this.criadoEm,
    this.thumbUrl,
    this.sku,
    this.cor,
    this.dimensoes,
    this.peso,
    this.materiais,
    this.preco,
  });

  factory Produto.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Produto(
      id: doc.id,
      nome: (d['nome'] ?? '') as String,
      descricao: (d['descricao'] ?? '') as String,
      categoria: (d['categoria'] ?? 'Outros') as String,
      empresaId: (d['empresaId'] ?? '') as String,
      glbUrl: (d['glbUrl'] ?? '') as String,
      viewerUrl: (d['viewerUrl'] ?? '') as String,
      thumbUrl: d['thumbUrl'] as String?,
      ativo: (d['ativo'] ?? true) as bool,
      criadoEm: (d['criadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
      sku: d['sku'] as String?,
      cor: d['cor'] as String?,
      dimensoes: d['dimensoes'] as String?,
      peso: d['peso'] as String?,
      materiais: d['materiais'] as String?,
      preco: d['preco'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'nome': nome,
        'descricao': descricao,
        'categoria': categoria,
        'empresaId': empresaId,
        'glbUrl': glbUrl,
        'viewerUrl': viewerUrl,
        if (thumbUrl != null) 'thumbUrl': thumbUrl,
        'ativo': ativo,
        'criadoEm': Timestamp.fromDate(criadoEm),
        if (sku != null) 'sku': sku,
        if (cor != null) 'cor': cor,
        if (dimensoes != null) 'dimensoes': dimensoes,
        if (peso != null) 'peso': peso,
        if (materiais != null) 'materiais': materiais,
        if (preco != null) 'preco': preco,
      };
}

const kCategorias = <String>[
  'Calçados',
  'Vestuário',
  'Acessórios',
  'Móveis',
  'Decoração',
  'Eletro',
  'Outros',
];
