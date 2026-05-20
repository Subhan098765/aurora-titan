import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../theme/aurora_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/resources_provider.dart';
import '../../core/result.dart';
import '../../providers/auth_provider.dart';

class ResourcesTab extends ConsumerStatefulWidget {
  const ResourcesTab({super.key});

  @override
  ConsumerState<ResourcesTab> createState() => ResourcesTabState();
}

class ResourcesTabState extends ConsumerState<ResourcesTab> {
  void _refresh() {
    ref.invalidate(resourcesProvider);
  }


  void showDeployDialog() {
    final nameController = TextEditingController();
    final taskController = TextEditingController();
    final callsignController = TextEditingController();
    String selectedType = 'flight';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AuroraTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: StatefulBuilder(
          builder: (ctx, setSheetState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.add_circle, color: AuroraTheme.primaryNeon),
                  const SizedBox(width: 10),
                  const Text('DEPLOY NEW UNIT',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close, color: AuroraTheme.textMuted), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 20),
              _buildInput(nameController, 'Unit Name', Icons.badge),
              const SizedBox(height: 12),
              _buildInput(taskController, 'Mission Task', Icons.task),
              const SizedBox(height: 12),
              _buildInput(callsignController, 'Callsign (e.g. DRN-07)', Icons.tag),
              const SizedBox(height: 16),
              const Text('Unit Type', style: TextStyle(color: AuroraTheme.textMuted)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final type in [
                    {'key': 'flight', 'label': 'Drone', 'icon': Icons.flight},
                    {'key': 'medical_services', 'label': 'EMS', 'icon': Icons.medical_services},
                    {'key': 'local_police', 'label': 'Police', 'icon': Icons.local_police},
                    {'key': 'fire_truck', 'label': 'Fire', 'icon': Icons.fire_truck},
                    {'key': 'security', 'label': 'Military', 'icon': Icons.security},
                  ])
                    GestureDetector(
                      onTap: () => setSheetState(() => selectedType = type['key'] as String),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: selectedType == type['key'] ? AuroraTheme.primaryNeon.withValues(alpha: 0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: selectedType == type['key'] ? AuroraTheme.primaryNeon : Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(type['icon'] as IconData, color: selectedType == type['key'] ? AuroraTheme.primaryNeon : Colors.white54, size: 16),
                            const SizedBox(width: 6),
                            Text(type['label'] as String, style: TextStyle(color: selectedType == type['key'] ? AuroraTheme.primaryNeon : Colors.white54, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.rocket_launch),
                  label: const Text('DEPLOY TO NETWORK'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AuroraTheme.primaryNeon,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final unit = {
                      'name': nameController.text.isEmpty ? 'New Unit' : nameController.text,
                      'task': taskController.text.isEmpty ? 'General Duty' : taskController.text,
                      'callsign': callsignController.text.isEmpty ? 'UNIT-XX' : callsignController.text,
                      'type_icon': selectedType,
                      'eta_minutes': 10,
                      'color_hex': '0xFF00E5FF',
                    };

                    final authState = ref.read(authProvider);
                    final token = authState.token;

                    try {
                      final response = await http.post(
                        Uri.parse('https://aurora-titan-896824917672.europe-west1.run.app/api/v1/resources'),
                        headers: {
                          'Content-Type': 'application/json',
                          if (token != null) 'Authorization': 'Bearer $token',
                        },
                        body: jsonEncode(unit),
                      ).timeout(const Duration(seconds: 3));

                      if (response.statusCode == 200 || response.statusCode == 201) {
                        ref.invalidate(resourcesProvider);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('✅ ${unit['name']} deployed successfully!'),
                              backgroundColor: Colors.green.shade900,
                            ),
                          );
                        }
                      } else {
                        String errMsg = 'Failed to deploy: ${response.statusCode}';
                        try {
                          final data = jsonDecode(response.body);
                          errMsg = data['detail'] ?? errMsg;
                        } catch (_) {}
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('❌ $errMsg'),
                              backgroundColor: AuroraTheme.warning,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('❌ Network error: $e'),
                            backgroundColor: AuroraTheme.warning,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController c, String hint, IconData icon) {
    return TextField(
      controller: c,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AuroraTheme.textMuted),
        prefixIcon: Icon(icon, color: AuroraTheme.textMuted),
        filled: true,
        fillColor: AuroraTheme.background.withValues(alpha: 0.8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white24)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white24)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AuroraTheme.primaryNeon)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resourcesAsync = ref.watch(resourcesProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('LIVE UNIT DEPLOYMENTS',
                    style: TextStyle(color: AuroraTheme.primaryNeon, fontWeight: FontWeight.bold, letterSpacing: 2)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AuroraTheme.primaryNeon.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AuroraTheme.primaryNeon),
                  ),
                  child: resourcesAsync.when(
                    data: (res) {
                      if (res is Success) {
                        return Text('${(res as Success<List<dynamic>>).value.length} ACTIVE',
                            style: const TextStyle(color: AuroraTheme.primaryNeon, fontWeight: FontWeight.bold, fontSize: 12));
                      }
                      return const Text('ERROR', style: TextStyle(color: AuroraTheme.warning, fontWeight: FontWeight.bold, fontSize: 12));
                    },
                    loading: () => const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: AuroraTheme.primaryNeon)),
                    error: (err, stack) => const Text('ERROR', style: TextStyle(color: AuroraTheme.warning, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: resourcesAsync.when(
              data: (res) {
                if (res is Failure) {
                  return Center(child: Text((res as Failure).message, style: const TextStyle(color: AuroraTheme.warning)));
                }
                final units = (res as Success<List<dynamic>>).value;
                return RefreshIndicator(
                  onRefresh: () async => _refresh(),
                  color: AuroraTheme.primaryNeon,
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: units.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final unit = units[index];
                      final isMap = unit is Map;
                      final name = isMap ? (unit['name'] ?? 'Unit') : 'Unit';
                      final task = isMap ? (unit['task'] ?? '') : '';
                      final callsign = isMap ? (unit['callsign'] ?? '') : '';
                      final eta = isMap ? (unit['eta'] ?? unit['eta_minutes'] ?? 0) : 0;
                      final color = isMap && unit['color'] is Color ? unit['color'] as Color : AuroraTheme.primaryNeon;
                      final icon = isMap && unit['icon'] is IconData ? unit['icon'] as IconData : Icons.flight;
                      return _buildUnitTile(name, task, callsign, icon, color, eta as int);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AuroraTheme.primaryNeon)),
              error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: AuroraTheme.warning))),
            ),
          ),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildUnitTile(String name, String task, String callsign, IconData icon, Color color, int eta) {
    final isIdle = eta == 0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AuroraTheme.surface.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isIdle ? Colors.white12 : color.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(task, style: const TextStyle(color: AuroraTheme.textMuted, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(callsign.toString(), style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isIdle ? Colors.transparent : color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isIdle ? Colors.white24 : color),
                ),
                child: Text(
                  isIdle ? 'IDLE' : '${eta}m ETA',
                  style: TextStyle(color: isIdle ? Colors.grey : color, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
