import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/incident.dart';
import '../providers/incident_provider.dart';
import '../services/fcm_service.dart';
import 'status_update_dialog.dart';
import 'proximity_notification_dialog.dart';
import 'status_history_dialog.dart';

class IncidentCard extends StatelessWidget {
  final Incident incident;
  final VoidCallback? onViewOnMap;

  const IncidentCard({
    super.key, 
    required this.incident,
    this.onViewOnMap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status and actions
            Row(
              children: [
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(incident.statut).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(incident.statut)),
                  ),
                  child: Text(
                    _getStatusLabel(incident.statut),
                    style: TextStyle(
                      color: _getStatusColor(incident.statut),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                // Notification button
                IconButton(
                  icon: Icon(
                    Icons.notifications_active_outlined,
                    color: Colors.orange.shade700,
                  ),
                  onPressed: () => _showProximityNotificationDialog(context),
                  tooltip: 'Notifier les utilisateurs à proximité',
                ),
                // Status update button
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _showStatusUpdateDialog(context),
                  tooltip: 'Modifier le statut',
                ),
                // More actions button
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: ListTile(
                        leading: Icon(Icons.visibility_outlined),
                        title: Text('Voir les détails'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'history',
                      child: ListTile(
                        leading: Icon(Icons.history_outlined),
                        title: Text('Historique'),
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    // Handle menu actions
                    switch (value) {
                      case 'view':
                        _showIncidentDetails(context);
                        break;
                      case 'history':
                        _showStatusHistory(context);
                        break;
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Incident details
            if (incident.incidentTypeName != null) ...[
              Row(
                children: [
                  const Icon(
                    Icons.report_problem_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    incident.incidentTypeName!,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            if (incident.description?.isNotEmpty == true) ...[
              Text(
                incident.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
            ],

            // Location
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${incident.latitude.toStringAsFixed(4)}, ${incident.longitude.toStringAsFixed(4)}',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // User and date info
            Row(
              children: [
                if (incident.userName != null) ...[
                  const Icon(
                    Icons.person_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    incident.userName!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                ],
                const Icon(
                  Icons.access_time_outlined,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(incident.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),

            // Photo indicator
            if (incident.photoUrls.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.photo_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${incident.photoUrls.length} photo(s)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showStatusUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatusUpdateDialog(
        incident: incident,
        onStatusUpdate: (newStatus, commentaire) async {
          try {
            // Get the incident provider and update the status
            final incidentProvider = Provider.of<IncidentProvider>(
              context,
              listen: false,
            );
            
            
            final success = await incidentProvider.updateIncidentStatus(
              incident.id,
              newStatus,
              commentaire: commentaire,
            );
            
            
            if (!success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Erreur lors de la mise à jour du statut'),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Statut mis à jour avec succès'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erreur: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showProximityNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ProximityNotificationDialog(incident: incident),
    ).then((result) {
      if (result is NotificationResult && context.mounted) {
        // Show result dialog
        showDialog(
          context: context,
          builder: (context) => NotificationResultDialog(
            result: result,
            incident: incident,
          ),
        );
      }
    });
  }

  void _showIncidentDetails(BuildContext context) {
    if (onViewOnMap != null) {
      // Use callback to navigate to map
      onViewOnMap!();
    } else {
      // Fallback dialog if no callback provided
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Détails de l\'incident'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID: ${incident.id.substring(0, 8)}'),
              if (incident.description != null) Text('Description: ${incident.description}'),
              Text('Coordonnées: ${incident.latitude.toStringAsFixed(4)}, ${incident.longitude.toStringAsFixed(4)}'),
              if (incident.userName != null) Text('Signalé par: ${incident.userName}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    }
  }

  void _showStatusHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatusHistoryDialog(incident: incident),
    );
  }

  String _getStatusLabel(IncidentStatut status) {
    switch (status) {
      case IncidentStatut.EN_ATTENTE:
        return 'En attente';
      case IncidentStatut.EN_COURS:
        return 'En cours';
      case IncidentStatut.TRAITE:
        return 'Traité';
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inMinutes}min';
    }
  }
}
