import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../theme/aurora_theme.dart';
import '../../services/websocket_service.dart';
import '../../core/locator.dart';

class SystemTab extends StatefulWidget {
  const SystemTab({super.key});

  @override
  State<SystemTab> createState() => _SystemTabState();
}

class _SystemTabState extends State<SystemTab> {
  final ScrollController _scrollController = ScrollController();
  final WebSocketService _wsService = getIt<WebSocketService>();

  final List<Map<String, dynamic>> _metrics = [
    {'label': 'API Latency', 'value': '12ms', 'icon': Icons.speed, 'color': AuroraTheme.primaryNeon},
    {'label': 'Active Agents', 'value': '8/8', 'icon': Icons.memory, 'color': Colors.greenAccent},
    {'label': 'Signals/sec', 'value': '1,420', 'icon': Icons.wifi_tethering, 'color': AuroraTheme.secondaryNeon},
    {'label': 'DB Records', 'value': '94,201', 'icon': Icons.storage, 'color': Colors.purpleAccent},
  ];

  @override
  void initState() {
    super.initState();
    _wsService.addListener(_scrollToBottom);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _connectWebSocket() async {
    _wsService.connect('wss://aurora-titan-896824917672.europe-west1.run.app/ws/stream');
  }

  Future<void> _runLiveAnalysis() async {
    _wsService.send('AURORA_CLIENT_CONNECTED');
    try {
      await http.post(
        Uri.parse('https://aurora-titan-896824917672.europe-west1.run.app/api/v1/analyze-crisis'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'signals': [
            {'type': 'seismic', 'text': 'Magnitude 7.2 earthquake near Tokyo coast'},
            {'type': 'social', 'text': 'Tsunami warning sirens activated in Yokohama'},
          ]
        }),
      ).timeout(const Duration(seconds: 10));
    } catch (_) {}
  }

  @override
  void dispose() {
    _wsService.removeListener(_scrollToBottom);
    _scrollController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: _wsService,
        builder: (context, child) {
          final isConnected = _wsService.isConnected;
          final logs = _wsService.logs;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                const Text('ANTIGRAVITY TERMINAL',
                    style: TextStyle(color: AuroraTheme.primaryNeon, fontWeight: FontWeight.bold, letterSpacing: 2)),
                const SizedBox(height: 16),

                // Metrics Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.5,
                  physics: const NeverScrollableScrollPhysics(),
                  children: _metrics.map((m) => _buildMetricCard(m)).toList(),
                ),
                const SizedBox(height: 16),

                // Console
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isConnected ? AuroraTheme.primaryNeon.withValues(alpha: 0.5) : Colors.grey.withValues(alpha: 0.3),
                      ),
                      boxShadow: isConnected
                          ? [BoxShadow(color: AuroraTheme.primaryNeon.withValues(alpha: 0.08), blurRadius: 20)]
                          : [],
                    ),
                    child: logs.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.terminal, color: AuroraTheme.textMuted, size: 40),
                                SizedBox(height: 8),
                                Text('Press Connect to stream live agent logs.',
                                    style: TextStyle(color: AuroraTheme.textMuted)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: logs.length,
                            itemBuilder: (context, i) {
                              final log = logs[i];
                              Color c = AuroraTheme.primaryNeon;
                              if (log.contains('ERROR') || log.contains('CRITICAL')) c = AuroraTheme.warning;
                              if (log.contains('✅') || log.contains('STREAM')) c = Colors.greenAccent;
                              if (log.contains('INFO') || log.contains('SYSTEM')) c = Colors.white70;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: Text(log, style: TextStyle(fontFamily: 'monospace', color: c, fontSize: 12)),
                              );
                            },
                          ),
                  ),
                ),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(isConnected ? Icons.wifi : Icons.power_settings_new),
                    label: Text(isConnected ? 'CONNECTED — RE-RUN ANALYSIS' : 'CONNECT TO FASTAPI BACKEND'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isConnected
                          ? Colors.green.withValues(alpha: 0.2)
                          : AuroraTheme.primaryNeon.withValues(alpha: 0.2),
                      foregroundColor: isConnected ? Colors.greenAccent : AuroraTheme.primaryNeon,
                      side: BorderSide(color: isConnected ? Colors.greenAccent : AuroraTheme.primaryNeon),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: isConnected ? _runLiveAnalysis : _connectWebSocket,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(Map<String, dynamic> m) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (m['color'] as Color).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (m['color'] as Color).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(m['icon'] as IconData, color: m['color'] as Color, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(m['value'] as String, style: TextStyle(color: m['color'] as Color, fontWeight: FontWeight.bold, fontSize: 15)),
              Text(m['label'] as String, style: const TextStyle(color: AuroraTheme.textMuted, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
