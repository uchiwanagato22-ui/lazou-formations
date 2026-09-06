# LAZOU Formations — Stage 6

## Réalisé
- Catalogue public branché sur Firestore sans fallback automatique vers des données fictives.
- Accueil : formations affichées depuis Firestore, avec états chargement/erreur/vide.
- Suppression des chiffres historiques codés en dur dans le hero de l'accueil.
- Contact téléphone + WhatsApp depuis l'accueil.
- Règles Firestore complétées pour évaluations, annonces, supports, certificats et compteurs.
- Permissions renforcées : un formateur agit uniquement sur les groupes qui lui sont affectés.
- Étudiant limité aux données de son propre groupe pour les supports, annonces et évaluations.
- Certificats lisibles publiquement pour permettre leur vérification sans compte ; création/modification/suppression réservées à l'admin.
- Compteur des certificats réservé à l'admin.

## À faire côté Firebase / configuration
1. Publier `firestore.rules` dans Firebase Console.
2. Vérifier que chaque compte possède le bon `role`.
3. Vérifier les champs `groupeId`, `formationId`, `formateurUid` sur les affectations.
4. Créer les vraies formations dans `formations`.
5. Tester chaque rôle : admin, formateur, caissier, étudiant.
6. Vérifier les index Firestore si Firebase en demande lors d'une requête.

## Étape suivante
- Transformer les programmes de formation en contenu pédagogique Firestore structuré : modules, leçons, supports, quiz et progression.
- Construire un vrai planning basé sur les sessions/groupes.
- Finaliser le workflow inscription -> validation -> affectation.
- Finaliser paiements, reçus et alertes.
