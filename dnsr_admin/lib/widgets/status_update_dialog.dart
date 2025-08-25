import 'package:flutter/material.dart';
import '../models/incident.dart';

class StatusUpdateDialog extends StatefulWidget {
  final Incident incident;
  final Function(IncidentStatut newStatus, String? commentaire) onStatusUpdate;

  const StatusUpdateDialog({
    super.key,
    required this.incident,
    required this.onStatusUpdate,
  });

  @override
  State<StatusUpdateDialog> createState() => _StatusUpdateDialogState();
}

class _StatusUpdateDialogState extends State<StatusUpdateDialog> {
  IncidentStatut? _selectedStatus;
  final TextEditingController _commentaireController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.incident.statut;
  }

  @override
  void dispose() {
    _commentaireController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier le statut'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current status
            Text(
              'Statut actuel: ${_getStatusLabel(widget.incident.statut)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            
            // Status selection
            const Text(
              'Nouveau statut:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ...IncidentStatut.values.map((status) => RadioListTile<IncidentStatut>(
              title: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(_getStatusLabel(status)),
                ],
              ),
              value: status,
              groupValue: _selectedStatus,
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            )),
            
            const SizedBox(height: 16),
            
            // Comment field
            const Text(
              'Commentaire (optionnel):',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentaireController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Ajouter un commentaire...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () {
            Navigator.of(context).pop();
          },
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isLoading || _selectedStatus == null || _selectedStatus == widget.incident.statut
              ? null
              : _handleStatusUpdate,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Mettre à jour'),
        ),
      ],
    );
  }

  void _handleStatusUpdate() async {
    if (_selectedStatus == null || _selectedStatus == widget.incident.statut) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onStatusUpdate(
        _selectedStatus!,
        _commentaireController.text.trim().isEmpty 
            ? null 
            : _commentaireController.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
