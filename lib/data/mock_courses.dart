import '../models/course_content.dart';

/// Le vrai contenu que l'étudiant consulte DANS l'app à la place d'un livre.
/// Comptabilité générale est développée en premier car c'est la formation
/// confirmée par Lazou. Les autres cours seront enrichis au même format dès
/// qu'on a le programme exact du centre.
final Map<String, Course> mockCourses = {
  'compta-generale': const Course(
    formationId: 'compta-generale',
    lessons: [
      Lesson(
        id: 'plan-comptable',
        titre: 'Le plan comptable',
        resume: 'Les 7 classes de comptes et à quoi elles servent',
        sections: [
          ContentSection(
            texte:
                'Le plan comptable classe toutes les opérations d\'une entreprise '
                'en 7 grandes familles de comptes, numérotées de 1 à 7. C\'est la '
                'base de tout : chaque écriture comptable utilise un compte de '
                'cette liste.',
          ),
          ContentSection(diagramme: DiagramType.planComptable),
          ContentSection(
            titre: 'À retenir',
            puces: [
              'Classes 1 à 5 = éléments du bilan (ce que possède/doit l\'entreprise)',
              'Classes 6 et 7 = éléments du compte de résultat (charges et produits)',
              'Chaque compte a un numéro précis, ex : 601 = achats de marchandises',
            ],
          ),
        ],
      ),
      Lesson(
        id: 'cycle-comptable',
        titre: 'Le cycle comptable',
        resume: 'De la facture au bilan : le chemin d\'une opération',
        sections: [
          ContentSection(
            texte:
                'Chaque opération de l\'entreprise (achat, vente, paiement...) suit '
                'le même parcours avant de se retrouver dans les états financiers '
                'finaux.',
          ),
          ContentSection(diagramme: DiagramType.cycleComptable),
          ContentSection(
            titre: 'Exemple concret',
            texte:
                'Une facture d\'achat (pièce justificative) est d\'abord enregistrée '
                'dans le journal, puis reportée dans le grand livre du fournisseur '
                'concerné, puis reprise dans la balance, et enfin dans le bilan.',
          ),
        ],
      ),
      Lesson(
        id: 'operations-courantes',
        titre: 'Les opérations courantes',
        resume: 'Achats, ventes, banque, caisse',
        sections: [
          ContentSection(
            titre: 'Les 4 grandes catégories',
            puces: [
              'Achats : marchandises, fournitures, services',
              'Ventes : facturation clients, avoirs',
              'Banque : virements, chèques, rapprochement bancaire',
              'Caisse : dépenses et recettes en espèces',
            ],
          ),
        ],
      ),
      Lesson(
        id: 'excel-niveau-3',
        titre: 'Excel niveau 3 (module pratique)',
        resume: 'Tableaux croisés dynamiques et fonctions avancées',
        sections: [
          ContentSection(
            titre: 'Ce que tu vas savoir faire',
            puces: [
              'Créer un tableau croisé dynamique (TCD) à partir de données brutes',
              'Utiliser RECHERCHEV pour croiser des informations entre 2 tableaux',
              'Construire un tableau de bord de gestion simple',
              'Protéger un classeur et ses formules',
            ],
          ),
        ],
      ),
      Lesson(
        id: 'sage-gestion-commerciale',
        titre: 'Sage — Gestion commerciale (module pratique)',
        resume: 'Facturation, stocks, achats/ventes',
        sections: [
          ContentSection(
            titre: 'Ce que tu vas savoir faire',
            puces: [
              'Créer et gérer les fiches clients/fournisseurs',
              'Émettre une facture, un devis, un bon de livraison',
              'Suivre les stocks (entrées/sorties)',
            ],
          ),
        ],
      ),
      Lesson(
        id: 'sage-comptable',
        titre: 'Sage — Comptabilité (module pratique)',
        resume: 'Écritures, rapprochement bancaire, états financiers',
        sections: [
          ContentSection(
            titre: 'Ce que tu vas savoir faire',
            puces: [
              'Paramétrer le plan comptable dans le logiciel',
              'Saisir des écritures et les rapprocher avec la banque',
              'Éditer les états financiers de fin d\'exercice',
              'Préparer une déclaration de TVA',
            ],
          ),
        ],
      ),
    ],
  ),
};
