# Stage 9 — Dossier étudiant 360°

- Remplacement des placeholders « À connecter » dans le dossier étudiant admin.
- Présence réelle calculée depuis les feuilles d'appel du groupe : taux, présents, absents, retards.
- Moyenne réelle de l'étudiant calculée depuis les évaluations de son groupe.
- Certificats réels affichés dans le dossier avec accès au rendu du certificat.
- Ajout des méthodes Firestore `watchStatistiquesPresenceEtudiant` et `watchMoyenneEtudiant`.
- Version : 1.3.0+8.

## Vérification
Flutter n'est pas installé dans l'environnement de travail actuel, donc aucun `flutter analyze` ou build n'a été exécuté ici. À faire sur le PC de développement :
`flutter pub get`
`flutter analyze`
puis `flutter build apk --release`.
