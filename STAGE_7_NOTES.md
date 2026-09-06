# Lazou Formations — Stage 7

## Travail réalisé

- Catalogue des formations entièrement piloté par Firestore côté accueil/catalogue.
- Administration des formations améliorée :
  - création ;
  - modification ;
  - suppression ;
  - domaine ;
  - durée ;
  - niveau ;
  - prix en MRU ;
  - prochaine session ;
  - modules ;
  - formation certifiante.
- Les identifiants des nouvelles formations sont rendus uniques pour éviter qu'une formation écrase accidentellement une autre formation ayant un titre similaire.
- Le formulaire public d'inscription n'affiche plus une fausse confirmation lorsque l'écriture Firestore échoue : une erreur est affichée et l'utilisateur peut réessayer.
- Les règles Firestore renforcées du Stage 6 sont conservées.

## Configuration Firebase à faire après le code

Ne pas modifier les rôles au hasard. Les rôles sont stockés dans `users/{UID}.role`.

Rôles disponibles :
- `admin`
- `formateur`
- `caissier`
- `etudiant`

Voir la liste exacte des champs recommandés dans la documentation de remise du Stage 7.

## À faire dans une prochaine étape

- rendre la validation d'une inscription plus complète avec affectation à une formation/groupe ;
- finaliser l'administration des groupes et du planning ;
- connecter les supports/cours à Firestore ;
- améliorer le dossier étudiant avec suivi réel présence/notes/certificat ;
- ajouter les contrôles de cohérence et messages d'erreur partout où nécessaire.

## Vérification

Flutter/Dart n'est pas installé dans l'environnement de travail actuel, donc aucun `flutter analyze` ou build réel n'a été prétendu comme réussi.
