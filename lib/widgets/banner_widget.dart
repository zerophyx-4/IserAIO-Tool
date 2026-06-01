import 'package:flutter/material.dart';
import '../utils/theme.dart';

class BannerWidget extends StatelessWidget {
  final HSRTheme theme;
  final String deviceName;
  final String romName;
  final String androidVer;
  final String kernelVer;

  const BannerWidget({super.key, required this.theme, required this.deviceName, required this.romName, required this.androidVer, required this.kernelVer});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [theme.bannerStart, theme.bannerEnd]),
      ),
      child: Stack(
        children: [
          Positioned(bottom: -30, left: -30, child: Container(width: 180, height: 180, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [theme.accent.withValues(alpha: 0.25), Colors.transparent])))),
          Positioned(top: -20, right: -20, child: Container(width: 140, height: 140, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [theme.accent.withValues(alpha: 0.15), Colors.transparent])))),
          Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, theme.bg], stops: const [0.4, 1.0])))),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('👋 Good morning, haiser!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3)),
                            const SizedBox(height: 5),
                            Text(deviceName, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.55))),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(99), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
                        child: const Text('V1.0', style: TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.w600, letterSpacing: 1)),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      _chip(romName, theme.accent),
                      _chip('Android $androidVer', Colors.white.withValues(alpha: 0.6)),
                      _chip(kernelVer, Colors.white.withValues(alpha: 0.4)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(99), border: Border.all(color: color.withValues(alpha: 0.4))),
      child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}