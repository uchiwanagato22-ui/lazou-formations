import 'package:cloud_firestore/cloud_firestore.dart';

enum CategorieDepense { salaires, loyer, internet, electricite, materiel, marketing, transport, autre }

extension CategorieDepenseX on CategorieDepense {
  String get label => switch (this) {
    CategorieDepense.salaires => 'Salaires',
    CategorieDepense.loyer => 'Loyer',
    CategorieDepense.internet => 'Internet',
    CategorieDepense.electricite => 'Électricité',
    CategorieDepense.materiel => 'Matériel',
    CategorieDepense.marketing => 'Marketing',
    CategorieDepense.transport => 'Transport',
    CategorieDepense.autre => 'Autre',
  };
}

class Depense {
  final String id;
  final String libelle;
  final double montant;
  final CategorieDepense categorie;
  final String? note;
  final String enregistrePar;
  final DateTime? date;

  const Depense({required this.id, required this.libelle, required this.montant, required this.categorie, required this.enregistrePar, this.note, this.date});

  Map<String, dynamic> toMap() => {
    'libelle': libelle,
    'montant': montant,
    'categorie': categorie.name,
    'note': note,
    'enregistrePar': enregistrePar,
    'date': FieldValue.serverTimestamp(),
  };

  factory Depense.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final ts = d['date'];
    return Depense(
      id: doc.id,
      libelle: (d['libelle'] ?? '').toString(),
      montant: (d['montant'] as num?)?.toDouble() ?? 0,
      categorie: CategorieDepense.values.firstWhere((e) => e.name == d['categorie'], orElse: () => CategorieDepense.autre),
      note: d['note']?.toString(),
      enregistrePar: (d['enregistrePar'] ?? '').toString(),
      date: ts is Timestamp ? ts.toDate() : null,
    );
  }
}
