import 'package:cloud_firestore/cloud_firestore.dart';

enum Papel { admin, vendedor }

Papel _papelFromString(String? s) {
  return Papel.values.firstWhere(
    (p) => p.name == s,
    orElse: () => Papel.vendedor,
  );
}

/// Usuário autenticado. Carregado em `usuarios/{uid}` após login.
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

  factory Usuario.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Usuario(
      uid: doc.id,
      nome: (d['nome'] ?? '') as String,
      email: (d['email'] ?? '') as String,
      empresaId: (d['empresaId'] ?? '') as String,
      papel: _papelFromString(d['papel'] as String?),
      criadoEm: (d['criadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'nome': nome,
        'email': email,
        'empresaId': empresaId,
        'papel': papel.name,
        'criadoEm': Timestamp.fromDate(criadoEm),
      };

  /// Iniciais para avatar (até 2 letras).
  String get iniciais {
    final parts = nome.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
