import 'package:cloud_firestore/cloud_firestore.dart';

/// Empresa (tenant). Toda query de produtos DEVE filtrar por [id] da empresa.
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

  factory Empresa.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Empresa(
      id: doc.id,
      nome: (d['nome'] ?? '') as String,
      cnpj: (d['cnpj'] ?? '') as String,
      ativo: (d['ativo'] ?? true) as bool,
      criadoEm: (d['criadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'nome': nome,
        'cnpj': cnpj,
        'ativo': ativo,
        'criadoEm': Timestamp.fromDate(criadoEm),
      };
}
