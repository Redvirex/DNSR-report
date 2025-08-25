import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../models/status_history.dart';
import '../services/supabase_service.dart';

class StatusHistoryDialog extends StatefulWidget {
  final Incident incident;

  const StatusHistoryDialog({
    super.key,
    required this.incident,
  });

  @override
  State<StatusHistoryDialog> createState() => _StatusHistoryDialogState();
}

class _StatusHistoryDialogState extends State<StatusHistoryDialog> {
  List<StatusHistory> _history = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final historyData = await AdminSupabaseService.instance
          .getStatusHistory(widget.incident.id);
      
      setState(() {
        _history = historyData
            .map((data) => StatusHistory.fromJson(data))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement de l\'historique: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        height: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.history, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Historique des statuts',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Incident #${widget.incident.id.substring(0, 8)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadHistory,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun historique disponible',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Les changements de statut apparaîtront ici',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Status Section
          Text(
            'Statut Actuel',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          _buildCurrentStatusCard(),
          
          const SizedBox(height: 24),
          
          // History Section
          Row(
            children: [
              Text(
                'Historique',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_history.length}',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Historical entries
          if (_history.isEmpty)
            _buildNoHistoryMessage()
          else
            ..._history.map((history) => _buildHistoryEntry(
              ancienStatut: history.ancienStatut,
              nouveauStatut: history.nouveauStatut,
              updatedAt: history.updatedAt,
              details: history.details,
            )),
        ],
      ),
    );
  }

  Widget _buildCurrentStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200, width: 2),
      ),
      child: Row(
        children: [
          // Large status indicator
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _getStatusColor(widget.incident.statut),
              shape: BoxShape.circle,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Status info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(widget.incident.statut).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _getStatusColor(widget.incident.statut)),
                  ),
                  child: Text(
                    _getStatusLabel(widget.incident.statut),
                    style: TextStyle(
                      color: _getStatusColor(widget.incident.statut),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoHistoryMessage() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.history_outlined,
              size: 32,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'Aucun changement de statut',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'L\'historique apparaîtra ici quand le statut sera modifié',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryEntry({
    required IncidentStatut ancienStatut,
    required IncidentStatut nouveauStatut,
    required DateTime updatedAt,
    required String? details,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getStatusColor(nouveauStatut),
              shape: BoxShape.circle,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(ancienStatut).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _getStatusColor(ancienStatut)),
                      ),
                      child: Text(
                        _getStatusLabel(ancienStatut),
                        style: TextStyle(
                          color: _getStatusColor(ancienStatut),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(nouveauStatut).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _getStatusColor(nouveauStatut)),
                      ),
                      child: Text(
                        _getStatusLabel(nouveauStatut),
                        style: TextStyle(
                          color: _getStatusColor(nouveauStatut),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateTime(updatedAt),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                
                if (details != null && details.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    details,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
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

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inHours > 0) {
      return 'Aujourd\'hui à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }
}
