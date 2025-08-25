import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Map customization settings
  bool _showPOI = false;
  bool _showTransit = false;
  bool _showStreetView = false;
  bool _showMapTypeControl = false;
  bool _showFullscreenControl = false;
  
  // General app settings
  bool _enableRealTimeUpdates = true;
  String _defaultMapView = 'roadmap';
  int _refreshInterval = 30; // seconds
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Map settings
      _showPOI = prefs.getBool('map_show_poi') ?? false;
      _showTransit = prefs.getBool('map_show_transit') ?? false;
      _showStreetView = prefs.getBool('map_show_street_view') ?? false;
      _showMapTypeControl = prefs.getBool('map_show_map_type_control') ?? false;
      _showFullscreenControl = prefs.getBool('map_show_fullscreen_control') ?? false;
      
      // General settings
      _enableRealTimeUpdates = prefs.getBool('enable_real_time_updates') ?? true;
      _defaultMapView = prefs.getString('default_map_view') ?? 'roadmap';
      _refreshInterval = prefs.getInt('refresh_interval') ?? 30;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save map settings
    await prefs.setBool('map_show_poi', _showPOI);
    await prefs.setBool('map_show_transit', _showTransit);
    await prefs.setBool('map_show_street_view', _showStreetView);
    await prefs.setBool('map_show_map_type_control', _showMapTypeControl);
    await prefs.setBool('map_show_fullscreen_control', _showFullscreenControl);
    
    // Save general settings
    await prefs.setBool('enable_real_time_updates', _enableRealTimeUpdates);
    await prefs.setString('default_map_view', _defaultMapView);
    await prefs.setInt('refresh_interval', _refreshInterval);
    
    // Show confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _resetSettings() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to their default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await _loadSettings();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings reset to defaults'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.settings, size: 32, color: Colors.blue),
                const SizedBox(width: 12),
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _saveSettings,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Settings'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _resetSettings,
                  icon: const Icon(Icons.restore),
                  label: const Text('Reset to Defaults'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Settings Content
            Expanded(
              child: SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column - Map Settings
                    Expanded(
                      child: _buildMapSettingsCard(),
                    ),
                    
                    const SizedBox(width: 24),
                    
                    // Right Column - General Settings
                    Expanded(
                      child: _buildGeneralSettingsCard(),
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

  Widget _buildMapSettingsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.map, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Map Configuration',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Map Features',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            
            const SizedBox(height: 12),
            
            _buildSwitchTile(
              'Points of Interest',
              'Show businesses, landmarks, and other POIs on the map',
              Icons.location_on,
              _showPOI,
              (value) => setState(() => _showPOI = value),
            ),
            
            _buildSwitchTile(
              'Transit Stations',
              'Display public transportation stations and routes',
              Icons.train,
              _showTransit,
              (value) => setState(() => _showTransit = value),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Map Controls',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            
            const SizedBox(height: 12),
            
            _buildSwitchTile(
              'Street View Control',
              'Enable the Street View pegman control',
              Icons.streetview,
              _showStreetView,
              (value) => setState(() => _showStreetView = value),
            ),
            
            _buildSwitchTile(
              'Map Type Selector',
              'Allow switching between map types (Road, Satellite, etc.)',
              Icons.layers,
              _showMapTypeControl,
              (value) => setState(() => _showMapTypeControl = value),
            ),
            
            _buildSwitchTile(
              'Fullscreen Button',
              'Show button to expand map to fullscreen',
              Icons.fullscreen,
              _showFullscreenControl,
              (value) => setState(() => _showFullscreenControl = value),
            ),
            
            const SizedBox(height: 16),
            
            // Default Map View
            Text(
              'Default Map View',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            
            const SizedBox(height: 8),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _defaultMapView,
                  isExpanded: true,
                  onChanged: (value) => setState(() => _defaultMapView = value!),
                  items: const [
                    DropdownMenuItem(value: 'roadmap', child: Text('Road Map')),
                    DropdownMenuItem(value: 'satellite', child: Text('Satellite')),
                    DropdownMenuItem(value: 'hybrid', child: Text('Hybrid')),
                    DropdownMenuItem(value: 'terrain', child: Text('Terrain')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSettingsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tune, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'General Settings',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Application Behavior',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            
            const SizedBox(height: 12),
            
            _buildSwitchTile(
              'Real-time Updates',
              'Automatically refresh incident data in real-time',
              Icons.refresh,
              _enableRealTimeUpdates,
              (value) => setState(() => _enableRealTimeUpdates = value),
            ),
            
            const SizedBox(height: 16),
            
            // Refresh Interval
            Text(
              'Data Refresh Interval',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _refreshInterval.toDouble(),
                    min: 10,
                    max: 300,
                    divisions: 29,
                    label: '${_refreshInterval}s',
                    onChanged: (value) => setState(() => _refreshInterval = value.round()),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    '${_refreshInterval}s',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Information Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Settings are automatically saved to your browser\'s local storage. '
                    'Map settings will take effect the next time you visit the map page.',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: value ? Colors.green : Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }
}
