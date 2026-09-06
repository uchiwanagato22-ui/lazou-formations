import 'package:flutter/material.dart';

/// Domaines de formation proposés par Lazou (d'après l'affiche + les infos reçues).
enum FormationDomaine {
  informatique,
  comptabilite,
  langues,
  maintenance,
  msAccess,
  graphique,
}

extension FormationDomaineLabel on FormationDomaine {
  String get label {
    switch (this) {
      case FormationDomaine.informatique:
        return 'Informatique';
      case FormationDomaine.comptabilite:
        return 'Comptabilité';
      case FormationDomaine.langues:
        return 'Langues';
      case FormationDomaine.maintenance:
        return 'Maintenance';
      case FormationDomaine.msAccess:
        return 'MS Access';
      case FormationDomaine.graphique:
        return 'Graphique';
    }
  }
}

extension FormationDomaineIcon on FormationDomaine {
  IconData get icone {
    switch (this) {
      case FormationDomaine.informatique:
        return Icons.computer;
      case FormationDomaine.comptabilite:
        return Icons.calculate_outlined;
      case FormationDomaine.langues:
        return Icons.language;
      case FormationDomaine.maintenance:
        return Icons.build_outlined;
      case FormationDomaine.msAccess:
        return Icons.storage_outlined;
      case FormationDomaine.graphique:
        return Icons.brush_outlined;
    }
  }
}

extension FormationDomaineValue on FormationDomaine {
  String get value => name;

  static FormationDomaine fromValue(String value) {
    return FormationDomaine.values.firstWhere(
      (d) => d.name == value,
      orElse: () => FormationDomaine.informatique,
    );
  }
}

/// Représente une formation du catalogue Lazou.
/// Les champs marqués "TODO" attendent encore les vraies infos du centre
/// (tarifs, prochaines sessions, etc.) — à remplacer dès qu'on les a.
class Formation {
  final String id;
  final String titre;
  final FormationDomaine domaine;
  final String description;
  final String duree; // ex: "2 mois théorique + 1 mois pratique"
  final List<String> modules; // logiciels/matières couvertes
  final String? niveau;
  final double? prix; // TODO: à confirmer avec Lazou
  final List<String>? formulesTarifaires; // ex: 2 rythmes différents avec prix propres
  final bool certifiante;
  final String? prochaineSession; // TODO: à confirmer

  const Formation({
    required this.id,
    required this.titre,
    required this.domaine,
    required this.description,
    required this.duree,
    required this.modules,
    this.niveau,
    this.prix,
    this.formulesTarifaires,
    this.certifiante = true,
    this.prochaineSession,
  });

  Map<String, dynamic> toMap() => {
        'titre': titre,
        'domaine': domaine.value,
        'description': description,
        'duree': duree,
        'modules': modules,
        'niveau': niveau,
        'prix': prix,
        'formulesTarifaires': formulesTarifaires,
        'certifiante': certifiante,
        'prochaineSession': prochaineSession,
      };

  factory Formation.fromMap(String id, Map<String, dynamic> data) => Formation(
        id: id,
        titre: data['titre'] as String? ?? '',
        domaine: FormationDomaineValue.fromValue(data['domaine'] as String? ?? ''),
        description: data['description'] as String? ?? '',
        duree: data['duree'] as String? ?? '',
        modules: (data['modules'] as List?)?.map((e) => e.toString()).toList() ?? [],
        niveau: data['niveau'] as String?,
        prix: (data['prix'] as num?)?.toDouble(),
        formulesTarifaires: (data['formulesTarifaires'] as List?)?.map((e) => e.toString()).toList(),
        certifiante: data['certifiante'] as bool? ?? true,
        prochaineSession: data['prochaineSession'] as String?,
      );
}
