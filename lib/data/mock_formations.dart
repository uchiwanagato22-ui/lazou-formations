import '../models/formation.dart';

/// Données de démo pour avancer sur les écrans pendant qu'on récupère
/// le vrai catalogue (tarifs, sessions) auprès de Lazou. Le contenu des
/// modules ci-dessous s'appuie sur les standards du marché (bureautique,
/// Sage/comptabilité) — à ajuster dès qu'on a le programme exact de Lazou.
/// Voir programme-formations-lazou.md pour le détail des sources.
final List<Formation> mockFormations = [
  const Formation(
    id: 'compta-generale',
    titre: 'Comptabilité générale',
    domaine: FormationDomaine.comptabilite,
    description:
        'Formation complète en comptabilité générale : théorie (plan comptable, '
        'journal, grand livre, bilan) puis pratique sur 3 logiciels utilisés en '
        'entreprise. Formation confirmée par Lazou.',
    duree: '2 mois théorique + 1 mois pratique',
    modules: [
      'Plan comptable & journal',
      'Excel niveau 3',
      'Gestion commerciale (Sage)',
      'Sage comptable',
    ],
    certifiante: true,
  ),
  const Formation(
    id: 'bureautique',
    titre: 'Informatique / Bureautique',
    domaine: FormationDomaine.informatique,
    description:
        'Programme en 4 modules : Dactylographie, Word (traitement de texte), '
        'Excel (tableur), PowerPoint (présentation). Deux rythmes possibles '
        'selon ta disponibilité — infos confirmées par Lazou.',
    duree: 'Normale : 5 à 6 mois — Accélérée : 45 jours à 2 mois',
    niveau: 'Débutant à avancé',
    modules: ['Dactylographie', 'Word', 'Excel', 'PowerPoint'],
    formulesTarifaires: [
      'Formule Normale — 8 000 MRU/mois, sur 5 ou 6 mois, 3 séances/semaine (6h) '
          '+ 5 000 MRU pour le diplôme en fin de formation + 3 000 MRU de livres',
      'Formule Accélérée — 45 jours ou 2 mois, 2h/jour sauf le vendredi, '
          '18 000 MRU/mois (36 000 MRU au total) + 5 000 MRU diplôme + 3 000 MRU livres '
          '= 44 000 MRU au total',
      'NB : si tu commences un 3ème mois de formation, ce mois est dû en entier',
    ],
  ),
  const Formation(
    id: 'ms-access',
    titre: 'MS Access',
    domaine: FormationDomaine.msAccess,
    description:
        'Bases de données relationnelles : création de tables, formulaires de '
        'saisie, requêtes et rapports.',
    duree: 'À confirmer',
    modules: ['Tables & relations', 'Formulaires', 'Requêtes', 'États/rapports'],
  ),
  const Formation(
    id: 'maintenance',
    titre: 'Maintenance informatique',
    domaine: FormationDomaine.maintenance,
    description:
        'Diagnostic et réparation de pannes courantes, installation de Windows, '
        'notions de réseau et de sécurité informatique.',
    duree: 'À confirmer',
    modules: ['Matériel (hardware)', 'Installation Windows', 'Dépannage', 'Réseaux de base'],
  ),
  const Formation(
    id: 'graphique',
    titre: 'Graphisme / Infographie',
    domaine: FormationDomaine.graphique,
    description:
        'Design graphique appliqué : retouche photo, création vectorielle et '
        'réalisation de supports de communication (flyers, logos, affiches).',
    duree: 'À confirmer',
    modules: ['Notions de design', 'Retouche photo', 'Création vectorielle', 'Supports imprimés'],
  ),
  const Formation(
    id: 'langues',
    titre: 'Les Langues',
    domaine: FormationDomaine.langues,
    description:
        'Français, anglais, arabe — par niveaux, avec un focus sur le '
        'vocabulaire professionnel.',
    duree: 'À confirmer',
    modules: ['Compréhension', 'Expression orale', 'Expression écrite', 'Vocabulaire pro'],
  ),
];
