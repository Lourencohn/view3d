import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/compartilhamento.dart';
import '../../models/produto.dart';
import '../../shared/widgets/app_error_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../theme.dart';
import '../catalogo/catalogo_provider.dart';
import 'compartilhados_provider.dart';

class CompartilhadosScreen extends ConsumerWidget {
  const CompartilhadosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compartilhados = ref.watch(compartilhamentosFiltradosProvider);
    final all = ref.watch(compartilhamentosProvider).asData?.value ?? const [];
    final filtro = ref.watch(canalFilterProvider);
    final produtos =
        ref.watch(produtosProvider).asData?.value ?? const <Produto>[];

    final totalViews = all.fold<int>(0, (a, s) => a + s.views);
    final totalAr = all.fold<int>(0, (a, s) => a + s.arSessions);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ATIVIDADE', style: AppText.caption),
                const SizedBox(height: 4),
                Text('Compartilhados', style: AppText.titleXL),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _Stat(value: '${all.length}', label: 'envios · 7 dias'),
                    const SizedBox(width: 22),
                    _Stat(value: '$totalViews', label: 'views'),
                    const SizedBox(width: 22),
                    _Stat(value: '$totalAr', label: 'AR', accent: true),
                  ],
                ),
              ],
            ),
          ),

          _CanalChips(active: filtro, ref: ref),

          Expanded(
            child: compartilhados.when(
              loading: () => const LoadingWidget(),
              error: (e, _) => AppErrorWidget(
                message: 'Não foi possível carregar.\n$e',
                onRetry: () => ref.invalidate(compartilhamentosProvider),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return const _EmptyState();
                }
                final grouped = _groupByDay(list);
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  children: grouped.entries.expand((entry) {
                    final bucket = entry.key;
                    final items = entry.value;
                    return [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
                        child: Text(
                          bucket.toUpperCase(),
                          style: AppText.caption,
                        ),
                      ),
                      ...items.map((s) => _ShareRow(
                            share: s,
                            produto: _findProduto(produtos, s.produtoId),
                            onTap: () =>
                                context.push('/produto/${s.produtoId}'),
                          )),
                      const SizedBox(height: 12),
                    ];
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Produto? _findProduto(List<Produto> all, String id) {
    try {
      return all.firstWhere((p) => p.id == id);
    } on StateError {
      return null;
    }
  }

  Map<String, List<Compartilhamento>> _groupByDay(
      List<Compartilhamento> list) {
    final out = <String, List<Compartilhamento>>{};
    for (final s in list) {
      final bucket = _dayBucket(s.dataHora);
      (out[bucket] ??= []).add(s);
    }
    return out;
  }

  String _dayBucket(DateTime d) {
    final today = DateTime.now();
    final t = DateTime(today.year, today.month, today.day);
    final target = DateTime(d.year, d.month, d.day);
    final diff = t.difference(target).inDays;
    if (diff == 0) return 'Hoje';
    if (diff == 1) return 'Ontem';
    if (diff < 7) return 'Esta semana';
    if (diff < 30) return 'Este mês';
    return 'Antes';
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.value,
    required this.label,
    this.accent = false,
  });
  final String value;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: accent ? AppTheme.accent : AppTheme.ink,
              fontFeatures: const [FontFeature.tabularFigures()],
            )),
        Text(label,
            style: TextStyle(fontSize: 11, color: AppTheme.ink3)),
      ],
    );
  }
}

class _CanalChips extends StatelessWidget {
  const _CanalChips({required this.active, required this.ref});
  final Canal? active;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final items = <(Canal?, String)>[
      (null, 'Todos'),
      (Canal.whatsapp, 'WhatsApp'),
      (Canal.email, 'E-mail'),
      (Canal.qr, 'QR'),
      (Canal.link, 'Link'),
    ];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (ctx, i) {
          final (canal, label) = items[i];
          final selected = canal == active;
          return GestureDetector(
            onTap: () =>
                ref.read(canalFilterProvider.notifier).state = canal,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: selected ? AppTheme.ink : AppTheme.bgMuted,
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? AppTheme.bgApp : AppTheme.ink2,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ShareRow extends StatelessWidget {
  const _ShareRow({
    required this.share,
    required this.onTap,
    this.produto,
  });
  final Compartilhamento share;
  final Produto? produto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final canalColor = Color(share.canal.colorHex);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                _MiniThumb(produto: produto),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        produto?.nome ?? 'Produto removido',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.1,
                          color: AppTheme.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: canalColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              share.comprador ??
                                  share.contato ??
                                  share.canal.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.ink3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('·',
                              style: TextStyle(
                                  fontSize: 12, color: AppTheme.ink4)),
                          const SizedBox(width: 6),
                          Text(
                            _relTime(share.dataHora),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.ink3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${share.views}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.ink,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text('VIEWS',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppTheme.ink3,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w500,
                        )),
                    if (share.arSessions > 0) ...[
                      const SizedBox(height: 2),
                      const Text('+AR',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.accent,
                            fontWeight: FontWeight.w500,
                          )),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniThumb extends StatelessWidget {
  const _MiniThumb({this.produto});
  final Produto? produto;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 56,
        height: 56,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (produto == null) {
      return _Fallback(
        letter: '?',
        tint: AppTheme.bgMuted,
        icon: Icons.broken_image_outlined,
      );
    }
    final p = produto!;
    if (p.thumbUrl != null && p.thumbUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: p.thumbUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) =>
            _Fallback(letter: _initial(p.nome), tint: _tintFor(p.categoria)),
        errorWidget: (_, __, ___) =>
            _Fallback(letter: _initial(p.nome), tint: _tintFor(p.categoria)),
      );
    }
    return _Fallback(
      letter: _initial(p.nome),
      tint: _tintFor(p.categoria),
    );
  }

  String _initial(String nome) =>
      nome.isNotEmpty ? nome.characters.first.toUpperCase() : '?';

  Color _tintFor(String categoria) {
    switch (categoria) {
      case 'Móveis':
        return AppTheme.accentTint;
      case 'Decoração':
        return AppTheme.brandRedTint;
      case 'Eletro':
        return AppTheme.brandGreenTint;
      case 'Calçados':
      case 'Vestuário':
      case 'Acessórios':
        return AppTheme.accentTint;
      default:
        return AppTheme.bgMuted;
    }
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.letter, required this.tint, this.icon});
  final String letter;
  final Color tint;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.isDark ? AppTheme.bgMuted : tint,
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon, size: 18, color: AppTheme.ink4)
          : Text(
              letter,
              style: TextStyle(
                fontFamily: AppTheme.fontDisplay,
                fontStyle: FontStyle.italic,
                fontSize: 26,
                color: AppTheme.ink.withOpacity(0.55),
                letterSpacing: -0.5,
              ),
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.ios_share_outlined,
                size: 44, color: AppTheme.ink3.withOpacity(0.6)),
            const SizedBox(height: 14),
            Text('Nada compartilhado ainda',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.ink,
                )),
            const SizedBox(height: 6),
            Text(
              'Abra um produto e toque em "Compartilhar" para enviar o link a um comprador.',
              textAlign: TextAlign.center,
              style: AppText.bodySm,
            ),
          ],
        ),
      ),
    );
  }
}

String _relTime(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return 'agora';
  if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'há ${diff.inHours} h';
  if (diff.inDays == 1) return 'ontem';
  if (diff.inDays < 7) return 'há ${diff.inDays} dias';
  return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
}
