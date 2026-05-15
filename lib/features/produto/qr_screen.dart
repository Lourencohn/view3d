import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../shared/widgets/app_error_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../theme.dart';
import '../catalogo/catalogo_provider.dart';

class QrScreen extends ConsumerStatefulWidget {
  const QrScreen({super.key, required this.produtoId});
  final String produtoId;

  @override
  ConsumerState<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends ConsumerState<QrScreen> {
  @override
  void initState() {
    super.initState();
    // Copia o link para o clipboard automaticamente — comportamento
    // obrigatório segundo a spec.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = ref.read(produtoByIdProvider(widget.produtoId)).asData?.value;
      if (p != null) {
        Clipboard.setData(ClipboardData(text: p.viewerUrl));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Link copiado para a área de transferência'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final produtoAsync = ref.watch(produtoByIdProvider(widget.produtoId));

    return Scaffold(
      backgroundColor: AppTheme.bgApp,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: produtoAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) =>
            AppErrorWidget(message: 'Erro ao carregar produto.\n$e'),
        data: (p) {
          if (p == null) {
            return const AppErrorWidget(message: 'Produto não encontrado.');
          }
          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('QR · APONTE A CÂMERA',
                      style: AppText.caption),
                  const SizedBox(height: 6),
                  Text(p.nome, style: AppText.titleXL),
                  const SizedBox(height: 24),

                  // Card com o QR
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.bgCard,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontFamily: AppTheme.fontDisplay,
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                  color: AppTheme.ink,
                                ),
                                children: [
                                  TextSpan(text: 'View'),
                                  TextSpan(
                                    text: '3D',
                                    style: TextStyle(
                                      color: AppTheme.accent,
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(p.sku ?? '', style: AppText.mono),
                          ],
                        ),
                        const SizedBox(height: 18),
                        QrImageView(
                          data: p.viewerUrl,
                          size: 240,
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: AppTheme.ink,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: AppTheme.ink,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          [p.categoria, p.cor]
                              .where((s) => s != null && s!.isNotEmpty)
                              .join(' · '),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.ink2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          p.viewerUrl.replaceFirst(RegExp(r'^https?://'), ''),
                          style: AppText.mono,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  SizedBox(
                    height: 56,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.ios_share_rounded, size: 18),
                      label: const Text('Compartilhar link'),
                      onPressed: () {
                        Share.share(
                          'Veja em 3D: ${p.nome}\n${p.viewerUrl}',
                          subject: p.nome,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Funciona em iOS, Android e desktop. Sem instalar app.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppTheme.ink3),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
