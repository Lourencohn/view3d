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

  int get colorHex => switch (this) {
        Canal.whatsapp => 0xFF25D366,
        Canal.email    => 0xFF0A84FF,
        Canal.qr       => 0xFFE8513A,
        Canal.link     => 0xFF1A1815,
        Canal.sistema  => 0xFF8A857A,
      };
}

/// Evento de compartilhamento — persistido em `compartilhamentos`
/// (por enquanto a tela usa mock; trocar quando o ShareSheet gravar de fato).
class Compartilhamento {
  final String id;
  final String produtoId;
  final String empresaId;
  final String uid;
  final Canal canal;
  final String? comprador;
  final String? contato;
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

  factory Compartilhamento.fromJson(Map<String, dynamic> j) => Compartilhamento(
        id: j['id'] as String,
        produtoId: (j['produto_id'] ?? '') as String,
        empresaId: (j['empresa_id'] ?? '') as String,
        uid: (j['uid'] ?? '') as String,
        canal: _canalFromString(j['canal'] as String?),
        comprador: j['comprador'] as String?,
        contato: j['contato'] as String?,
        dataHora: DateTime.tryParse((j['data_hora'] ?? '') as String) ??
            DateTime.now(),
        views: (j['views'] ?? 0) as int,
        arSessions: (j['ar_sessions'] ?? 0) as int,
        ultimoAcesso: j['ultimo_acesso'] != null
            ? DateTime.tryParse(j['ultimo_acesso'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'produto_id': produtoId,
        'empresa_id': empresaId,
        'uid': uid,
        'canal': canal.name,
        if (comprador != null) 'comprador': comprador,
        if (contato != null) 'contato': contato,
        'data_hora': dataHora.toIso8601String(),
        'views': views,
        'ar_sessions': arSessions,
        if (ultimoAcesso != null)
          'ultimo_acesso': ultimoAcesso!.toIso8601String(),
      };
}

/// Snapshot agregado dos últimos 7 dias para a tela "Insights" (mock).
class InsightsSnapshot {
  final int views7d;
  final double views7dDelta;
  final int uniqueBuyers;
  final double uniqueBuyersDelta;
  final int arSessions;
  final double arSessionsDelta;
  final int avgTimeSec;
  final double avgTimeDelta;
  final List<int> viewsSeries;
  final List<TopProduto> topProdutos;
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
