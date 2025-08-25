import '../models/incident.dart';

class StatusHistory {
  final String id;
  final String incidentId;
  final IncidentStatut ancienStatut;
  final IncidentStatut nouveauStatut;
  final DateTime updatedAt;
  final String? details;

  StatusHistory({
    required this.id,
    required this.incidentId,
    required this.ancienStatut,
    required this.nouveauStatut,
    required this.updatedAt,
    this.details,
  });

  factory StatusHistory.fromJson(Map<String, dynamic> json) {
    return StatusHistory(
      id: json['id'],
      incidentId: json['incident_id'],
      ancienStatut: _parseStatus(json['ancien_statut']),
      nouveauStatut: _parseStatus(json['nouveau_statut']),
      updatedAt: DateTime.parse(json['updated_at']),
      details: json['details'],
    );
  }

  static IncidentStatut _parseStatus(String statusString) {
    switch (statusString) {
      case 'EN_ATTENTE':
        return IncidentStatut.EN_ATTENTE;
      case 'EN_COURS':
        return IncidentStatut.EN_COURS;
      case 'TRAITE':
        return IncidentStatut.TRAITE;
      default:
        return IncidentStatut.EN_ATTENTE;
    }
  }

  String getStatusLabel(IncidentStatut status) {
    switch (status) {
      case IncidentStatut.EN_ATTENTE:
        return 'En attente';
      case IncidentStatut.EN_COURS:
        return 'En cours';
      case IncidentStatut.TRAITE:
        return 'Traité';
    }
  }
}
