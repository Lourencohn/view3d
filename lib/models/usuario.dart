enum Papel { admin, vendedor }

Papel _papelFromString(String? s) {
  return Papel.values.firstWhere(
    (p) => p.name == s,
    orElse: () => Papel.vendedor,
  );
}

class Usuario {
  final String uid;
  final String nome;
  final String email;
  final String empresaId;
  final Papel papel;
  final DateTime criadoEm;

  const Usuario({
    required this.uid,
    required this.nome,
    required this.email,
    required this.empresaId,
    required this.papel,
    required this.criadoEm,
  });

  bool get isAdmin => papel == Papel.admin;

  factory Usuario.fromJson(Map<String, dynamic> j) => Usuario(
        uid: j['id'] as String,
        nome: (j['nome'] ?? '') as String,
        email: (j['email'] ?? '') as String,
        empresaId: (j['empresa_id'] ?? '') as String,
        papel: _papelFromString(j['papel'] as String?),
        criadoEm: DateTime.tryParse((j['criado_em'] ?? '') as String) ??
            DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': uid,
        'nome': nome,
        'email': email,
        'empresa_id': empresaId,
        'papel': papel.name,
      };

  String get iniciais {
    final parts = nome.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
