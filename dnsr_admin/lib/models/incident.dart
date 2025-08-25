enum IncidentStatut {
  EN_ATTENTE('EN_ATTENTE'),
  EN_COURS('EN_COURS'),
  TRAITE('TRAITE');

  const IncidentStatut(this.value);
  final String value;

  @override
  String toString() => value;
}

class Incident {
  final String id;
  final String utilisateurId;
  final int typeIncidentId;
  final int? typeVehiculeId;
  final String? description;
  final double latitude;
  final double longitude;
  final IncidentStatut statut;
  final DateTime createdAt;
  final List<String> photoUrls;
  
  final String? userName;
  final String? userEmail;
  final String? incidentTypeName;
  final String? vehicleTypeName;
  final String? categoryName;

  const Incident({
    required this.id,
    required this.utilisateurId,
    required this.typeIncidentId,
    this.typeVehiculeId,
    this.description,
    required this.latitude,
    required this.longitude,
    this.statut = IncidentStatut.EN_ATTENTE,
    required this.createdAt,
    this.photoUrls = const [],
    this.userName,
    this.userEmail,
    this.incidentTypeName,
    this.vehicleTypeName,
    this.categoryName,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'] as String,
      utilisateurId: json['utilisateur_id'] as String,
      typeIncidentId: json['type_incident'] as int,
      typeVehiculeId: json['type_vehicule'] as int?,
      description: json['description'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      statut: _parseStatut(json['statut'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
      photoUrls: json['photo_urls'] != null 
          ? List<String>.from(json['photo_urls'] as List)
          : [],
      userName: json['user_name'] as String?,
      userEmail: json['user_email'] as String?,
      incidentTypeName: json['incident_type_name'] as String?,
      vehicleTypeName: json['vehicle_type_name'] as String?,
      categoryName: json['category_name'] as String?,
    );
  }

  static IncidentStatut _parseStatut(String? statut) {
    switch (statut) {
      case 'EN_COURS':
        return IncidentStatut.EN_COURS;
      case 'TRAITE':
        return IncidentStatut.TRAITE;
      case 'EN_ATTENTE':
      default:
        return IncidentStatut.EN_ATTENTE;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'utilisateur_id': utilisateurId,
      'type_incident': typeIncidentId,
      'type_vehicule': typeVehiculeId,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'statut': statut.value,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Incident copyWith({
    String? id,
    String? utilisateurId,
    int? typeIncidentId,
    int? typeVehiculeId,
    String? description,
    double? latitude,
    double? longitude,
    IncidentStatut? statut,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? photoUrls,
    String? userName,
    String? userEmail,
    String? incidentTypeName,
    String? vehicleTypeName,
    String? categoryName,
  }) {
    return Incident(
      id: id ?? this.id,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      typeIncidentId: typeIncidentId ?? this.typeIncidentId,
      typeVehiculeId: typeVehiculeId ?? this.typeVehiculeId,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      statut: statut ?? this.statut,
      createdAt: createdAt ?? this.createdAt,
      photoUrls: photoUrls ?? this.photoUrls,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      incidentTypeName: incidentTypeName ?? this.incidentTypeName,
      vehicleTypeName: vehicleTypeName ?? this.vehicleTypeName,
      categoryName: categoryName ?? this.categoryName,
    );
  }

  String get displayTitle {
    return incidentTypeName ?? 'Incident #${id.substring(0, 8)}';
  }

  String get locationString {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} jour${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} heure${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'À l\'instant';
    }
  }

  @override
  String toString() {
    return 'Incident(id: $id, utilisateurId: $utilisateurId, typeIncidentId: $typeIncidentId, statut: $statut, createdAt: $createdAt)';
  }
}
