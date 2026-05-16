import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/usuario.dart';
import '../../providers/theme_mode_provider.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../theme.dart';
import '../auth/auth_provider.dart';

class ContaScreen extends ConsumerWidget {
  const ContaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);

    if (auth is! AuthSignedIn) {
      return const LoadingWidget();
    }
    final user = auth.usuario;
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return SafeArea(
      bottom: false,
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PERFIL', style: AppText.caption),
                const SizedBox(height: 4),
                Text('Conta', style: AppText.titleXL),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: _ProfileCard(user: user),
          ),

          _Section(title: 'Conta', children: [
            _Row(
              icon: Icons.person_outline_rounded,
              label: 'Nome',
              value: user.nome.split(' ').first,
            ),
            _Row(
              icon: Icons.mail_outline_rounded,
              label: 'E-mail',
              value: _truncate(user.email, 18),
            ),
            const _Row(
              icon: Icons.lock_outline_rounded,
              label: 'Senha',
              value: 'Trocar',
            ),
            _Row(
              icon: Icons.business_outlined,
              label: 'Empresa',
              value: user.empresaId,
              isLast: true,
            ),
          ]),

          _Section(title: 'Preferências', children: [
            const _Row(
              icon: Icons.notifications_none_rounded,
              label: 'Notificações',
              value: 'Ativas',
            ),
            _Row(
              icon: Icons.dark_mode_outlined,
              label: 'Modo escuro',
              trailing: Switch(
                value: isDark,
                activeColor: AppTheme.accent,
                onChanged: (v) {
                  ref
                      .read(themeModeProvider.notifier)
                      .setMode(v ? ThemeMode.dark : ThemeMode.light);
                },
              ),
            ),
            const _Row(
              icon: Icons.translate_rounded,
              label: 'Idioma',
              value: 'Português',
              isLast: true,
            ),
          ]),

          _Section(title: 'Sobre', children: [
            const _Row(
              icon: Icons.info_outline_rounded,
              label: 'Sobre a TROVATA',
            ),
            const _Row(
              icon: Icons.shield_outlined,
              label: 'Termos e privacidade',
            ),
            const _Row(
              icon: Icons.support_agent_rounded,
              label: 'Falar com suporte',
              value: 'ajuda@trovata.com.br',
              isLast: true,
            ),
          ]),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Material(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Sair da conta?'),
                      content: const Text(
                          'Você precisará entrar novamente na próxima vez.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: TextButton.styleFrom(
                              foregroundColor: AppTheme.accent),
                          child: const Text('Sair'),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await ref.read(authControllerProvider).signOut();
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded,
                          size: 18, color: AppTheme.accent),
                      SizedBox(width: 14),
                      Text(
                        'Sair',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppTheme.accent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Center(
              child: Text(
                'TROVATA · v0.1.0 · © 2026 Trovata · Birigui-SP',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: AppTheme.ink4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _truncate(String s, int n) =>
      s.length > n ? '${s.substring(0, n)}…' : s;
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.user});
  final Usuario user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A1A1815),
              blurRadius: 8,
              offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.ink,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              user.iniciais,
              style: TextStyle(
                fontFamily: AppTheme.fontDisplay,
                fontSize: 26,
                color: AppTheme.bgApp,
                letterSpacing: -0.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTheme.fontDisplay,
                      fontSize: 26,
                      height: 1.0,
                      letterSpacing: -0.5,
                      color: AppTheme.ink,
                    )),
                const SizedBox(height: 4),
                Text(user.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.ink3,
                    )),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.accentTint,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${user.papel == Papel.admin ? 'Admin' : 'Vendedor'} · ${user.empresaId}'
                        .toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.accentDeep,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
            child: Text(title.toUpperCase(), style: AppText.caption),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x081A1815),
                    blurRadius: 6,
                    offset: Offset(0, 1)),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    this.value,
    this.trailing,
    this.onTap,
    this.isLast = false,
  });
  final IconData icon;
  final String label;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(color: AppTheme.line, width: 0.5),
                ),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppTheme.bgMuted,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 16, color: AppTheme.ink2),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.ink,
                  letterSpacing: -0.1,
                ),
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null && value != null)
              Text(
                value!,
                style: TextStyle(fontSize: 13, color: AppTheme.ink3),
              ),
            if (trailing == null) ...[
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppTheme.ink4),
            ],
          ],
        ),
      ),
    );
  }
}
