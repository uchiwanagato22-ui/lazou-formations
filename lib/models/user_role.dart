/// Les rôles de l'app. Stocké sur le document utilisateur Firestore
/// (users/{uid}.role) et lu à la connexion pour rediriger vers le bon espace.
enum UserRole { etudiant, formateur, admin, caissier }

extension UserRoleParsing on UserRole {
  String get value => switch (this) {
        UserRole.etudiant => 'etudiant',
        UserRole.formateur => 'formateur',
        UserRole.admin => 'admin',
        UserRole.caissier => 'caissier',
      };

  static UserRole fromValue(String value) {
    return UserRole.values.firstWhere(
      (r) => r.value == value,
      orElse: () => UserRole.etudiant,
    );
  }
}
