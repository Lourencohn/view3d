import 'package:cloud_firestore/cloud_firestore.dart';

enum Canal { whatsapp, email, qr, link, sistema }

Canal _canalFromString(String? s) {
  return Canal.values.firstWhere(
    (c) => c.name == s,
    orElse: () => Canal.link,
  );
}

extension CanalX on Canal {
  String get label => switch (this) {
        Canal.whatsapp => 'WhatsApp',
        Canal.email    => 'E-mail',
        Canal.qr       => 'QR Code',
        Canal.link     => 'Link',
        Canal.sistema  => 'Sistema',
      };

  /// Cor para o pin/chip da UI.
  int get colorHex => switch (this) {
        Canal.whatsapp => 0xFF25D366,
        Canal.email    => 0xFF0A84FF,
        Canal.qr       => 0xFFE8513A,
        Canal.link     => 0xFF1A1815,
        Canal.sistema  => 0xFF8A857A,
      };
}

/// Um evento de compartilhamento — alimenta a tela "Compartilhados" e os
/// insights. Persistido em `compartilhamentos/{id}` (criar essa coleção
/// no Firestore quando for hora; por enquanto vem de mock).
class Compartilhamento {
  final String id;
  final String produtoId;
  final String empresaId;
  final String uid;           // vendedor que compartilhou
  final Canal canal;
  final String? comprador;    // nome amigável (opcional)
  final String? contato;      // telefone, email, etc (opcional)
  final DateTime dataHora;
  final int views;
  final int arSessions;
  final DateTime? ultimoAcesso;

  const Compartilhamento({
    required this.id,
    required this.produtoId,
    required this.empresaId,
    required this.uid,
    required this.canal,
    required this.dataHora,
    required this.views,
    required this.arSessions,
    this.comprador,
    this.contato,
    this.ultimoAcesso,
  });

  factory Compartilhamento.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    return Compartilhamento(
      id: doc.id,
      produtoId: (d['produtoId'] ?? '') as String,
      empresaId: (d['empresaId'] ?? '') as String,
      uid: (d['uid'] ?? '') as String,
      canal: _canalFromString(d['canal'] as String?),
      comprador: d['comprador'] as String?,
      contato: d['contato'] as String?,
      dataHora: (d['dataHora'] as Timestamp?)?.toDate() ?? DateTime.now(),
      views: (d['views'] ?? 0) as int,
      arSessions: (d['arSessions'] ?? 0) as int,
      ultimoAcesso: (d['ultimoAcesso'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'produtoId': produtoId,
        'empresaId': empresaId,
        'uid': uid,
        'canal': canal.name,
        if (comprador != null) 'comprador': comprador,
        if (contato != null) 'contato': contato,
        'dataHora': Timestamp.fromDate(dataHora),
        'views': views,
        'arSessions': arSessions,
        if (ultimoAcesso != null)
          'ultimoAcesso': Timestamp.fromDate(ultimoAcesso!),
      };
}

/// Snapshot agregado de métricas dos últimos 7 dias para a tela "Insights".
/// No futuro: gerado por Cloud Function diária em `insights/{empresaId}`.
class InsightsSnapshot {
  final int views7d;
  final double views7dDelta;
  final int uniqueBuyers;
  final double uniqueBuyersDelta;
  final int arSessions;
  final double arSessionsDelta;
  final int avgTimeSec;
  final double avgTimeDelta;

  /// 7 valores — mais antigo → mais recente.
  final List<int> viewsSeries;

  /// Lista ordenada por views desc — id → contagens.
  final List<TopProduto> topProdutos;

  /// Map canal.name → fração 0..1
  final Map<String, double> canais;

  const InsightsSnapshot({
    required this.views7d,
    required this.views7dDelta,
    required this.uniqueBuyers,
    required this.uniqueBuyersDelta,
    required this.arSessions,
    required this.arSessionsDelta,
    required this.avgTimeSec,
    required this.avgTimeDelta,
    required this.viewsSeries,
    required this.topProdutos,
    required this.canais,
  });
}

class TopProduto {
  final String produtoId;
  final int views;
  final int arSessions;
  const TopProduto({
    required this.produtoId,
    required this.views,
    required this.arSessions,
  });
}
