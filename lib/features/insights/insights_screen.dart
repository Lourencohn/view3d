import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/compartilhamento.dart';
import '../../models/produto.dart';
import '../../shared/widgets/app_error_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../theme.dart';
import '../catalogo/catalogo_provider.dart';
import 'insights_provider.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(insightsProvider);
    final produtos =
        ref.watch(produtosProvider).asData?.value ?? const <Produto>[];

    return SafeArea(
      bottom: false,
      child: insights.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => AppErrorWidget(
          message: 'Não foi possível carregar os insights.\n$e',
          onRetry: () => ref.invalidate(insightsProvider),
        ),
        data: (snap) => _Body(snap: snap, produtos: produtos),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.snap, required this.produtos});
  final InsightsSnapshot snap;
  final List<Produto> produtos;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ÚLTIMOS 7 DIAS', style: AppText.caption),
              const SizedBox(height: 4),
              Text('Insights', style: AppText.titleXL),
            ],
          ),
        ),

        // Hero — total views + sparkbars
        _HeroCard(snap: snap),
        const SizedBox(height: 10),

        // Stats grid
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: 'Compradores únicos',
                value: '${snap.uniqueBuyers}',
                delta: snap.uniqueBuyersDelta,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                label: 'Sessões AR',
                value: '${snap.arSessions}',
                delta: snap.arSessionsDelta,
                accent: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: 'Tempo médio',
                value: '${snap.avgTimeSec}',
                suffix: 's',
                delta: snap.avgTimeDelta,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                label: 'Taxa AR',
                value:
                    '${(snap.arSessions / snap.views7d * 100).round()}',
                suffix: '%',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        _TopProdutosCard(snap: snap, produtos: produtos),
        const SizedBox(height: 10),

        _CanaisCard(snap: snap),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.snap});
  final InsightsSnapshot snap;

  @override
  Widget build(BuildContext context) {
    final previous =
        (snap.views7d / (1 + snap.views7dDelta)).round();
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A1A1815),
              blurRadius: 8,
              offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOTAL DE VIEWS',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.ink3,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w500,
                  )),
              _DeltaPill(value: snap.views7dDelta),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${snap.views7d}',
                  style: TextStyle(
                    fontFamily: AppTheme.fontDisplay,
                    fontSize: 56,
                    height: 1,
                    letterSpacing: -1.4,
                    color: AppTheme.ink,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  )),
              const SizedBox(width: 10),
              Text('vs ',
                  style: TextStyle(
                    fontFamily: AppTheme.fontDisplay,
                    fontSize: 22,
                    color: AppTheme.ink4,
                    fontStyle: FontStyle.italic,
                  )),
              Text('$previous',
                  style: TextStyle(
                    fontFamily: AppTheme.fontDisplay,
                    fontSize: 22,
                    color: AppTheme.ink4,
                    fontStyle: FontStyle.italic,
                    decoration: TextDecoration.lineThrough,
                  )),
            ],
          ),
          const SizedBox(height: 14),
          _Sparkbars(data: snap.viewsSeries),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _DayLabel('7D'),
                _DayLabel('6D'),
                _DayLabel('5D'),
                _DayLabel('4D'),
                _DayLabel('3D'),
                _DayLabel('2D'),
                _DayLabel('HOJE', active: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DayLabel extends StatelessWidget {
  const _DayLabel(this.text, {this.active = false});
  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
          fontSize: 10,
          color: active ? AppTheme.ink2 : AppTheme.ink3,
          letterSpacing: 0.5,
          fontWeight: active ? FontWeight.w600 : FontWeight.w500,
        ));
  }
}

class _Sparkbars extends StatelessWidget {
  const _Sparkbars({required this.data});
  final List<int> data;

