# Stage 10 — Recouvrement et suivi des impayés

- Ajout de l'écran admin « Recouvrement ».
- Calcul en temps réel du reste à payer : montantDu de l'étudiant moins la somme de ses paiements.
- Filtre « seulement les impayés » et recherche par nom/email/téléphone/formation.
- Classement des étudiants par montant restant le plus élevé.
- Bouton « Encaisser » avec étudiant pré-sélectionné.
- Aucun nouveau champ de solde n'est stocké : une seule source de vérité est conservée dans Firestore.
- Le tableau de bord admin distingue désormais « Paiements » (historique) et « Recouvrement » (action sur les soldes).
- Version cible : 1.4.0+9.
