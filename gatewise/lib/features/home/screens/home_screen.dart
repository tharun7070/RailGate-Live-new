import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/models.dart';
import '../providers/home_providers.dart';

/// Main home screen with map and gate status overview
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MapViewScreen(),
    const GatesListScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GateProvider>().loadGates();
      context.read<LocationProvider>().getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        elevation: 8,
        shadowColor: AppColors.shadowLight,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_outlined),
            selectedIcon: Icon(Icons.list),
            label: 'Gates',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

/// Map view screen showing gates on map
class MapViewScreen extends StatelessWidget {
  const MapViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Consumer2<GateProvider, LocationProvider>(
      builder: (context, gateProvider, locationProvider, _) {
        return Stack(
          children: [
            // Map placeholder (in production, use GoogleMap widget)
            Container(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map,
                      size: 80,
                      color: isDark 
                          ? AppColors.textTertiaryDark 
                          : AppColors.textTertiaryLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Map View',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark 
                            ? AppColors.textSecondaryDark 
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Google Maps integration will appear here',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark 
                            ? AppColors.textTertiaryDark 
                            : AppColors.textTertiaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Top search bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 4,
                    shadowColor: AppColors.shadowLight,
                    child: InkWell(
                      onTap: () => _showRouteSearch(context),
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: isDark 
                                  ? AppColors.textTertiaryDark 
                                  : AppColors.textTertiaryLight,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Search destination...',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark 
                                    ? AppColors.textTertiaryDark 
                                    : AppColors.textTertiaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Gate count badge
            Positioned(
              top: 80,
              right: 16,
              child: Card(
                elevation: 4,
                shadowColor: AppColors.shadowLight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatRow(
                        context,
                        icon: Icons.check_circle,
                        color: AppColors.statusOpen,
                        count: gateProvider.openGates.length,
                        label: 'Open',
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow(
                        context,
                        icon: Icons.block,
                        color: AppColors.statusClosed,
                        count: gateProvider.closedGates.length,
                        label: 'Closed',
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow(
                        context,
                        icon: Icons.warning_amber,
                        color: AppColors.statusLikelyToClose,
                        count: gateProvider.likelyToCloseGates.length,
                        label: 'Warning',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Selected gate info at bottom
            if (gateProvider.selectedGate != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildSelectedGateCard(context, gateProvider.selectedGate!),
              ),
          ],
        );
      },
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required int count,
    required String label,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedGateCard(BuildContext context, RailwayGate gate) {
    return GestureDetector(
      onTap: () => _showGateDetails(context, gate),
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.cardDark
              : AppColors.cardLight,
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      gate.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    StatusIndicator(status: gate.status),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.read<GateProvider>().clearSelectedGate(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRouteSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RouteSearchSheet(),
    );
  }

  void _showGateDetails(BuildContext context, RailwayGate gate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GateDetailsSheet(gate: gate),
    );
  }
}

/// Route search bottom sheet
class RouteSearchSheet extends StatefulWidget {
  const RouteSearchSheet({super.key});

  @override
  State<RouteSearchSheet> createState() => _RouteSearchSheetState();
}

class _RouteSearchSheetState extends State<RouteSearchSheet> {
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppConstants.bottomSheetRadius),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Find Route',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              
              // Form
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    TextField(
                      controller: _startController,
                      decoration: const InputDecoration(
                        labelText: 'Starting Point',
                        prefixIcon: Icon(Icons.my_location),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _endController,
                      decoration: const InputDecoration(
                        labelText: 'Destination',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _isSearching ? null : _findRoute,
                        icon: _isSearching
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.route),
                        label: Text(_isSearching ? 'Finding Route...' : 'Find Route'),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Quick locations
                    Text(
                      'Recent Locations',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 12),
                    _buildQuickLocation(
                      context,
                      icon: Icons.home,
                      title: 'Home',
                      subtitle: 'Mumbai Central',
                    ),
                    const SizedBox(height: 8),
                    _buildQuickLocation(
                      context,
                      icon: Icons.work,
                      title: 'Work',
                      subtitle: 'Bandra Kurla Complex',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickLocation(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: isDark 
            ? AppColors.primarySkyBlueDark.withOpacity(0.2)
            : AppColors.primarySkyBlueAccent.withOpacity(0.2),
        child: Icon(icon, size: 20, color: AppColors.primarySkyBlue),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 13)),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
      ),
      onTap: () {
        // Set as destination
      },
    );
  }

  Future<void> _findRoute() async {
    if (_startController.text.isEmpty || _endController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both locations')),
      );
      return;
    }

    setState(() => _isSearching = true);

    // Mock route finding - in production, use actual geocoding
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isSearching = false);
    
    // Navigate to route screen
    Navigator.pop(context);
  }
}

/// Gate details bottom sheet
class GateDetailsSheet extends StatelessWidget {
  final RailwayGate gate;

  const GateDetailsSheet({super.key, required this.gate});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppConstants.bottomSheetRadius),
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Gate name and status
              Text(
                gate.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              StatusIndicator(status: gate.status, size: 16),
              
              const SizedBox(height: 24),
              
              // Description
              if (gate.description != null && gate.description!.isNotEmpty) ...[
                Text(
                  'About',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  gate.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
              ],
              
              // Wait time
              if (gate.status == GateStatus.closed && gate.estimatedWaitTime > 0) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.statusClosed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        color: AppColors.statusClosed,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Estimated wait time: ~${gate.estimatedWaitTime} minutes',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.statusClosed,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              // Report status button
              OutlinedButton.icon(
                onPressed: () => _showReportStatusDialog(context),
                icon: const Icon(Icons.edit),
                label: const Text('Report Current Status'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Last updated
              if (gate.lastUpdated != null)
                Center(
                  child: Text(
                    'Last updated: ${_formatLastUpdated(gate.lastUpdated!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark 
                          ? AppColors.textTertiaryDark 
                          : AppColors.textTertiaryLight,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatLastUpdated(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  void _showReportStatusDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ReportStatusSheet(gateId: gate.id, currentStatus: gate.status),
    );
  }
}

/// Report status bottom sheet
class ReportStatusSheet extends StatelessWidget {
  final String gateId;
  final GateStatus currentStatus;

  const ReportStatusSheet({
    super.key,
    required this.gateId,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Report Gate Status',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Help other commuters by reporting the current status',
            style: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 24),
          
          _buildStatusOption(
            context,
            status: GateStatus.open,
            color: AppColors.statusOpen,
            icon: Icons.check_circle,
          ),
          const SizedBox(height: 12),
          _buildStatusOption(
            context,
            status: GateStatus.closed,
            color: AppColors.statusClosed,
            icon: Icons.block,
          ),
          const SizedBox(height: 12),
          _buildStatusOption(
            context,
            status: GateStatus.likelyToClose,
            color: AppColors.statusLikelyToClose,
            icon: Icons.warning_amber,
          ),
          
          const SizedBox(height: 24),
          
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOption(
    BuildContext context, {
    required GateStatus status,
    required Color color,
    required IconData icon,
  }) {
    final isSelected = status == currentStatus;
    
    return InkWell(
      onTap: () {
        context.read<GateProvider>().reportGateStatus(gateId, status);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you for reporting!')),
        );
      },
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : null,
          border: Border.all(
            color: isSelected ? color : (isDark(context) ? AppColors.borderDark : AppColors.borderLight),
          ),
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(
              status.displayName,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : null,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }

  bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}

/// Gates list screen
class GatesListScreen extends StatelessWidget {
  const GatesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GateProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.gates.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.railway_alert,
                  size: 80,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
                ),
                const SizedBox(height: 16),
                Text(
                  'No gates found',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadGates(),
          child: ListView.builder(
            itemCount: provider.gates.length,
            itemBuilder: (context, index) {
              final gate = provider.gates[index];
              return GateInfoCard(
                gate: gate,
                onTap: () => _showGateDetails(context, gate),
                onReportStatus: () => _showReportStatus(context, gate),
              );
            },
          ),
        );
      },
    );
  }

  void _showGateDetails(BuildContext context, RailwayGate gate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GateDetailsSheet(gate: gate),
    );
  }

  void _showReportStatus(BuildContext context, RailwayGate gate) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ReportStatusSheet(gateId: gate.id, currentStatus: gate.status),
    );
  }
}

/// Settings screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();
    
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Settings',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 24),
        
        // Theme toggle
        Card(
          child: SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: Text(isDark ? 'Dark theme enabled' : 'Light theme enabled'),
            value: themeProvider.isDarkMode,
            onChanged: (value) => themeProvider.toggleTheme(),
            secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // About
        Card(
          child: ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About GateWise'),
            subtitle: const Text('Version 1.0.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAboutDialog(context),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Help
        Card(
          child: ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Show help
            },
          ),
        ),
      ],
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'GateWise',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 GateWise. All rights reserved.',
      children: [
        const SizedBox(height: 16),
        const Text('Smart Railway Gate Status & Route Decision App'),
      ],
    );
  }
}
