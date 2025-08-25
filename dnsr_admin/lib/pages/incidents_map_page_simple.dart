import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/incident.dart';
import '../providers/incident_provider.dart';
import '../config/app_config.dart';

class IncidentsMapPage extends StatefulWidget {
  const IncidentsMapPage({super.key});

  @override
  State<IncidentsMapPage> createState() => _IncidentsMapPageState();
}

class _IncidentsMapPageState extends State<IncidentsMapPage> {
  Incident? _selectedIncident;

  @override
  void initState() {
    super.initState();
    _loadIncidents();
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IncidentProvider>(
      builder: (context, incidentProvider, child) {
        final incidents = incidentProvider.incidents;

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
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Text(
                              '${incidents.length} incidents',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[600]),
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
                                      Icon(
                                        Icons.map_outlined,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 16),
                                      Text('No incidents to display on map'),
                                    ],
                                  ),
                                )
                              : Column(
                                  children: [
                                    // Map placeholder with Google Maps info
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.map,
                                              size: 48,
                                              color: Colors.blue,
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'Google Maps Integration',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'API Key Configured: ${AppConfig.googleMapsApiKey.substring(0, 20)}...',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            if (incidents.isNotEmpty)
                                              Text(
                                                'Map Center: ${incidents.first.latitude.toStringAsFixed(4)}, ${incidents.first.longitude.toStringAsFixed(4)}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'Click on incidents below to see details',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ],
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Incidents on Map (${incidents.length})',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: incidents.length,
              itemBuilder: (context, index) {
                final incident = incidents[index];
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
        trailing: Container(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        incident.statut,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(incident.statut),
                        width: 1,
                      ),
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
                ],
              ),
            ),
          ),
        ],
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
