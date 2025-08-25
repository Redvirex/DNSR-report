import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import '../models/incident.dart';
import '../services/supabase_service.dart';

class IncidentProvider extends ChangeNotifier {
  final AdminSupabaseService _supabaseService = AdminSupabaseService.instance;

  List<Incident> _incidents = [];
  Map<String, int> _statistics = {};
  bool _isLoading = false;
  String? _errorMessage;
  IncidentStatut? _statusFilter;
  bool _isRefreshing = false;
  RealtimeChannel? _incidentChannel;

  List<Incident> get incidents => _incidents;
  Map<String, int> get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  IncidentStatut? get statusFilter => _statusFilter;

  /// Set status filter
  void setStatusFilter(IncidentStatut? filter) {
    if (_statusFilter == filter) {
      if (kDebugMode) {
        developer.log('Status filter unchanged, skipping reload', name: 'IncidentProvider');
      }
      return;
    }
    
    developer.log('Setting status filter to: $filter', name: 'IncidentProvider');
    _statusFilter = filter;
    notifyListeners();
    Future.microtask(() => loadIncidents(refresh: true));
  }

  /// Clear status filter
  void clearStatusFilter() {
    if (_statusFilter == null) {
      developer.log('Status filter already null, skipping reload', name: 'IncidentProvider');
      return;
    }
    
    developer.log('Clearing status filter', name: 'IncidentProvider');
    _statusFilter = null;
    notifyListeners();
    Future.microtask(() => loadIncidents(refresh: true));
  }

