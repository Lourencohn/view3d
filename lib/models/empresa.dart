/// Empresa (tenant). Toda query de produtos filtra por [id] da empresa.
class Empresa {
  final String id;
  final String nome;
  final String cnpj;
  final bool ativo;
  final DateTime criadoEm;

  const Empresa({
    required this.id,
    required this.nome,
    required this.cnpj,
    required this.ativo,
    required this.criadoEm,
  });

  factory Empresa.fromJson(Map<String, dynamic> j) => Empresa(
        id: j['id'] as String,
        nome: (j['nome'] ?? '') as String,
        cnpj: (j['cnpj'] ?? '') as String,
        ativo: (j['ativo'] ?? true) as bool,
        criadoEm: DateTime.tryParse((j['criado_em'] ?? '') as String) ??
            DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'cnpj': cnpj,
        'ativo': ativo,
      };
}
