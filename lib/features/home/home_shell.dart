import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme.dart';

/// Shell com barra de navegação inferior. Envolve as abas catálogo,
/// compartilhados, insights e conta usando `StatefulShellRoute.indexedStack` —
/// todas as abas ficam montadas, a troca é instantânea (IndexedStack apenas
/// alterna qual filha é visível), e o estado de cada aba é preservado entre
/// trocas.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _tabs = <_HomeTab>[
    _HomeTab(label: 'Catálogo', icon: Icons.grid_view_rounded),
    _HomeTab(label: 'Compartilhados', icon: Icons.ios_share_rounded),
    _HomeTab(label: 'Insights', icon: Icons.insights_rounded),
    _HomeTab(label: 'Conta', icon: Icons.person_outline_rounded),
  ];

  void _go(int index) {
    // initialLocation: true volta pra raiz da branch ao re-tocar a mesma aba.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = navigationShell.currentIndex;

    return Scaffold(
      backgroundColor: AppTheme.bgApp,
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
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
              return _NavItem(
                tab: e.value,
                active: i == activeIndex,
                onTap: () => _go(i),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _HomeTab {
  final String label;
  final IconData icon;
  const _HomeTab({required this.label, required this.icon});
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
