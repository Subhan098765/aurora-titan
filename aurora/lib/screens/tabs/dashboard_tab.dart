import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/aurora_theme.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60), // Space for AppBar
              
              // Top Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniStat('Global Confidence', '94.2%', AuroraTheme.primaryNeon),
                  _buildMiniStat('Active Nodes', '12,042', AuroraTheme.secondaryNeon),
                  _buildMiniStat('Resolved', '84', Colors.greenAccent),
                ],
              ),
              const SizedBox(height: 24),

              // Live Ingestion Chart
              const Text(
                'LIVE SIGNAL INGESTION (TPS)',
                style: TextStyle(color: AuroraTheme.textMuted, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              const SizedBox(height: 16),
              _buildGlassCard(
                context,
                child: SizedBox(
                  height: 200,
                  child: _buildLineChart(),
                ),
              ),
              
              const SizedBox(height: 32),
              const Text(
                'CRITICAL ANOMALIES',
                style: TextStyle(color: AuroraTheme.warning, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              const SizedBox(height: 16),
              
              // Animated Critical Card
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/signal_fusion'),
                child: _buildGlowingCard(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: AuroraTheme.warning, size: 28),
                              const SizedBox(width: 12),
                              Text(
                                'Global Critical Nodes: 4',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AuroraTheme.warning.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AuroraTheme.warning),
                            ),
                            child: const Text('PRIORITY 1', style: TextStyle(color: AuroraTheme.warning, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Conflict: Earthquake (Tokyo) vs Tsunami Warnings', style: TextStyle(color: AuroraTheme.textMain)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Expanded(
                            child: LinearProgressIndicator(
                              value: 0.92,
                              backgroundColor: Colors.white12,
                              color: AuroraTheme.warning,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text('92% Confidence', style: TextStyle(color: AuroraTheme.warning.withValues(alpha: 0.8))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(color: AuroraTheme.textMuted, fontSize: 12)),
      ],
    );
  }

  Widget _buildGlassCard(BuildContext context, {required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AuroraTheme.surface.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildGlowingCard(BuildContext context, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AuroraTheme.warning.withValues(alpha: 0.15),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: _buildGlassCard(context, child: child),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.white.withValues(alpha: 0.05), strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}k', style: const TextStyle(color: AuroraTheme.textMuted, fontSize: 10));
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 6,
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 3),
              FlSpot(1, 2),
              FlSpot(2, 5),
              FlSpot(3, 3.1),
              FlSpot(4, 4),
              FlSpot(5, 3),
              FlSpot(6, 4.5),
            ],
            isCurved: true,
            color: AuroraTheme.primaryNeon,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AuroraTheme.primaryNeon.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }
}
