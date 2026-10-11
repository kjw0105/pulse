import 'package:flutter/material.dart';

class TokenRequiredView extends StatelessWidget {
  const TokenRequiredView({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF090B0F),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    color: Color(0x1AB6FF69),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.waves_rounded,
                    color: Color(0xFFB6FF69),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Pulse',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                const Text(
                  '지도를 불러오려면 Mapbox public access token이 필요합니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, height: 1.5),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const SelectableText(
                    'flutter run --dart-define=ACCESS_TOKEN=pk.xxx',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFB6FF69),
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
