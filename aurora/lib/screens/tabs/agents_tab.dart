import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/aurora_theme.dart';
import 'dart:math' as math;

class AgentsTab extends StatefulWidget {
  const AgentsTab({super.key});

  @override
  State<AgentsTab> createState() => _AgentsTabState();
}

class _AgentsTabState extends State<AgentsTab> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ANTIGRAVITY PIPELINE',
                  style: TextStyle(color: AuroraTheme.primaryNeon, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _animController.value * 2 * math.pi,
                      child: const Icon(Icons.settings, color: AuroraTheme.primaryNeon, size: 20),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildAgentNode(
                    '1. Signal Fusion Agent',
                    'Ingesting 1,420 tps from Social, Weather, APIs.',
                    Icons.merge_type,
                    AuroraTheme.primaryNeon,
                    true,
                  ),
                  _buildConnector(AuroraTheme.primaryNeon),
                  _buildAgentNode(
                    '2. Crisis Classifier Agent',
                    'Classified as CRITICAL: Water-Main Burst vs Flood conflict resolved.',
                    Icons.category,
                    AuroraTheme.warning,
                    true,
                  ),
                  _buildConnector(AuroraTheme.warning),
                  _buildAgentNode(
                    '3. Evolution Predictor',
                    'Mapping spread. Radius 1.5km. Impact peak at 16:30.',
                    Icons.timeline,
                    AuroraTheme.secondaryNeon,
                    true,
                  ),
                  _buildConnector(AuroraTheme.secondaryNeon),
                  _buildAgentNode(
                    '4. Resource Optimizer',
                    'Rerouting Drone DRN-05 and Ambulance AMB-01.',
                    Icons.route,
                    Colors.greenAccent,
                    true,
                  ),
                  _buildConnector(Colors.grey.withValues(alpha: 0.3)),
                  _buildAgentNode(
                    '5. Stakeholder Messaging',
                    'Drafting EMS alerts and Media briefs. Awaiting approval.',
                    Icons.message,
                    Colors.grey,
                    false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnector(Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 36),
      height: 30,
      width: 2,
      color: color,
    );
  }

  Widget _buildAgentNode(String title, String desc, IconData icon, Color color, bool isActive) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isActive ? color.withValues(alpha: 0.1) : AuroraTheme.surface.withValues(alpha: 0.4),
            border: Border.all(color: isActive ? color.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1), width: isActive ? 2 : 1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(desc, style: TextStyle(color: isActive ? Colors.white70 : AuroraTheme.textMuted, fontSize: 13)),
                  ],
                ),
              ),
              if (isActive)
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: (_animController.value > 0.5 ? 1.0 - _animController.value : _animController.value) * 2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: color, blurRadius: 10, spreadRadius: 2)],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
