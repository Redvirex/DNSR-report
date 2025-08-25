import 'package:flutter/material.dart';
import '../models/incident.dart';

class StatusFilterChip extends StatelessWidget {
  final IncidentStatut? selectedStatus;
  final Function(IncidentStatut?) onStatusChanged;

  const StatusFilterChip({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // All incidents chip
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: const Text('Tous'),
              selected: selectedStatus == null,
              onSelected: (selected) {
                if (selected) {
                  onStatusChanged(null);
                }
              },
              backgroundColor: Colors.grey.shade100,
              selectedColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            ),
          ),
          // Status filter chips
          ...IncidentStatut.values.map(
            (status) => Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Text(_getStatusLabel(status)),
                selected: selectedStatus == status,
                onSelected: (selected) {
                  onStatusChanged(selected ? status : null);
                },
                backgroundColor: _getStatusColor(status).withValues(alpha: 0.1),
                selectedColor: _getStatusColor(status).withValues(alpha: 0.3),
                checkmarkColor: _getStatusColor(status),
              ),
            ),
          ),
        ],
      ),
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
}
