import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/aurora_theme.dart';

class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            const Text(
              'GLOBAL ANALYTICS & INSIGHTS',
              style: TextStyle(color: AuroraTheme.primaryNeon, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            const SizedBox(height: 24),
            
            // Response Times Bar Chart
            Expanded(
              flex: 2,
              child: _buildGlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('AVG RESPONSE TIMES (MINS)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Expanded(
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 60,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  const style = TextStyle(color: AuroraTheme.textMuted, fontWeight: FontWeight.bold, fontSize: 10);
                                  Widget text;
                                  switch (value.toInt()) {
                                    case 0: text = const Text('Seismic', style: style); break;
                                    case 1: text = const Text('Flood', style: style); break;
                                    case 2: text = const Text('Fire', style: style); break;
                                    case 3: text = const Text('Grid', style: style); break;
                                    default: text = const Text('', style: style); break;
                                  }
                                  return SideTitleWidget(meta: meta, space: 4, child: text);
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 12, color: AuroraTheme.primaryNeon, width: 20, borderRadius: BorderRadius.circular(4))]),
                            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 45, color: AuroraTheme.secondaryNeon, width: 20, borderRadius: BorderRadius.circular(4))]),
                            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 28, color: AuroraTheme.warning, width: 20, borderRadius: BorderRadius.circular(4))]),
                            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 8, color: Colors.purpleAccent, width: 20, borderRadius: BorderRadius.circular(4))]),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Crisis Distribution Pie Chart
            Expanded(
              flex: 2,
              child: _buildGlassContainer(
                child: Row(
                  children: [
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 30,
                          sections: [
                            PieChartSectionData(color: AuroraTheme.primaryNeon, value: 40, title: '40%', radius: 40, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                            PieChartSectionData(color: AuroraTheme.secondaryNeon, value: 30, title: '30%', radius: 35, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                            PieChartSectionData(color: AuroraTheme.warning, value: 15, title: '15%', radius: 30, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                            PieChartSectionData(color: Colors.purpleAccent, value: 15, title: '15%', radius: 30, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CRISIS DISTRIBUTION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 12),
                          _buildLegend('Seismic Events', AuroraTheme.primaryNeon),
                          _buildLegend('Floods / Weather', AuroraTheme.secondaryNeon),
                          _buildLegend('Fires', AuroraTheme.warning),
                          _buildLegend('Infrastructure', Colors.purpleAccent),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: AuroraTheme.textMuted, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AuroraTheme.surface.withValues(alpha: 0.4),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}