  @override
  Widget build(BuildContext context) {
    final max = data.fold<int>(1, (a, b) => b > a ? b : a);
    return SizedBox(
      height: 70,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(data.length, (i) {
          final isLast = i == data.length - 1;
          final h = (data[i] / max * 66).clamp(4.0, 66.0);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Container(
                height: h,
                decoration: BoxDecoration(
                  color:
                      isLast ? AppTheme.accent : AppTheme.ink.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    this.delta,
    this.suffix,
    this.accent = false,
  });
  final String label;
  final String value;
  final double? delta;
  final String? suffix;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x081A1815), blurRadius: 6, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.ink3,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 4,
            children: [
              RichText(
                text: TextSpan(
                  text: value,
                  style: TextStyle(
                    fontFamily: AppTheme.fontDisplay,
                    fontSize: 30,
                    height: 1,
                    letterSpacing: -0.5,
                    color: accent ? AppTheme.accent : AppTheme.ink,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  children: [
                    if (suffix != null)
                      TextSpan(
                        text: suffix,
                        style: TextStyle(
                          fontFamily: 'system-ui',
                          fontSize: 14,
                          color: AppTheme.ink3,
                        ),
                      ),
                  ],
                ),
              ),
              if (delta != null) _DeltaPill(value: delta!),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeltaPill extends StatelessWidget {
  const _DeltaPill({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    final positive = value >= 0;
    final pct = (value.abs() * 100).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: positive ? const Color(0xFFDBF2E6) : const Color(0xFFFDE0DB),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${positive ? '↑' : '↓'} $pct%',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: positive ? const Color(0xFF1F8A5B) : const Color(0xFFC93F2A),
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _TopProdutosCard extends StatelessWidget {
  const _TopProdutosCard({required this.snap, required this.produtos});
  final InsightsSnapshot snap;
  final List<Produto> produtos;

  Produto? _find(String id) {
    for (final p in produtos) {
      if (p.id == id) return p;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final maxViews = snap.topProdutos.isEmpty
        ? 1
        : snap.topProdutos.first.views;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A1A1815),
              blurRadius: 8,
              offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOP PRODUTOS',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.ink3,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w500,
                  )),
              Text('views · AR',
                  style: TextStyle(fontSize: 10, color: AppTheme.ink4)),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(snap.topProdutos.length, (i) {
            final row = snap.topProdutos[i];
            final produto = _find(row.produtoId);
            return _TopRow(
              index: i + 1,
              produto: produto,
              views: row.views,
              ar: row.arSessions,
              ratio: row.views / maxViews,
              onTap: produto == null
                  ? null
                  : () => context.push('/produto/${produto.id}'),
            );
          }),
        ],
      ),
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({
    required this.index,
    required this.produto,
    required this.views,
    required this.ar,
    required this.ratio,
    this.onTap,
  });
  final int index;
  final Produto? produto;
  final int views;
  final int ar;
  final double ratio;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              child: Text(
                index.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: AppTheme.ink3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.bgMuted,
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: Text(
                produto?.nome.isNotEmpty == true ? produto!.nome[0] : '?',
                style: TextStyle(
                  fontFamily: AppTheme.fontDisplay,
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                  color: AppTheme.ink.withOpacity(0.45),
                ),
              ),
            ),
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
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.ink,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppTheme.bgMuted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: ratio.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.ink,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 32,
              child: Text(
                '$views',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.ink,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            SizedBox(
              width: 26,
              child: Text(
                '$ar',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.accent,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CanaisCard extends StatelessWidget {
  const _CanaisCard({required this.snap});
  final InsightsSnapshot snap;

  @override
  Widget build(BuildContext context) {
    final ordered = snap.canais.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A1A1815),
              blurRadius: 8,
              offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('POR ONDE COMPARTILHA',
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.ink3,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w500,
              )),
          const SizedBox(height: 10),
          // Stacked horizontal bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: ordered.map((e) {
                  final canal = Canal.values.firstWhere(
                    (c) => c.name == e.key,
                    orElse: () => Canal.link,
                  );
                  return Expanded(
                    flex: (e.value * 1000).round().clamp(1, 1000),
                    child: Container(color: Color(canal.colorHex)),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...ordered.map((e) {
            final canal = Canal.values.firstWhere(
              (c) => c.name == e.key,
              orElse: () => Canal.link,
            );
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Color(canal.colorHex),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      canal.label,
                      style: TextStyle(
                          fontSize: 13, color: AppTheme.ink2),
                    ),
                  ),
                  Text(
                    '${(e.value * 100).round()}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.ink,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
