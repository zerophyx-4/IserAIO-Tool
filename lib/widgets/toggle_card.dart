import 'package:flutter/material.dart';

class ToggleCard extends StatelessWidget {
  final String label;
  final String sub;
  final bool value;
  final Color color;
  final bool needsRestart;
  final bool devOnly;
  final ValueChanged<bool> onChanged;

  const ToggleCard({
    super.key,
    required this.label,
    required this.sub,
    required this.value,
    required this.color,
    required this.onChanged,
    this.needsRestart = false,
    this.devOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: value ? color.withOpacity(0.08) : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: value ? color.withOpacity(0.35) : Colors.white.withOpacity(0.06)),
        boxShadow: value ? [BoxShadow(color: color.withOpacity(0.12), blurRadius: 16)] : [],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xCCFFFFFF)))),
                    if (needsRestart) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(color: const Color(0xFFFF8C00).withOpacity(0.15), borderRadius: BorderRadius.circular(99)),
                        child: const Text('Restart', style: TextStyle(fontSize: 9, color: Color(0xFFFF8C00), fontWeight: FontWeight.w700)),
                      ),
                    ],
                    if (devOnly) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(color: const Color(0xFFFF4D4D).withOpacity(0.15), borderRadius: BorderRadius.circular(99)),
                        child: const Text('DEV', style: TextStyle(fontSize: 9, color: Color(0xFFFF4D4D), fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(sub, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.3))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 42, height: 24,
              decoration: BoxDecoration(
                color: value ? color : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: value ? color.withOpacity(0.5) : Colors.white.withOpacity(0.1)),
                boxShadow: value ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8)] : [],
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                curve: Curves.elasticOut,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.all(2),
                  width: 18, height: 18,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}