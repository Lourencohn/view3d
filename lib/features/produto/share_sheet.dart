import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/produto.dart';
import '../../theme.dart';

class ShareSheet extends StatelessWidget {
  const ShareSheet({super.key, required this.produto});
  final Produto produto;

  @override
  Widget build(BuildContext context) {
    final shortUrl =
        produto.viewerUrl.replaceFirst(RegExp(r'^https?://'), '');

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
          14,
          12,
          14,
          26 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: AppTheme.lineStrong,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.bgMuted,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      produto.nome.isNotEmpty ? produto.nome[0] : '?',
                      style: TextStyle(
                        fontFamily: AppTheme.fontDisplay,
                        fontStyle: FontStyle.italic,
                        fontSize: 22,
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
                          'Compartilhar ${produto.nome}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.1,
                            color: AppTheme.ink,
                          ),
                        ),
                        Text(
                          'Comprador acessa pelo navegador, sem app',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.ink3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
              decoration: BoxDecoration(
                color: AppTheme.bgMuted,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.link_rounded,
                      size: 18, color: AppTheme.ink3),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      shortUrl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.mono.copyWith(color: AppTheme.ink2),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: AppTheme.ink,
                      foregroundColor: AppTheme.bgApp,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      await Clipboard.setData(
                          ClipboardData(text: produto.viewerUrl));
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Link copiado para a área de transferência'),
                        ),
                      );
                    },
                    child: const Text('Copiar',
                        style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: _ShareTile(
                    icon: Icons.chat_rounded,
                    label: 'WhatsApp',
                    color: const Color(0xFF25D366),
                    onTap: () => _share(context, produto, 'whatsapp'),
                  ),
                ),
                Expanded(
                  child: _ShareTile(
                    icon: Icons.mail_outline_rounded,
                    label: 'E-mail',
                    color: const Color(0xFF0A84FF),
                    onTap: () => _share(context, produto, 'email'),
                  ),
                ),
                Expanded(
                  child: _ShareTile(
                    icon: Icons.qr_code_rounded,
                    label: 'QR Code',
                    color: AppTheme.accent,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/produto/${produto.id}/qr');
                    },
                  ),
                ),
                Expanded(
                  child: _ShareTile(
                    icon: Icons.more_horiz_rounded,
                    label: 'Mais',
                    color: AppTheme.ink,
                    onTap: () => _share(context, produto, 'system'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _share(BuildContext ctx, Produto p, String channel) async {
    final text = 'Veja em 3D: ${p.nome}\n${p.viewerUrl}';
    await Share.share(text, subject: p.nome);
    if (ctx.mounted) Navigator.of(ctx).pop();
  }
}

class _ShareTile extends StatelessWidget {
  const _ShareTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.ink2,
                  fontWeight: FontWeight.w500,
                )),
          ],
        ),
      ),
    );
  }
}
