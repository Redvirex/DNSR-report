import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../models/incident.dart';
import '../providers/admin_auth_provider.dart';
import '../providers/incident_provider.dart';
import '../widgets/dashboard_sidebar.dart';
import '../widgets/incident_stats_cards.dart';
import '../widgets/status_filter_chip.dart';
import '../widgets/incident_card.dart';
import '../widgets/profile_dialog.dart';
import 'incidents_map_page.dart';
import 'users_page.dart';
import 'settings_page.dart';
import 'broadcast_notifications_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0; // Start with Incidents page (index 0)
  bool _hasLoadedInitialData = false;
  IncidentStatut? _dashboardStatusFilter; // Local filter for dashboard incidents
  Incident? _focusIncident; // Incident to focus on map page
  bool _enableRealTimeUpdates = true; // Track real-time setting
  IncidentProvider? _incidentProvider; // Cache provider reference for safe dispose

  final List<String> _pageNames = [
    'Incidents',
    'Map View',
    'Users',
    'Broadcast',
    'Settings',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadInitialData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cache the provider reference for safe use in dispose
    _incidentProvider ??= Provider.of<IncidentProvider>(context, listen: false);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _enableRealTimeUpdates = prefs.getBool('enable_real_time_updates') ?? true;
    });
  }

  @override
  void dispose() {
    // Stop real-time subscription when dashboard is disposed
    _incidentProvider?.stopRealtimeSubscription();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (_hasLoadedInitialData) {
      if (kDebugMode) {
        developer.log('Initial data already loaded, skipping', name: 'DashboardPage');
      }
      return;
    }

    debugPrint('DashboardPage: Loading initial data for incidents');
    final incidentProvider = Provider.of<IncidentProvider>(
      context,
      listen: false,
    );
    
    // Delay the loading to after the build cycle
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await Future.wait([
          incidentProvider.loadIncidents(),
          incidentProvider.loadStatistics(),
        ]);

        // Start real-time subscription since we start on incidents page
        debugPrint(
          'DashboardPage: Starting real-time subscription for initial load',
        );
        incidentProvider.startRealtimeSubscription();

        _hasLoadedInitialData = true;
        debugPrint('DashboardPage: Initial data loaded successfully');
      } catch (e) {
        debugPrint('DashboardPage: Error loading initial data: $e');
      }
    });
  }

  // Helper method to filter incidents locally without affecting provider
  List<Incident> _getFilteredIncidents(List<Incident> incidents) {
    if (_dashboardStatusFilter == null) {
      return incidents;
    }
    return incidents.where((incident) => incident.statut == _dashboardStatusFilter).toList();
  }

  // Navigate to map page with specific incident focused
  void _navigateToMapWithIncident(Incident incident) {
    debugPrint('Navigating to map with incident: #${incident.id.substring(0, 8)}');
    
    setState(() {
      _selectedIndex = 1; // Switch to map page
      _focusIncident = incident; // Store the incident to focus on
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigation vers l\'incident #${incident.id.substring(0, 8)} sur la carte'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Voir',
          onPressed: () {
            // The incident should already be focused when this action is clicked
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          DashboardSidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              debugPrint(
                'DashboardPage: Switching to page $index (${_pageNames[index]})',
              );

              final incidentProvider = Provider.of<IncidentProvider>(
                context,
                listen: false,
              );

              // Stop real-time subscription if leaving incidents or map page
              if ((_selectedIndex == 0 || _selectedIndex == 1) &&
                  (index != 0 && index != 1)) {
                debugPrint(
                  'DashboardPage: Stopping real-time subscription (leaving incidents/map page)',
                );
                incidentProvider.stopRealtimeSubscription();
              }

              // Start real-time subscription if entering incidents or map page
              if ((_selectedIndex != 0 && _selectedIndex != 1) &&
                  (index == 0 || index == 1)) {
                debugPrint(
                  'DashboardPage: Starting real-time subscription (entering incidents/map page)',
                );
                incidentProvider.startRealtimeSubscription();
              }

              // Reload settings when leaving settings page
              if (_selectedIndex == 4 && index != 4) {
                _loadSettings();
              }

              setState(() {
                _selectedIndex = index;
              });
            },
          ),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // App Bar
                Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        Text(
                          _pageNames[_selectedIndex],
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),

                        // Refresh Button - only show when real-time updates are disabled
                        if (!_enableRealTimeUpdates) ...[
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              debugPrint(
                                'DashboardPage: Manual refresh triggered',
                              );
                              final incidentProvider =
                                  Provider.of<IncidentProvider>(
                                    context,
                                    listen: false,
                                  );
                              // Non-blocking refresh
                              Future.microtask(() => incidentProvider.refresh());
                            },
                          ),
                        ],

                        // User Profile
                        Consumer<AdminAuthProvider>(
                          builder: (context, authProvider, child) {
                            return PopupMenuButton<String>(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.blue[100],
                                    child: Text(
                                      authProvider
                                                  .userProfile
                                                  ?.fullName
                                                  .isNotEmpty ==
                                              true
                                          ? authProvider
                                                .userProfile!
                                                .fullName[0]
                                                .toUpperCase()
                                          : 'A',
                                      style: TextStyle(
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        authProvider.userProfile?.fullName ??
                                            'Admin',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        'Administrator',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_drop_down),
                                ],
                              ),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'profile',
                                  child: Row(
                                    children: [
                                      Icon(Icons.person),
                                      SizedBox(width: 8),
                                      Text('Profile'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'settings',
                                  child: Row(
                                    children: [
                                      Icon(Icons.settings),
                                      SizedBox(width: 8),
                                      Text('Settings'),
                                    ],
                                  ),
                                ),
                                const PopupMenuDivider(),
                                const PopupMenuItem(
                                  value: 'logout',
                                  child: Row(
                                    children: [
                                      Icon(Icons.logout, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text(
                                        'Sign Out',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                switch (value) {
                                  case 'logout':
                                    _showLogoutDialog();
                                    break;
                                  case 'profile':
                                    showDialog(
                                      context: context,
                                      builder: (context) => const ProfileDialog(),
                                    );
                                    break;
                                  case 'settings':
                                    setState(() {
                                      _selectedIndex =
                                          4; // Settings page (adjusted index)
                                    });
                                    break;
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Page Content
                Expanded(child: _buildPageContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent() {
    switch (_selectedIndex) {
      case 0: // Incidents
        return _buildIncidentsContent();
      case 1: // Map View
        return _buildMapContent();
      case 2: // Users
        return _buildUsersContent();
      case 3: // Broadcast
        return _buildBroadcastContent();
      case 4: // Settings
        return _buildSettingsContent();
      default:
        return _buildIncidentsContent();
    }
  }

  Widget _buildIncidentsContent() {
    return Consumer<IncidentProvider>(
      builder: (context, incidentProvider, child) {
        final allIncidents = incidentProvider.incidents;
        final filteredIncidents = _getFilteredIncidents(allIncidents);
        
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and stats
              Row(
                children: [
                  Text(
                    'Incidents Dashboard',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Stats cards
              IncidentStatsCards(
                incidents: allIncidents, // Use all incidents for statistics
                isLoading: incidentProvider.isLoading,
              ),

              const SizedBox(height: 24),

              // Filter and incidents list
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filter controls
                    Row(
                      children: [
                        StatusFilterChip(
                          selectedStatus: _dashboardStatusFilter,
                          onStatusChanged: (status) {
                            setState(() {
                              _dashboardStatusFilter = status;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Incidents list header
                    Row(
                      children: [
                        Text(
                          'Incidents',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${filteredIncidents.length}', // Show filtered count
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Incidents content
                    Expanded(
                      child: incidentProvider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : filteredIncidents.isEmpty // Check filtered incidents
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inbox_outlined,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Aucun incident trouvé',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _dashboardStatusFilter != null
                                        ? 'Aucun incident avec ce statut'
                                        : 'Aucun incident enregistré',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.grey.shade500,
                                        ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredIncidents.length,
                              itemBuilder: (context, index) {
                                final incident = filteredIncidents[index];
                                return IncidentCard(
                                  incident: incident,
                                  onViewOnMap: () => _navigateToMapWithIncident(incident),
                                );
                              },
                            ),
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

  Widget _buildMapContent() {
    debugPrint('Building map content with focus incident: ${_focusIncident?.id.substring(0, 8) ?? 'none'}');
    
    final mapPage = IncidentsMapPage(focusIncident: _focusIncident);
    
    // Clear the focus incident after passing it to the map
    if (_focusIncident != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _focusIncident = null;
        });
      });
    }
    
    return mapPage;
  }

  Widget _buildUsersContent() {
    return const UsersPage();
  }

  Widget _buildBroadcastContent() {
    return const BroadcastNotificationsPage();
  }

  Widget _buildSettingsContent() {
    return const SettingsPage();
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<AdminAuthProvider>(context, listen: false).signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
