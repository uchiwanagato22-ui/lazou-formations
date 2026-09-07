# Stage 8 — Workflow des inscriptions

- Validation d’une inscription depuis l’espace admin.
- Si la demande est liée à un compte étudiant, la formation est automatiquement affectée.
- Lorsqu’un groupe compatible existe, l’admin peut choisir le groupe ou valider sans groupe.
- Si la demande est publique sans compte lié, elle reste validée et l’admin reçoit une indication qu’un compte étudiant sera nécessaire pour l’affectation automatique.
- Affichage amélioré des demandes : email, compte lié/sans compte, erreurs de chargement et retours d’action.
- Ajout de `getGroupesOnce()` et `validerInscription()` dans `FirestoreService`.
- Version : 1.2.0+7.

Flutter/Dart n’est pas installé dans l’environnement de travail actuel : aucun `flutter analyze` ou build n’a été déclaré comme réussi.