  // Load incidents with filters
  Future<void> loadIncidents({
    int limit = 50,
    int offset = 0,
    DateTime? fromDate,
    DateTime? toDate,
    bool refresh = false,
  }) async {
    // Prevent multiple simultaneous loads
    if (_isLoading && !refresh) {
      if (kDebugMode) {
        developer.log('Already loading, skipping request', name: 'IncidentProvider');
      }
      return;
    }

    try {
      developer.log('Loading incidents - refresh: $refresh, offset: $offset, filter: $_statusFilter', name: 'IncidentProvider');
      
      if (refresh || offset == 0) {
        _isLoading = true;
        notifyListeners();
      }

      final newIncidents = await _supabaseService.getIncidents(
        limit: limit,
        offset: offset,
        fromDate: fromDate,
        toDate: toDate,
        statutFilter: _statusFilter,
      );

      debugPrint('IncidentProvider: Loaded ${newIncidents.length} incidents');

      if (offset == 0 || refresh) {
        _incidents = newIncidents;
      } else {
        _incidents.addAll(newIncidents);
      }

      _errorMessage = null;
      debugPrint('IncidentProvider: Total incidents now: ${_incidents.length}');
    } catch (e) {
      debugPrint('IncidentProvider: Error loading incidents: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load statistics
  Future<void> loadStatistics() async {
    try {
      _statistics = await _supabaseService.getIncidentStatistics();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Get incidents by location bounds (for map)
  Future<List<Incident>> getIncidentsByBounds({
    required double northEastLat,
    required double northEastLng,
    required double southWestLat,
    required double southWestLng,
  }) async {
    try {
      return await _supabaseService.getIncidentsByBounds(
        northEastLat: northEastLat,
        northEastLng: northEastLng,
        southWestLat: southWestLat,
        southWestLng: southWestLng,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Get recent incidents
  Future<void> loadRecentIncidents({int limit = 10}) async {
    try {
      _isLoading = true;
      notifyListeners();

      _incidents = await _supabaseService.getRecentIncidents(limit: limit);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh data
  Future<void> refresh() async {
    // Prevent multiple simultaneous refreshes
    if (_isRefreshing) {
      debugPrint('IncidentProvider: Already refreshing, skipping request');
      return;
    }

    _isRefreshing = true;
    debugPrint('IncidentProvider: Refreshing all data');
    try {
      await Future.wait([
        loadIncidents(refresh: true),
        loadStatistics(),
      ]);
      debugPrint('IncidentProvider: Refresh completed successfully');
    } catch (e) {
      debugPrint('IncidentProvider: Refresh failed: $e');
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isRefreshing = false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Update incident status
  Future<bool> updateIncidentStatus(String incidentId, IncidentStatut newStatus, {String? commentaire}) async {
    try {
      debugPrint('IncidentProvider: Updating incident $incidentId to $newStatus');
      
      final success = await _supabaseService.updateIncidentStatus(incidentId, newStatus, commentaire: commentaire);
      
      if (success) {
        debugPrint('IncidentProvider: Status update successful - real-time subscription will handle UI update');
        
        // Don't update local state immediately - let real-time subscription handle it
        // This ensures all data including updated_at timestamp is properly synced
        
        // Refresh statistics
        loadStatistics();
        
        debugPrint('IncidentProvider: Status update completed successfully');
      } else {
        debugPrint('IncidentProvider: Status update failed');
      }
      
      return success;
    } catch (e) {
      debugPrint('IncidentProvider: Error updating incident status: $e');
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get recent incidents (sorted by creation date)
  List<Incident> get recentIncidents => 
      _incidents.take(10).toList();

  // Start real-time subscription
  void startRealtimeSubscription() {
    if (_incidentChannel != null) {
      debugPrint('IncidentProvider: Real-time subscription already active');
      return;
    }

    debugPrint('IncidentProvider: Starting real-time subscription');
    
    _incidentChannel = _supabaseService.client
        .channel('incident_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'incident',
          callback: (payload) {
            debugPrint('IncidentProvider: Real-time event received: ${payload.eventType}');
            _handleRealtimeEvent(payload);
          },
        )
        .subscribe();
  }

  // Stop real-time subscription
  void stopRealtimeSubscription() {
    if (_incidentChannel != null) {
      debugPrint('IncidentProvider: Stopping real-time subscription');
      _supabaseService.client.removeChannel(_incidentChannel!);
      _incidentChannel = null;
    }
  }

  // Handle real-time events
  void _handleRealtimeEvent(PostgresChangePayload payload) async {
    try {
      switch (payload.eventType) {
        case PostgresChangeEvent.insert:
          await _handleIncidentInsert(payload.newRecord);
          break;
        case PostgresChangeEvent.update:
          await _handleIncidentUpdate(payload.newRecord);
          break;
        case PostgresChangeEvent.delete:
          _handleIncidentDelete(payload.oldRecord);
          break;
        default:
          debugPrint('IncidentProvider: Unhandled event type: ${payload.eventType}');
          break;
      }
      
      // Update statistics after any change
      loadStatistics();
    } catch (e) {
      debugPrint('IncidentProvider: Error handling real-time event: $e');
    }
  }

  // Handle new incident insertion
  Future<void> _handleIncidentInsert(Map<String, dynamic> newRecord) async {
    try {
      // Build the incident with related data
      final photoUrls = await _supabaseService.getIncidentPhotoUrls(newRecord['id'] as String);
      
      String? userName;
      if (newRecord['utilisateur_id'] != null) {
        try {
          final userResponse = await _supabaseService.client
              .from('utilisateurs')
              .select('prenom, nom')
              .eq('id', newRecord['utilisateur_id'])
              .single();
          userName = '${userResponse['prenom']} ${userResponse['nom']}';
        } catch (e) {
          debugPrint('IncidentProvider: Error fetching user for new incident: $e');
        }
      }

      String? incidentTypeName;
      if (newRecord['type_incident'] != null) {
        try {
          final typeResponse = await _supabaseService.client
              .from('type_incident')
              .select('title')
              .eq('id', newRecord['type_incident'])
              .single();
          incidentTypeName = typeResponse['title'];
        } catch (e) {
          debugPrint('IncidentProvider: Error fetching type for new incident: $e');
        }
      }

      final newIncident = Incident.fromJson({
        ...newRecord,
        'photo_urls': photoUrls,
        'user_name': userName,
        'incident_type_name': incidentTypeName,
      });

      // Check if incident matches current filter
      if (_statusFilter == null || newIncident.statut == _statusFilter) {
        _incidents.insert(0, newIncident); // Insert at beginning for newest first
        notifyListeners();
        debugPrint('IncidentProvider: Added new incident: ${newIncident.id}');
      }
    } catch (e) {
      debugPrint('IncidentProvider: Error processing new incident: $e');
    }
  }

  // Handle incident update
  Future<void> _handleIncidentUpdate(Map<String, dynamic> updatedRecord) async {
    try {
      final incidentId = updatedRecord['id'] as String;
      final existingIndex = _incidents.indexWhere((incident) => incident.id == incidentId);
      
      if (existingIndex != -1) {
        // Build updated incident with related data
        final photoUrls = await _supabaseService.getIncidentPhotoUrls(incidentId);
        
        String? userName;
        if (updatedRecord['utilisateur_id'] != null) {
          try {
            final userResponse = await _supabaseService.client
                .from('utilisateurs')
                .select('prenom, nom')
                .eq('id', updatedRecord['utilisateur_id'])
                .single();
            userName = '${userResponse['prenom']} ${userResponse['nom']}';
          } catch (e) {
            debugPrint('IncidentProvider: Error fetching user for updated incident: $e');
          }
        } else {
          // Preserve existing user name if utilisateur_id wasn't updated
          final existingIncident = _incidents[existingIndex];
          userName = existingIncident.userName;
        }

        String? incidentTypeName;
        if (updatedRecord['type_incident'] != null) {
          try {
            final typeResponse = await _supabaseService.client
                .from('type_incident')
                .select('title')
                .eq('id', updatedRecord['type_incident'])
                .single();
            incidentTypeName = typeResponse['title'];
          } catch (e) {
            debugPrint('IncidentProvider: Error fetching type for updated incident: $e');
          }
        } else {
          // Preserve existing incident type name if type_incident wasn't updated
          final existingIncident = _incidents[existingIndex];
          incidentTypeName = existingIncident.incidentTypeName;
        }

        final updatedIncident = Incident.fromJson({
          ...updatedRecord,
          'photo_urls': photoUrls,
          'user_name': userName,
          'incident_type_name': incidentTypeName,
        });

        // Check if updated incident still matches filter
        if (_statusFilter == null || updatedIncident.statut == _statusFilter) {
          _incidents[existingIndex] = updatedIncident;
        } else {
          // Remove incident if it no longer matches filter
          _incidents.removeAt(existingIndex);
        }
        
        notifyListeners();
        debugPrint('IncidentProvider: Updated incident: $incidentId');
      }
    } catch (e) {
      debugPrint('IncidentProvider: Error processing incident update: $e');
    }
  }

  // Handle incident deletion
  void _handleIncidentDelete(Map<String, dynamic> deletedRecord) {
    final incidentId = deletedRecord['id'] as String;
    final existingIndex = _incidents.indexWhere((incident) => incident.id == incidentId);
    
    if (existingIndex != -1) {
      _incidents.removeAt(existingIndex);
      notifyListeners();
      debugPrint('IncidentProvider: Removed incident: $incidentId');
    }
  }

  @override
  void dispose() {
    stopRealtimeSubscription();
    super.dispose();
  }
}
