import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/aurora_theme.dart';

class SignalFusionScreen extends StatelessWidget {
  const SignalFusionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SIGNAL FUSION'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ANTIGRAVITY AGENT: FUSION PIPELINE',
              style: TextStyle(color: AuroraTheme.textMuted, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AuroraTheme.warning.withValues(alpha: 0.1),
                border: Border.all(color: AuroraTheme.warning),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: AuroraTheme.warning),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'CONTRADICTION DETECTED: Social media indicates Flood, Field Report indicates Water-Main Burst.',
                      style: TextStyle(color: AuroraTheme.warning, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            const Text(
              'LIVE STREAMS',
              style: TextStyle(color: AuroraTheme.primaryNeon, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSignalRow(Icons.comment, 'Social Media', '"Huge flooding in G-10 markaz!"', Colors.blue),
            const SizedBox(height: 8),
            _buildSignalRow(Icons.cloud, 'Weather API', 'Heavy Rain (45mm/hr)', Colors.grey),
            const SizedBox(height: 8),
            _buildSignalRow(Icons.directions_car, 'Traffic API', 'Slowdown (10 km/h)', AuroraTheme.warning),
            const SizedBox(height: 8),
            _buildSignalRow(Icons.person, 'Field Report', '"Pipe burst near the main intersection."', AuroraTheme.secondaryNeon),
            
            const SizedBox(height: 32),
            
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/crisis_detail'),
                child: const Text('VIEW RESOLVED CRISIS DETAILS'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalRow(IconData icon, String source, String data, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AuroraTheme.surface.withValues(alpha: 0.4),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(source, style: const TextStyle(fontWeight: FontWeight.bold, color: AuroraTheme.textMain)),
                    Text(data, style: const TextStyle(color: AuroraTheme.textMuted)),
                  ],
                ),
              ),
              const Icon(Icons.check_circle, color: AuroraTheme.primaryNeon, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
