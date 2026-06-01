import 'package:flutter/material.dart';
import '../utils/theme.dart';

class DockTab {
  final String id;
  final IconData icon;
  final String label;
  const DockTab({required this.id, required this.icon, required this.label});
}

class LiquidDock extends StatelessWidget {
  final List<DockTab> tabs;
  final String activeTab;
  final HSRTheme theme;
  final ValueChanged<String> onTabChanged;

  const LiquidDock({super.key, required this.tabs, required this.activeTab, required this.theme, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 32),
          BoxShadow(color: theme.accent.withValues(alpha: 0.15), blurRadius: 20),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: tabs.map((tab) {
          final isActive = tab.id == activeTab;
          return GestureDetector(
            onTap: () => onTabChanged(tab.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              padding: EdgeInsets.symmetric(horizontal: isActive ? 14 : 14, vertical: 4),
              decoration: isActive ? BoxDecoration(
                gradient: LinearGradient(colors: [theme.accent.withValues(alpha: 0.2), theme.accent.withValues(alpha: 0.1)]),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: theme.accentBorder),
                boxShadow: [BoxShadow(color: theme.accent.withValues(alpha: 0.2), blurRadius: 16)],
              ) : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(tab.icon, size: 20, color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.28)),
                  if (isActive) ...[
                    const SizedBox(width: 7),
                    Text(tab.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: theme.accent)),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}