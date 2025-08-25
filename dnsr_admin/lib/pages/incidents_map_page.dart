import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui;
import 'dart:js' as js;
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/incident.dart';
import '../providers/incident_provider.dart';
import '../services/supabase_service.dart';
import '../config/app_config.dart';

class IncidentsMapPage extends StatefulWidget {
  final Incident? focusIncident;
  
  const IncidentsMapPage({super.key, this.focusIncident});

  @override
  State<IncidentsMapPage> createState() => _IncidentsMapPageState();
}

class _IncidentsMapPageState extends State<IncidentsMapPage> {
  Incident? _selectedIncident;
  js.JsObject? _googleMap;
  IncidentStatut? _statusFilter;
  String? _currentViewType;
  bool _isManualNavigation = false;
  int _lastIncidentCount = 0;
  List<String> _selectedIncidentImages = [];
  bool _loadingImages = false;
  
  final List<js.JsObject> _markers = [];
  
  bool _showPOI = false;
  bool _showTransit = false;
  bool _showStreetView = false;
  bool _showMapTypeControl = false;
  bool _showFullscreenControl = false;
  String _defaultMapView = 'roadmap';

  @override
  void initState() {
    super.initState();
    _loadMapSettings();
    _initializeMap();
    _loadIncidents();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final incidentProvider = Provider.of<IncidentProvider>(context, listen: false);
      _lastIncidentCount = incidentProvider.incidents.length;
      
      if (widget.focusIncident != null) {
        _selectedIncident = widget.focusIncident;
        _focusOnIncidentWhenReady(widget.focusIncident!);
      }
    });
  }

  Future<void> _loadMapSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showPOI = prefs.getBool('map_show_poi') ?? false;
      _showTransit = prefs.getBool('map_show_transit') ?? false;
      _showStreetView = prefs.getBool('map_show_street_view') ?? false;
      _showMapTypeControl = prefs.getBool('map_show_map_type_control') ?? false;
      _showFullscreenControl = prefs.getBool('map_show_fullscreen_control') ?? false;
      _defaultMapView = prefs.getString('default_map_view') ?? 'roadmap';
    });
  }

  // Focus on incident with retry logic to ensure map is ready
  void _focusOnIncidentWhenReady(Incident incident, {int retryCount = 0}) {
    const maxRetries = 10;
    const retryDelay = Duration(milliseconds: 500);
    
    if (retryCount >= maxRetries) {
      developer.log('Map focusing failed after $maxRetries retries', name: 'IncidentsMapPage');
      return;
    }
    
    if (mounted && _googleMap != null) {
      _selectIncident(incident);
    } else {
      Future.delayed(retryDelay, () {
        _focusOnIncidentWhenReady(incident, retryCount: retryCount + 1);
      });
    }
  }

  Future<void> refreshMapWithNewSettings() async {
    await _loadMapSettings();
    // Reinitialize the map with new settings
    if (_currentViewType != null) {
      final viewIdMatch = RegExp(r'google-maps-html-(\d+)').firstMatch(_currentViewType!);
      if (viewIdMatch != null) {
        final viewId = int.parse(viewIdMatch.group(1)!);
        _initializeGoogleMap(viewId);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload settings when dependencies change (e.g., when returning from settings page)
    _loadMapSettings();
  }

  @override
  void dispose() {
    // Clean up when leaving the page
    _clearMarkers();
    _googleMap = null;
    super.dispose();
  }

  void _initializeMap() {
    // Generate a unique view type for each page visit
    _currentViewType = 'google-maps-html-${DateTime.now().millisecondsSinceEpoch}';
    
    // Register view factory for Google Maps
    ui.platformViewRegistry.registerViewFactory(
      _currentViewType!,
      (int viewId) => _createMapElement(viewId),
    );
  }

  

  web.HTMLDivElement _createMapElement(int viewId) {
    final mapDiv = web.HTMLDivElement()
      ..id = 'map-$viewId'
      ..style.width = '100%'
      ..style.height = '100%';

    // Load Google Maps JavaScript API
    _loadGoogleMapsScript(() {
      _initializeGoogleMap(viewId);
    });

    return mapDiv;
  }

  void _loadGoogleMapsScript(Function onLoaded) {
    // Check if Google Maps is already loaded
    if (js.context.hasProperty('google') && 
        js.context['google'].hasProperty('maps')) {
      onLoaded();
      return;
    }


    // Create script element
    final script = web.HTMLScriptElement();
    script.async = true;
    script.src = 'https://maps.googleapis.com/maps/api/js?key=${AppConfig.googleMapsApiKey}&loading=async&libraries=places';
    
    // Set up callback
    final callbackName = 'initGoogleMaps${DateTime.now().millisecondsSinceEpoch}';
    js.context[callbackName] = () {
      onLoaded();
      js.context.deleteProperty(callbackName);
    };
    
    script.src += '&callback=$callbackName';
    web.document.head!.append(script);
  }

  void _initializeGoogleMap(int viewId) {
    // Reset the map reference since we're creating a new one
    _googleMap = null;
    
    // Wait a bit for the widget to be mounted and incidents to load
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      
      final incidentProvider = Provider.of<IncidentProvider>(context, listen: false);
      final incidents = incidentProvider.incidents;

      if (incidents.isEmpty) {
        // If incidents are still loading, try again later
        Future.delayed(const Duration(milliseconds: 2000), () {
          if (mounted) _initializeGoogleMap(viewId);
        });
        return;
      }

      // Calculate center point
      double centerLat = incidents.map((i) => i.latitude).reduce((a, b) => a + b) / incidents.length;
      double centerLng = incidents.map((i) => i.longitude).reduce((a, b) => a + b) / incidents.length;

      // Create map with settings from SharedPreferences
      final mapOptions = js.JsObject.jsify({
        'center': {'lat': centerLat, 'lng': centerLng},
        'zoom': 10,
        'mapTypeId': _defaultMapView,
        
        // Apply user-configured controls
        'disableDefaultUI': true,
        'zoomControl': true,
        'mapTypeControl': _showMapTypeControl,
        'scaleControl': false,
        'streetViewControl': _showStreetView,
        'rotateControl': false,
        'fullscreenControl': _showFullscreenControl,
        
        // Map interaction settings
        'gestureHandling': 'cooperative',
        'disableDoubleClickZoom': false,
        'scrollwheel': true,
        'draggable': true,
        'disableDefaultContextMenu': true,
        'backgroundColor': '#f5f5f5',
        'clickableIcons': false,
        
        // Position zoom control
        'zoomControlOptions': {
          'position': js.context['google']['maps']['ControlPosition']['TOP_RIGHT']
        },
        
        // Apply custom map styles based on settings
        'styles': _getMapStyles(),
      });

      final mapDiv = web.document.getElementById('map-$viewId');
      if (mapDiv == null) {
        // Try again if the div isn't ready yet
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _initializeGoogleMap(viewId);
        });
        return;
      }
      
      try {
        _googleMap = js.JsObject(js.context['google']['maps']['Map'], [mapDiv, mapOptions]);

        // Add markers for each incident
        final filteredIncidents = _getFilteredIncidents(incidents);
        for (int i = 0; i < filteredIncidents.length; i++) {
          final incident = filteredIncidents[i];
          _addMarker(_googleMap!, incident, i + 1);
        }
        
        developer.log('Google Maps initialized successfully', name: 'IncidentsMapPage');
      } catch (e) {
        developer.log('Error initializing Google Maps: $e', name: 'IncidentsMapPage', error: e);
        // Retry after a delay
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) _initializeGoogleMap(viewId);
        });
      }
    });
  }

  void _addMarker(js.JsObject map, Incident incident, int markerNumber) {
    final statusColor = _getMarkerColor(incident.statut);
    
    final markerOptions = js.JsObject.jsify({
      'position': {'lat': incident.latitude, 'lng': incident.longitude},
      'map': map,
      'title': 'Incident #${incident.id.substring(0, 8)} - ${_getStatusText(incident.statut)}',
      'label': {
        'text': markerNumber.toString(),
        'color': 'white',
        'fontWeight': 'bold',
      },
      'icon': {
        'url': 'https://maps.google.com/mapfiles/ms/icons/$statusColor-dot.png',
        'scaledSize': js.JsObject(js.context['google']['maps']['Size'], [40, 40]),
      }
    });

    final marker = js.JsObject(js.context['google']['maps']['Marker'], [markerOptions]);
    
    // Store marker reference for later cleanup
    _markers.add(marker);

    // Add click listener
    final infoWindow = js.JsObject(js.context['google']['maps']['InfoWindow'], [
      js.JsObject.jsify({
        'content': _buildInfoWindowContent(incident),
      })
    ]);

    js.context['google']['maps']['event'].callMethod('addListener', [
      marker,
      'click',
      () {
        infoWindow.callMethod('open', [map, marker]);
        // Also select the incident in Flutter
        setState(() {
          _selectedIncident = incident;
        });
      }
    ]);
  }

  String _buildInfoWindowContent(Incident incident) {
    return '''
      <div style="max-width: 200px;">
        <h3 style="margin: 0 0 8px 0; color: ${_getStatusColor(incident.statut).toARGB32().toRadixString(16).substring(2)};">
          Incident #${incident.id.substring(0, 8)}
        </h3>
        <p style="margin: 4px 0;"><strong>Status:</strong> ${_getStatusText(incident.statut)}</p>
        ${incident.description != null ? '<p style="margin: 4px 0;"><strong>Description:</strong> ${incident.description}</p>' : ''}
        <p style="margin: 4px 0;"><strong>Location:</strong> ${incident.latitude.toStringAsFixed(4)}, ${incident.longitude.toStringAsFixed(4)}</p>
        ${incident.userName != null ? '<p style="margin: 4px 0;"><strong>Reported by:</strong> ${incident.userName}</p>' : ''}
      </div>
    ''';
  }

  String _getMarkerColor(IncidentStatut status) {
    switch (status) {
      case IncidentStatut.EN_ATTENTE:
        return 'orange';
      case IncidentStatut.EN_COURS:
        return 'blue';
      case IncidentStatut.TRAITE:
        return 'green';
    }
  }

  // Generate map styles based on user settings
  List<Map<String, dynamic>> _getMapStyles() {
    List<Map<String, dynamic>> styles = [];
    
    // Hide points of interest if disabled
    if (!_showPOI) {
      styles.addAll([
        {
          'featureType': 'poi',
          'stylers': [
            {'visibility': 'off'}
          ]
        },
        {
          'featureType': 'poi.business',
          'stylers': [
            {'visibility': 'off'}
          ]
        },
        {
          'featureType': 'poi.park',
          'elementType': 'labels.text',
          'stylers': [
            {'visibility': 'off'}
          ]
        },
        {
          'featureType': 'poi.school',
          'stylers': [
            {'visibility': 'off'}
          ]
        },
        {
          'featureType': 'poi.government',
          'stylers': [
            {'visibility': 'off'}
          ]
        },
        {
          'featureType': 'poi.medical',
          'stylers': [
            {'visibility': 'off'}
          ]
        },
        {
          'featureType': 'poi.place_of_worship',
          'stylers': [
            {'visibility': 'off'}
          ]
        },
      ]);
    }
    
    // Hide transit stations and lines if disabled
    if (!_showTransit) {
      styles.addAll([
        {
          'featureType': 'transit',
          'stylers': [
            {'visibility': 'off'}
          ]
        },
        {
          'featureType': 'transit.station',
          'stylers': [
            {'visibility': 'off'}
          ]
        },
      ]);
    }
    
    // Always apply some basic styling for better appearance
    styles.addAll([
      // Simplify road labels
      {
        'featureType': 'road',
        'elementType': 'labels.text',
        'stylers': [
          {'visibility': 'simplified'}
        ]
      },
      
      // Customize water color
      {
        'featureType': 'water',
        'stylers': [
          {'color': '#a2d2ff'}
        ]
      },
      
      // Customize landscape color
      {
        'featureType': 'landscape',
        'stylers': [
          {'color': '#f8f9fa'}
        ]
      },
    ]);
    
    return styles;
  }

  Future<void> _loadIncidents() async {
    final incidentProvider = Provider.of<IncidentProvider>(
      context,
      listen: false,
    );
    if (incidentProvider.incidents.isEmpty) {
      await incidentProvider.loadIncidents();
    }
  }

  void _selectIncident(Incident incident) {
    setState(() {
      _selectedIncident = incident;
      _loadingImages = true;
      _selectedIncidentImages = [];
    });
    
    // Load incident images
    _loadIncidentImages(incident.id);
    
    // Snap map to incident location
    _snapMapToIncident(incident);
  }

  Future<void> _loadIncidentImages(String incidentId) async {
    try {
      final imageUrls = await AdminSupabaseService.instance.getIncidentPhotoUrls(incidentId);
      
      if (mounted) {
        setState(() {
          _selectedIncidentImages = imageUrls;
          _loadingImages = false;
        });
        
        if (kDebugMode && imageUrls.isNotEmpty) {
          developer.log('Loaded ${imageUrls.length} images for incident', name: 'IncidentsMapPage');
        }
      }
    } catch (e) {
      developer.log('Error loading incident images', name: 'IncidentsMapPage', error: e);
      
      if (mounted) {
        setState(() {
          _selectedIncidentImages = [];
          _loadingImages = false;
        });
      }
    }
  }

  void _snapMapToIncident(Incident incident) {
    if (_googleMap != null) {
      _isManualNavigation = true;
      
      final position = js.JsObject.jsify({
        'lat': incident.latitude,
        'lng': incident.longitude
      });
      
      // Center the map on the incident and zoom in
      _googleMap!.callMethod('setCenter', [position]);
      _googleMap!.callMethod('setZoom', [15]);
      
      // Reset the flag after a delay to allow for future auto-updates
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _isManualNavigation = false;
        }
      });
    }
  }

  List<Incident> _getFilteredIncidents(List<Incident> incidents) {
    if (_statusFilter == null) {
      return incidents;
    }
    return incidents.where((incident) => incident.statut == _statusFilter).toList();
  }

  void _updateFilter(IncidentStatut? filter) {
    setState(() {
      _statusFilter = filter;
    });
    
    // When filter changes, allow auto-centering
    _isManualNavigation = false;
    
    // Refresh the map with filtered incidents
    _refreshMapMarkers();
  }

  void _clearMarkers() {
    for (final marker in _markers) {
      marker.callMethod('setMap', [null]);
    }
    _markers.clear();
  }

  void _refreshMapMarkers() {
    if (_googleMap == null) return;
    
    final incidentProvider = Provider.of<IncidentProvider>(context, listen: false);
    final incidents = incidentProvider.incidents;
    final filteredIncidents = _getFilteredIncidents(incidents);
    
    // Don't auto-center if user is manually navigating or if incident count hasn't changed
    bool shouldAutoCenter = !_isManualNavigation && filteredIncidents.length != _lastIncidentCount;
    _lastIncidentCount = filteredIncidents.length;
    
    // Clear existing markers before adding new ones
    _clearMarkers();
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && _googleMap != null) {
        // Recreate markers for current filtered incidents
        for (int i = 0; i < filteredIncidents.length; i++) {
          final incident = filteredIncidents[i];
          _addMarker(_googleMap!, incident, i + 1);
        }
        
        // Only recalculate center if it's appropriate to do so
        if (shouldAutoCenter && filteredIncidents.isNotEmpty) {
          double centerLat = filteredIncidents.map((i) => i.latitude).reduce((a, b) => a + b) / filteredIncidents.length;
          double centerLng = filteredIncidents.map((i) => i.longitude).reduce((a, b) => a + b) / filteredIncidents.length;
          
          final position = js.JsObject.jsify({
            'lat': centerLat,
            'lng': centerLng
          });
          
          _googleMap!.callMethod('setCenter', [position]);
          _googleMap!.callMethod('setZoom', [10]);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IncidentProvider>(
      builder: (context, incidentProvider, child) {
        final incidents = incidentProvider.incidents;

        // Only refresh map markers when incidents change and user isn't manually navigating
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _googleMap != null && !_isManualNavigation) {
            // Only refresh if the incident count has actually changed
            if (incidents.length != _lastIncidentCount) {
              _refreshMapMarkers();
            }
          }
        });

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              // Map Container
              Expanded(
                flex: _selectedIncident != null ? 2 : 1,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.map, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              'Incidents Map View',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 16),
                            // Real-time status indicator
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green, width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Live',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            
                            // Settings status indicator
                            if (_showPOI || _showTransit || _showStreetView || _showMapTypeControl || _showFullscreenControl)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.blue, width: 1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.settings, size: 12, color: Colors.blue),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'Custom',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            
                            const SizedBox(width: 8),
                            
                            Text(
                              '${incidents.length} incidents',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),

                      // Map Display Area
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                          child: incidents.isEmpty
                              ? const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.map_outlined, size: 64, color: Colors.grey),
                                      SizedBox(height: 16),
                                      Text('No incidents to display on map'),
                                    ],
                                  ),
                                )
                              : Column(
                                  children: [
                                    // Real Google Maps JavaScript API integration
                                    Expanded(
                                      flex: 2,
                                      child: _currentViewType != null
                                          ? HtmlElementView(viewType: _currentViewType!)
                                          : Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                border: Border.all(color: Colors.grey.shade300),
                                              ),
                                              child: const Center(
                                                child: Text(
                                                  'Initializing map...',
                                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                                ),
                                              ),
                                            ),
                                    ),
                                    
                                    // Incidents List
                                    Expanded(
                                      flex: 1,
                                      child: _buildIncidentsList(incidents),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Incident Details Panel
              if (_selectedIncident != null) ...[
                const SizedBox(width: 16),
                Expanded(flex: 1, child: _buildIncidentDetailsPanel()),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildIncidentsList(List<Incident> incidents) {
    final filteredIncidents = _getFilteredIncidents(incidents);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with filter
          Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Incidents on Map (${filteredIncidents.length})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    PopupMenuButton<IncidentStatut?>(
                      icon: Icon(
                        Icons.filter_list,
                        size: 20,
                        color: _statusFilter != null ? Colors.blue : Colors.grey,
                      ),
                      onSelected: _updateFilter,
                      itemBuilder: (context) => [
                        const PopupMenuItem<IncidentStatut?>(
                          value: null,
                          child: Text('All Incidents'),
                        ),
                        PopupMenuItem<IncidentStatut>(
                          value: IncidentStatut.EN_ATTENTE,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const Text('Pending'),
                            ],
                          ),
                        ),
                        PopupMenuItem<IncidentStatut>(
                          value: IncidentStatut.EN_COURS,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const Text('In Progress'),
                            ],
                          ),
                        ),
                        PopupMenuItem<IncidentStatut>(
                          value: IncidentStatut.TRAITE,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const Text('Processed'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (_statusFilter != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(_statusFilter!).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _getStatusColor(_statusFilter!), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Filter: ${_getStatusText(_statusFilter!)}',
                                style: TextStyle(
                                  color: _getStatusColor(_statusFilter!),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => _updateFilter(null),
                                child: Icon(
                                  Icons.close,
                                  size: 12,
                                  color: _getStatusColor(_statusFilter!),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          // Incidents list
          Expanded(
            child: filteredIncidents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.filter_list_off,
                          size: 32,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No incidents match the current filter',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filteredIncidents.length,
                    itemBuilder: (context, index) {
                      final incident = filteredIncidents[index];
                      return _buildIncidentListItem(incident, index + 1);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentListItem(Incident incident, int markerNumber) {
    final statusColor = _getStatusColor(incident.statut);

    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      elevation: 1,
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 12,
          backgroundColor: statusColor,
          child: Text(
            markerNumber.toString(),
            style: const TextStyle(
              color: Colors.white, 
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
        title: Text(
          'Incident #${incident.id.toString().substring(0, 8)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (incident.description != null)
              Text(
                incident.description!.length > 50 
                    ? '${incident.description!.substring(0, 50)}...'
                    : incident.description!,
                style: const TextStyle(fontSize: 11),
              ),
            Text(
              '${incident.latitude.toStringAsFixed(4)}, ${incident.longitude.toStringAsFixed(4)}',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor, width: 0.5),
              ),
              child: Text(
                _getStatusText(incident.statut),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.my_location, size: 16),
              onPressed: () => _selectIncident(incident),
              tooltip: 'View on map',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
          ],
        ),
        onTap: () => _selectIncident(incident),
      ),
    );
  }

  Widget _buildIncidentDetailsPanel() {
    if (_selectedIncident == null) return const SizedBox.shrink();

    final incident = _selectedIncident!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: _getStatusColor(incident.statut),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Incident Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _selectedIncident = null),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(incident.statut).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _getStatusColor(incident.statut), width: 1),
                    ),
                    child: Text(
                      _getStatusText(incident.statut),
                      style: TextStyle(
                        color: _getStatusColor(incident.statut),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Incident ID
                  _buildDetailRow('ID', incident.id.substring(0, 8)),

                  // Description
                  if (incident.description != null)
                    _buildDetailRow('Description', incident.description!),

                  // Coordinates
                  _buildDetailRow(
                    'Coordinates',
                    '${incident.latitude.toStringAsFixed(6)}, ${incident.longitude.toStringAsFixed(6)}',
                  ),

                  // User Information
                  if (incident.userName != null)
                    _buildDetailRow('Reported by', incident.userName!),

                  if (incident.userEmail != null)
                    _buildDetailRow('Email', incident.userEmail!),

                  // Incident Type
                  if (incident.incidentTypeName != null)
                    _buildDetailRow('Type', incident.incidentTypeName!),

                  // Vehicle Type
                  if (incident.vehicleTypeName != null)
                    _buildDetailRow('Vehicle', incident.vehicleTypeName!),

                  // Category
                  if (incident.categoryName != null)
                    _buildDetailRow('Category', incident.categoryName!),

                  // Created Date
                  _buildDetailRow(
                    'Created',
                    incident.createdAt.toString().substring(0, 19),
                  ),

                  const SizedBox(height: 16),

                  // Images Section
                  _buildImagesSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'IMAGES',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 8),
            if (_loadingImages)
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_selectedIncidentImages.length}',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_loadingImages)
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Loading images...',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else if (_selectedIncidentImages.isEmpty)
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                  SizedBox(height: 4),
                  Text(
                    'No images available',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedIncidentImages.length,
              itemBuilder: (context, index) {
                final imageUrl = _selectedIncidentImages[index];
                return Container(
                  margin: EdgeInsets.only(
                    right: index < _selectedIncidentImages.length - 1 ? 8 : 0,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: GestureDetector(
                      onTap: () => _showImageDialog(imageUrl, index),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.broken_image_outlined,
                                color: Colors.grey,
                                size: 32,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showImageDialog(String imageUrl, int initialIndex) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black87,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'Image ${initialIndex + 1} of ${_selectedIncidentImages.length}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Image
              Expanded(
                child: PageView.builder(
                  controller: PageController(initialPage: initialIndex),
                  itemCount: _selectedIncidentImages.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: Image.network(
                        _selectedIncidentImages[index],
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image_outlined,
                                  color: Colors.white,
                                  size: 64,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Failed to load image',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  String _getStatusText(IncidentStatut status) {
    switch (status) {
      case IncidentStatut.EN_ATTENTE:
        return 'Pending';
      case IncidentStatut.EN_COURS:
        return 'In Progress';
      case IncidentStatut.TRAITE:
        return 'Processed';
    }
  }

  Color _getStatusColor(IncidentStatut status) {
    switch (status) {
      case IncidentStatut.EN_ATTENTE:
        return Colors.orange;
      case IncidentStatut.EN_COURS:
        return Colors.blue;
      case IncidentStatut.TRAITE:
        return Colors.green;
    }
  }
}
