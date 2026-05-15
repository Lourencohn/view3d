import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme.dart';

/// Shell com barra de navegação inferior. Envolve catálogo, compartilhados,
/// insights e conta — usado via `ShellRoute` no go_router.
///
/// Cada item da nav corresponde a uma rota top-level. A rota corrente é
/// derivada da URL — o usuário pode usar deep link direto para qualquer
/// aba que a barra reflete corretamente.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.child});
  final Widget child;

  static const _tabs = <_HomeTab>[
    _HomeTab(
      path: '/catalogo',
      label: 'Catálogo',
      icon: Icons.grid_view_rounded,
    ),
    _HomeTab(
      path: '/compartilhados',
      label: 'Compartilhados',
      icon: Icons.ios_share_rounded,
    ),
    _HomeTab(
      path: '/insights',
      label: 'Insights',
      icon: Icons.insights_rounded,
    ),
    _HomeTab(
      path: '/conta',
      label: 'Conta',
      icon: Icons.person_outline_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final activeIndex = _tabs.indexWhere((t) => loc.startsWith(t.path));

    return Scaffold(
      backgroundColor: AppTheme.bgApp,
      body: child,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: AppTheme.bgApp,
            border: Border(
              top: BorderSide(color: AppTheme.line, width: 0.5),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _tabs.asMap().entries.map((e) {
              final i = e.key;
              final tab = e.value;
              final active = i == activeIndex;
              return _NavItem(
                tab: tab,
                active: active,
                onTap: () => context.go(tab.path),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _HomeTab {
  final String path;
  final String label;
  final IconData icon;
  const _HomeTab({
    required this.path,
    required this.label,
    required this.icon,
  });
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.active,
    required this.onTap,
  });
  final _HomeTab tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppTheme.ink : AppTheme.ink3;
    final accent = active ? AppTheme.accent : AppTheme.ink3;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(tab.icon, size: 22, color: accent),
              const SizedBox(height: 2),
              Text(
                tab.label,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
