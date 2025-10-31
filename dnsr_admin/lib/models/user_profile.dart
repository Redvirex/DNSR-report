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
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.id,
    this.nom,
    this.prenom,
    required this.email,
    this.role = RoleUtilisateur.CITOYEN,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      nom: json['nom'] as String?,
      prenom: json['prenom'] as String?,
      email: json['email'] as String,
      role: _parseRole(json['role'] as String?),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
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
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? nom,
    String? prenom,
    String? email,
    RoleUtilisateur? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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

  bool get isAdmin => role == RoleUtilisateur.ADMIN;

  @override
  String toString() {
    return 'UserProfile(id: $id, nom: $nom, prenom: $prenom, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.id == id &&
        other.nom == nom &&
        other.prenom == prenom &&
        other.email == email &&
        other.role == role;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      nom,
      prenom,
      email,
      role,
    );
  }
}
