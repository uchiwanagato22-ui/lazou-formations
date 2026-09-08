# Stage 10 — Correctifs navigation, authentification et données

- Connexion étudiant : redirection immédiate vers l'espace étudiant, sans retour Android.
- Connexion staff : redirection immédiate selon le rôle (admin, formateur, caissier), sans retour Android.
- Le rôle Firebase est chargé avant la fin des méthodes de connexion pour éviter une redirection sur un rôle encore null.
- Déconnexion ajoutée/corrigée pour étudiant, admin, formateur et caissier.
- Planning étudiant : erreurs Firestore désormais visibles au lieu d'un écran qui semble simplement vide.
- Paiements étudiant : erreurs Firestore désormais visibles au lieu d'un historique silencieusement vide.
- Vérification du profil étudiant avant lecture du planning/paiements.
- Version 1.6.1+12.

Vérification locale à faire sur le PC :
flutter pub get
flutter analyze
flutter build apk --release
