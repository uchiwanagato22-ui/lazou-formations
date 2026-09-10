# LAZOU Formations — Stage 14

## Bug hunt + data integrity
- Correction critique de `pointerPresenceUnique()` : la présence d'un étudiant ne remplace plus toute la map `etudiants` de la séance.
- Mise à jour ciblée avec `FieldPath(['etudiants', uid])` pour préserver les présences déjà enregistrées.
- Suite : QA écran par écran et finition premium de tous les rôles.

## Point de vigilance
- Flutter/Dart SDK n'est pas installé dans l'environnement de travail ; le code doit être validé localement avec `flutter analyze` puis un build release.
