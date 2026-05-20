
import 'package:flutter/material.dart';
import '../theme/aurora_theme.dart';

class CrisisDetailScreen extends StatelessWidget {
  const CrisisDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CRISIS: WATER-MAIN BURST')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [AuroraTheme.primaryNeon.withValues(alpha: 0.2), AuroraTheme.secondaryNeon.withValues(alpha: 0.2)],
                ),
                border: Border.all(color: AuroraTheme.primaryNeon),
              ),
              child: const Center(
                child: Icon(Icons.water_damage, size: 80, color: AuroraTheme.primaryNeon),
              ),
            ),
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMiniStat('Severity', 'CRITICAL', AuroraTheme.warning),
                _buildMiniStat('Radius', '2.5 km', AuroraTheme.primaryNeon),
                _buildMiniStat('Pop.', '15,000', AuroraTheme.secondaryNeon),
              ],
            ),
            
            const SizedBox(height: 32),
            const Text(
              'EVOLUTION TIMELINE (PREDICTED)',
              style: TextStyle(color: AuroraTheme.primaryNeon, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            _buildTimelineItem('15:00', 'Initial signal detected (Social Media)'),
            _buildTimelineItem('15:15', 'Field report confirmed Water-Main Burst'),
            _buildTimelineItem('16:30', 'Peak impact expected (Traffic gridlock)'),
            
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.precision_manufacturing),
                label: const Text('ALLOCATE RESOURCES'),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(color: AuroraTheme.textMuted)),
      ],
    );
  }

  Widget _buildTimelineItem(String time, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(time, style: const TextStyle(color: AuroraTheme.secondaryNeon, fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          Expanded(child: Text(desc, style: const TextStyle(color: AuroraTheme.textMain))),
        ],
      ),
    );
  }
}
