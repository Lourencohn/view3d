import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../models/produto.dart';
import '../../shared/widgets/app_error_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../theme.dart';
import 'catalogo_provider.dart';

class CatalogoScreen extends ConsumerWidget {
  const CatalogoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final produtos = ref.watch(produtosFiltradosProvider);
    final filtro = ref.watch(categoriaFilterProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          _CategoriaFilters(active: filtro, ref: ref),

          Expanded(
            child: produtos.when(
              loading: () => const LoadingWidget(),
              error: (e, _) => AppErrorWidget(
                message: 'Não foi possível carregar o catálogo.\n$e',
                onRetry: () => ref.invalidate(produtosProvider),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return const _EmptyState();
                }
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.64,
                  ),
                  itemCount: list.length,
                  itemBuilder: (ctx, i) {
                    final p = list[i];
                    return _ProdutoCard(
                      produto: p,
                      onTap: () => context.push('/produto/${p.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoriaFilters extends StatelessWidget {
  const _CategoriaFilters({required this.active, required this.ref});
  final String? active;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final items = <String?>[null, ...kCategorias];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (ctx, i) {
          final c = items[i];
          final selected = c == active;
          return GestureDetector(
            onTap: () =>
                ref.read(categoriaFilterProvider.notifier).state = c,
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
                c ?? 'Todos',
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

class _ProdutoCard extends StatelessWidget {
  const _ProdutoCard({required this.produto, required this.onTap});
  final Produto produto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.bgCard,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProdutoThumb(produto: produto),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.ink.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '3D · AR',
                        style: TextStyle(
                          color: AppTheme.bgApp,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produto.nome,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.1,
                      color: AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    produto.categoria,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.ink3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (produto.sku != null) ...[
                    const SizedBox(height: 2),
                    Text(produto.sku!, style: AppText.mono),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProdutoThumb extends StatelessWidget {
  const ProdutoThumb({
    super.key,
    required this.produto,
    this.autoRotate = true,
  });

  final Produto produto;
  final bool autoRotate;

  @override
  Widget build(BuildContext context) {
    final hasThumb =
        produto.thumbUrl != null && produto.thumbUrl!.isNotEmpty;

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.1),
              radius: 0.9,
              colors: AppTheme.isDark
                  ? [
                      AppTheme.bgMuted,
                      AppTheme.bgApp,
                    ]
                  : const [
                      Colors.white,
                      Color(0xFFE8EEF5),
                    ],
            ),
          ),
        ),
        if (hasThumb)
          CachedNetworkImage(
            imageUrl: produto.thumbUrl!,
            fit: BoxFit.cover,
            placeholder: (_, __) => const SizedBox.shrink(),
            errorWidget: (_, __, ___) => _GlbInline(
              produto: produto,
              autoRotate: autoRotate,
            ),
          )
        else
          _GlbInline(produto: produto, autoRotate: autoRotate),
      ],
    );
  }
}

class _GlbInline extends StatefulWidget {
  const _GlbInline({required this.produto, required this.autoRotate});
  final Produto produto;
  final bool autoRotate;

  @override
  State<_GlbInline> createState() => _GlbInlineState();
}

class _GlbInlineState extends State<_GlbInline> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _PosterInitial(produto: widget.produto),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 350),
          opacity: _ready ? 1.0 : 0.0,
          child: IgnorePointer(
            child: ModelViewer(
              src: widget.produto.glbUrl,
              alt: widget.produto.nome,
              autoRotate: widget.autoRotate,
              cameraControls: false,
              autoPlay: true,
              disableTap: true,
              disableZoom: true,
              disablePan: true,
              interactionPrompt: InteractionPrompt.none,
              loading: Loading.lazy,
              backgroundColor: const Color(0x00000000),
              shadowIntensity: 0.6,
              exposure: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}

class _PosterInitial extends StatelessWidget {
  const _PosterInitial({required this.produto});
  final Produto produto;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          produto.nome.split(' ').take(2).join(' '),
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(
            fontFamily: AppTheme.fontDisplay,
            fontStyle: FontStyle.italic,
            fontSize: 34,
            height: 1.0,
            color: AppTheme.ink.withOpacity(0.18),
            letterSpacing: -0.5,
          ),
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
            Icon(
              Icons.view_in_ar_outlined,
              size: 48,
              color: AppTheme.ink3.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Catálogo vazio',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppTheme.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Nenhum produto publicado para sua empresa ainda.',
              textAlign: TextAlign.center,
              style: AppText.bodySm,
            ),
          ],
        ),
      ),
    );
  }
}
