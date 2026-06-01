import 'package:flutter/material.dart';

class ProfileData {
  final String id;
  final String label;
  final String icon;
  final Color color;
  final String desc;
  const ProfileData({required this.id, required this.label, required this.icon, required this.color, required this.desc});
}

const List<ProfileData> kProfiles = [
  ProfileData(id: 'gaming',      label: 'Gaming',      icon: '⚡', color: Color(0xFFFF4D4D), desc: 'Max perf · Thermal OFF'),
  ProfileData(id: 'performance', label: 'Performance', icon: '🔥', color: Color(0xFFFF8C00), desc: 'High perf · Thermal OFF'),
  ProfileData(id: 'balanced',    label: 'Balanced',    icon: '⚖️', color: Color(0xFF00C2FF), desc: 'Default schedutil'),
  ProfileData(id: 'daily',       label: 'Daily',       icon: '☀️', color: Color(0xFF00E5A0), desc: 'Deep sleep · GMS doze'),
  ProfileData(id: 'battery',     label: 'Battery',     icon: '🔋', color: Color(0xFFA78BFA), desc: 'Powersave · Blur OFF'),
  ProfileData(id: 'cooldown',    label: 'Cool Down',   icon: '❄️', color: Color(0xFF67E8F9), desc: 'Powersave 2min → Balanced'),
];

class ProfileSelector extends StatelessWidget {
  final String activeProfile;
  final ValueChanged<String> onChanged;
  const ProfileSelector({super.key, required this.activeProfile, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final current = kProfiles.firstWhere((p) => p.id == activeProfile);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Performance Mode', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.5))),
            Text('${current.icon} ${current.label}', style: TextStyle(fontSize: 11, color: current.color, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: kProfiles.map((p) {
            final isActive = p.id == activeProfile;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(p.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 5),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: isActive ? p.color.withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isActive ? p.color.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.06), width: 1.5),
                    boxShadow: isActive ? [BoxShadow(color: p.color.withValues(alpha: 0.25), blurRadius: 14)] : [],
                  ),
                  child: Column(
                    children: [
                      Text(p.icon, style: const TextStyle(fontSize: 15)),
                      const SizedBox(height: 3),
                      Text(p.label, textAlign: TextAlign.center, style: TextStyle(fontSize: 8, color: isActive ? p.color : Colors.white.withValues(alpha: 0.3), fontWeight: isActive ? FontWeight.w700 : FontWeight.w400)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: current.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: current.color.withValues(alpha: 0.28)),
          ),
          child: Row(
            children: [
              Container(width: 5, height: 5, decoration: BoxDecoration(color: current.color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(child: Text(current.desc, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.4)))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: current.color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(99)),
                child: Text('ACTIVE', style: TextStyle(fontSize: 9, color: current.color, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}