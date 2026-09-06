/// Type de diagramme à afficher dans une leçon, en plus du texte.
/// Les diagrammes sont dessinés en Flutter (CustomPaint) — pas d'images
/// à héberger, ça marche même hors-ligne.
enum DiagramType { none, planComptable, cycleComptable }

/// Une section de contenu à l'intérieur d'une leçon : soit un bloc de texte
/// (avec puces optionnelles), soit un diagramme.
class ContentSection {
  final String? titre;
  final String? texte;
  final List<String>? puces;
  final DiagramType diagramme;

  const ContentSection({
    this.titre,
    this.texte,
    this.puces,
    this.diagramme = DiagramType.none,
  });
}

/// Une leçon = l'équivalent d'un chapitre de livre, mais consultable
/// directement dans l'app par l'étudiant, sans rien acheter à côté.
class Lesson {
  final String id;
  final String titre;
  final String resume;
  final List<ContentSection> sections;

  const Lesson({
    required this.id,
    required this.titre,
    required this.resume,
    required this.sections,
  });
}

/// Le cours complet d'une formation = liste de leçons ordonnées.
class Course {
  final String formationId;
  final List<Lesson> lessons;

  const Course({required this.formationId, required this.lessons});
}
