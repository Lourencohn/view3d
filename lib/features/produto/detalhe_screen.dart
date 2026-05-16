import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../models/produto.dart';
import '../../shared/widgets/app_error_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../theme.dart';
import '../catalogo/catalogo_provider.dart';
import 'share_sheet.dart';

class DetalheScreen extends ConsumerWidget {
  const DetalheScreen({super.key, required this.produtoId});
  final String produtoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final produtoAsync = ref.watch(produtoByIdProvider(produtoId));

    return Scaffold(
      backgroundColor: AppTheme.bgApp,
      body: produtoAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => AppErrorWidget(
          message: 'Não foi possível carregar o produto.\n$e',
          onRetry: () => ref.invalidate(produtoByIdProvider(produtoId)),
        ),
        data: (p) {
          if (p == null) {
            return const AppErrorWidget(
              message: 'Produto não encontrado.',
            );
          }
          return _DetalheView(produto: p);
        },
      ),
    );
  }
}

class _DetalheView extends StatelessWidget {
  const _DetalheView({required this.produto});
  final Produto produto;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // 3D Viewer
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(0, -0.1),
                        radius: 1.0,
                        colors: [Colors.white, AppTheme.bgMuted],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: ModelViewer(
                    src: produto.glbUrl,
                    alt: produto.nome,
                    cameraControls: true,
                    autoRotate: true,
                    ar: true,
                    arModes: const ['webxr', 'scene-viewer', 'quick-look'],
                    arScale: ArScale.auto,
                    shadowIntensity: 1.0,
                    interactionPrompt: InteractionPrompt.none,
                    loading: Loading.eager,
                  ),
                ),
                // Top bar
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: _TopBar(produto: produto),
                ),
              ],
            ),
          ),

          // Info
          Expanded(
            flex: 6,
            child: _InfoBlock(produto: produto),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.produto});
  final Produto produto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _IconCircle(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          Row(
            children: [
              _IconCircle(
                icon: Icons.favorite_border_rounded,
                onTap: () {},
              ),
              const SizedBox(width: 8),
              _IconCircle(
                icon: Icons.more_horiz_rounded,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  const _IconCircle({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.78),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 18, color: AppTheme.ink),
        ),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.produto});
  final Produto produto;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.bgApp,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    [produto.categoria, produto.cor]
                        .where((s) => s != null && s.isNotEmpty)
                        .join(' · ')
                        .toUpperCase(),
                    style: AppText.caption,
                  ),
                  const SizedBox(height: 6),
                  Text(produto.nome, style: AppText.titleXL),
                  const SizedBox(height: 14),
                  Text(produto.descricao, style: AppText.body),
                  const SizedBox(height: 18),
                  _SpecsGrid(produto: produto),
                ],
              ),
            ),
          ),
          _StickyActions(produto: produto),
        ],
      ),
    );
  }
}

class _SpecsGrid extends StatelessWidget {
  const _SpecsGrid({required this.produto});
  final Produto produto;

  @override
  Widget build(BuildContext context) {
    final entries = <List<String?>>[
      ['SKU', produto.sku],
      ['Dimensões', produto.dimensoes],
      ['Peso', produto.peso],
      ['Material', produto.materiais],
      ['Preço', produto.preco],
    ].where((e) => e[1] != null && e[1]!.isNotEmpty).toList();

    if (entries.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.line,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(0.5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11.5),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 0.5,
          crossAxisSpacing: 0.5,
          childAspectRatio: 2.6,
          children: entries.map((e) {
            final isPreco = e[0] == 'Preço';
            return Container(
              color: AppTheme.bgCard,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    e[0]!.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.ink3,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    e[1]!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isPreco ? AppTheme.accent : AppTheme.ink,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _StickyActions extends StatelessWidget {
  const _StickyActions({required this.produto});
  final Produto produto;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.bgApp,
        border: Border(top: BorderSide(color: AppTheme.line, width: 0.5)),
      ),
      padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + bottomPad),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.qr_code_rounded, size: 18),
              label: const Text('QR Code'),
              onPressed: () =>
                  context.push('/produto/${produto.id}/qr'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton.icon(
              icon: const Icon(Icons.ios_share_rounded, size: 18),
              label: const Text('Compartilhar'),
              onPressed: () => _share(context, produto),
            ),
          ),
        ],
      ),
    );
  }

  void _share(BuildContext context, Produto produto) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ShareSheet(produto: produto),
    );
  }
}
