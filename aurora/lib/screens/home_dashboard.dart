import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/aurora_theme.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/agents_tab.dart';
import 'tabs/map_tab.dart';
import 'tabs/analytics_tab.dart';
import 'tabs/resources_tab.dart';
import 'tabs/system_tab.dart';
import 'tabs/assistant_tab.dart';
import '../core/locator.dart';
import '../services/websocket_service.dart';
import '../providers/auth_provider.dart';

class HomeDashboard extends ConsumerStatefulWidget {
  const HomeDashboard({super.key});

  @override
  ConsumerState<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends ConsumerState<HomeDashboard> {
  int _currentIndex = 0;
  late final WebSocketService _wsService;
  late final List<Widget> _tabs;
  final GlobalKey<ResourcesTabState> _resourcesTabKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _wsService = getIt<WebSocketService>();
    _wsService.criticalAlert.addListener(_onCriticalAlert);
    _tabs = [
      const DashboardTab(),
      const AgentsTab(),
      const MapTab(),
      const AnalyticsTab(),
      ResourcesTab(key: _resourcesTabKey),
      const AssistantTab(),
      const SystemTab(),
    ];
  }

  @override
  void dispose() {
    _wsService.criticalAlert.removeListener(_onCriticalAlert);
    super.dispose();
  }

  void _onCriticalAlert() {
    final alert = _wsService.criticalAlert.value;
    if (alert != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(alert, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ],
          ),
          backgroundColor: AuroraTheme.warning,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  static const List<Map<String, dynamic>> _navItems = [
    {'label': 'Dashboard', 'icon': Icons.dashboard_rounded, 'tab': 0},
    {'label': 'Agents',    'icon': Icons.memory_rounded,    'tab': 1},
    {'label': 'Map',       'icon': Icons.map_rounded,       'tab': 2},
    {'label': 'Analytics', 'icon': Icons.insights_rounded,   'tab': 3},
  ];

  static const List<Map<String, dynamic>> _drawerExtra = [
    {'label': 'Resources', 'icon': Icons.airport_shuttle_rounded, 'tab': 4},
    {'label': 'AI Copilot','icon': Icons.psychology_rounded,      'tab': 5},
    {'label': 'System',    'icon': Icons.settings_rounded,        'tab': 6},
  ];

  String _getTitle() {
    const titles = [
      'GLOBAL DASHBOARD',
      'ANTIGRAVITY AGENTS',
      'LIVE CRISIS MAP',
      'GLOBAL ANALYTICS',
      'RESOURCE DEPLOYMENT',
      'AI COPILOT',
      'SYSTEM TERMINAL',
    ];
    return titles[_currentIndex];
  }

  void _goTo(int tab) {
    setState(() => _currentIndex = tab);
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Show FAB only on resources tab
    final showFab = _currentIndex == 4;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AuroraTheme.background,
      appBar: AppBar(
        title: Text(_getTitle(), style: const TextStyle(fontSize: 15, letterSpacing: 1.5)),
        actions: [
          // Defcon badge
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AuroraTheme.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AuroraTheme.warning.withValues(alpha: 0.7)),
            ),
            child: const Text('DEFCON 3', style: TextStyle(color: AuroraTheme.warning, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_active_rounded, color: AuroraTheme.warning),
            onPressed: _showAlerts,
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: IndexedStack(index: _currentIndex, children: _tabs),
      floatingActionButton: showFab
          ? FloatingActionButton.extended(
              onPressed: () {
                _resourcesTabKey.currentState?.showDeployDialog();
              },
              backgroundColor: AuroraTheme.primaryNeon,
              foregroundColor: Colors.black,
              icon: const Icon(Icons.rocket_launch),
              label: const Text('DEPLOY UNIT', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  void _showAlerts() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AuroraTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ACTIVE GLOBAL ALERTS', style: TextStyle(color: AuroraTheme.primaryNeon, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 16),
            _buildAlertTile('🌊 Tsunami warning — Pacific Coast (Japan)', AuroraTheme.warning),
            _buildAlertTile('🔥 Wildfire escalation — California Zone 7', AuroraTheme.warning),
            _buildAlertTile('⚡ Grid failure detected — Greater London', AuroraTheme.secondaryNeon),
            _buildAlertTile('🌍 Seismic activity — Indonesian archipelago', Colors.orangeAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertTile(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(text, style: TextStyle(color: color)),
    );
  }



  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AuroraTheme.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AuroraTheme.surface,
                border: Border(bottom: BorderSide(color: AuroraTheme.primaryNeon.withValues(alpha: 0.2))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.public_rounded, color: AuroraTheme.primaryNeon, size: 42),
                  const SizedBox(height: 12),
                  const Text('AURORA', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 3)),
                  const Text('World Crisis Response Network', style: TextStyle(color: AuroraTheme.textMuted, fontSize: 11)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AuroraTheme.primaryNeon.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AuroraTheme.primaryNeon.withValues(alpha: 0.4)),
                    ),
                    child: const Text('ANTIGRAVITY V3 TITAN', style: TextStyle(color: AuroraTheme.primaryNeon, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            // Main nav
            const SizedBox(height: 8),
            for (final item in _navItems)
              _buildDrawerTile(item['icon'] as IconData, item['label'] as String, item['tab'] as int),
            const Divider(color: Colors.white12, indent: 16, endIndent: 16),
            for (final item in _drawerExtra)
              _buildDrawerTile(item['icon'] as IconData, item['label'] as String, item['tab'] as int),
            const Spacer(),
            const Divider(color: Colors.white12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: ref.watch(authProvider).role?.toLowerCase() == 'commander'
                        ? AuroraTheme.primaryNeon
                        : AuroraTheme.secondaryNeon,
                    radius: 18,
                    child: const Icon(Icons.person, color: Colors.black, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ref.watch(authProvider).username ?? 'Field Operator',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          ref.watch(authProvider).role?.toUpperCase() ?? 'AGENT',
                          style: const TextStyle(color: AuroraTheme.textMuted, fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: AuroraTheme.warning, size: 20),
                    onPressed: () {
                      ref.read(authProvider.notifier).logout();
                    },
                    tooltip: 'Logout',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerTile(IconData icon, String title, int tab) {
    final isSelected = _currentIndex == tab;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AuroraTheme.primaryNeon : AuroraTheme.textMuted, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : AuroraTheme.textMuted,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AuroraTheme.primaryNeon.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      onTap: () => _goTo(tab),
    );
  }

  Widget _buildBottomNav() {
    final bottomIndex = _currentIndex < 4 ? _currentIndex : 0;
    return Container(
      decoration: BoxDecoration(
        color: AuroraTheme.background.withValues(alpha: 0.95),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: bottomIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: AuroraTheme.primaryNeon,
        unselectedItemColor: AuroraTheme.textMuted,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        items: [
          for (final item in _navItems)
            BottomNavigationBarItem(
              icon: Icon(item['icon'] as IconData),
              label: item['label'] as String,
            ),
        ],
      ),
    );
  }
}
