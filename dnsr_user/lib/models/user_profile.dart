enum RoleUtilisateur {
  CITOYEN('CITOYEN'),
  ADMIN('ADMIN');

  const RoleUtilisateur(this.value);
  final String value;

  @override
  String toString() => value;
}

class UserProfile {
  final String id;
  final String? nom;
  final String? prenom;
  final String email;
  final RoleUtilisateur role;
  final double? latitude;
  final double? longitude;
  final DateTime? updatedAt;
  final String? fcmToken;

  const UserProfile({
    required this.id,
    this.nom,
    this.prenom,
    required this.email,
    this.role = RoleUtilisateur.CITOYEN,
    this.latitude,
    this.longitude,
    this.updatedAt,
    this.fcmToken,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      nom: json['nom'] as String?,
      prenom: json['prenom'] as String?,
      email: json['email'] as String,
      role: _parseRole(json['role'] as String?),
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      fcmToken: json['fcm_token'] as String?,
    );
  }

  static RoleUtilisateur _parseRole(String? role) {
    switch (role) {
      case 'ADMIN':
        return RoleUtilisateur.ADMIN;
      case 'CITOYEN':
      default:
        return RoleUtilisateur.CITOYEN;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'role': role.name,
      'latitude': latitude,
      'longitude': longitude,
      'updated_at': updatedAt?.toIso8601String(),
      'fcm_token': fcmToken,
    };
  }

  /// Creates a copy of this UserProfile with optionally updated fields
  /// Used for immutable updates to user profile data
  UserProfile copyWith({
    String? id,
    String? nom,
    String? prenom,
    String? email,
    RoleUtilisateur? role,
    double? latitude,
    double? longitude,
    DateTime? updatedAt,
    String? fcmToken,
  }) {
    return UserProfile(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      role: role ?? this.role,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      updatedAt: updatedAt ?? this.updatedAt,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  String get fullName {
    if (nom == null && prenom == null) return '';
    return '${prenom ?? ''} ${nom ?? ''}'.trim();
  }

  bool get isProfileComplete {
    return nom != null &&
        nom!.isNotEmpty &&
        prenom != null &&
        prenom!.isNotEmpty;
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, nom: $nom, prenom: $prenom, email: $email, role: $role, latitude: $latitude, longitude: $longitude, fcmToken: $fcmToken)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.id == id &&
        other.nom == nom &&
        other.prenom == prenom &&
        other.email == email &&
        other.role == role &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      nom,
      prenom,
      email,
      role,
      latitude,
      longitude,
    );
  }
}
