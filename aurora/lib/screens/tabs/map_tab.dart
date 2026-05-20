import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/aurora_theme.dart';
import '../../providers/map_provider.dart';
import '../../core/result.dart';

class MapTab extends ConsumerWidget {
  const MapTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Global center
    final LatLng globalCenter = const LatLng(20.0, 0.0);
    final crisesAsync = ref.watch(mapCrisesProvider);

    return Stack(
      children: [
        // Real interactive map using flutter_map
        crisesAsync.when(
          data: (res) {
            List<Map<String, dynamic>> globalCrises = [];
            if (res is Success<List<dynamic>>) {
              for (var c in res.value) {
                final isMap = c is Map;
                if (!isMap) continue;
                final loc = c['loc'] as List<dynamic>?;
                if (loc != null && loc.length >= 2) {
                  globalCrises.add({
                    'name': c['name'] ?? 'Crisis',
                    'loc': LatLng((loc[0] as num).toDouble(), (loc[1] as num).toDouble()),
                    'color': AuroraTheme.warning,
                  });
                }
              }
            }
            return FlutterMap(
              options: MapOptions(
                initialCenter: globalCenter,
                initialZoom: 2.0, // Zoomed out for a world view
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                ),
                CircleLayer(
                  circles: globalCrises.map((crisis) => CircleMarker(
                    point: crisis['loc'] as LatLng,
                    color: (crisis['color'] as Color).withValues(alpha: 0.3),
                    borderColor: crisis['color'] as Color,
                    borderStrokeWidth: 2,
                    useRadiusInMeter: true,
                    radius: 300000, // 300km radius for global visibility
                  )).toList(),
                ),
                MarkerLayer(
                  markers: globalCrises.map((crisis) => Marker(
                    point: crisis['loc'] as LatLng,
                    width: 40,
                    height: 40,
                    child: Icon(Icons.warning, color: crisis['color'] as Color, size: 30),
                  )).toList(),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AuroraTheme.primaryNeon)),
          error: (err, stack) => Center(child: Text('Map Error: $err', style: const TextStyle(color: AuroraTheme.warning))),
        ),

        // Floating Overlay HUD
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 60), // AppBar padding
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AuroraTheme.surface.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.public, color: AuroraTheme.primaryNeon),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text('Tracking: GLOBAL CRISIS NETWORK (USGS LIVE)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: AuroraTheme.warning, borderRadius: BorderRadius.circular(8)),
                            child: const Text('DEFCON 3', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
