/// Produto 3D — metadados + URL pública do GLB.
class Produto {
  final String id;
  final String nome;
  final String descricao;
  final String categoria;
  final String empresaId;

  /// URL pública do arquivo .glb (Supabase Storage ou externo).
  final String glbUrl;

  /// URL pública da página do viewer (compartilhável).
  final String viewerUrl;

  /// Opcional — URL de thumbnail PNG/JPG. Se nulo, a UI mostra placeholder.
  final String? thumbUrl;

  final bool ativo;
  final DateTime criadoEm;

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

  factory Produto.fromJson(Map<String, dynamic> j) => Produto(
        id: j['id'] as String,
        nome: (j['nome'] ?? '') as String,
        descricao: (j['descricao'] ?? '') as String,
        categoria: (j['categoria'] ?? 'Outros') as String,
        empresaId: (j['empresa_id'] ?? '') as String,
        glbUrl: (j['glb_url'] ?? '') as String,
        viewerUrl: (j['viewer_url'] ?? '') as String,
        thumbUrl: j['thumb_url'] as String?,
        ativo: (j['ativo'] ?? true) as bool,
        criadoEm:
            DateTime.tryParse((j['criado_em'] ?? '') as String) ?? DateTime.now(),
        sku: j['sku'] as String?,
        cor: j['cor'] as String?,
        dimensoes: j['dimensoes'] as String?,
        peso: j['peso'] as String?,
        materiais: j['materiais'] as String?,
        preco: j['preco'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'descricao': descricao,
        'categoria': categoria,
        'empresa_id': empresaId,
        'glb_url': glbUrl,
        'viewer_url': viewerUrl,
        if (thumbUrl != null) 'thumb_url': thumbUrl,
        'ativo': ativo,
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
