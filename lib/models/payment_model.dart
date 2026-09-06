import 'package:cloud_firestore/cloud_firestore.dart';

/// Moyens de paiement courants localement (espèces + mobile money mauritanien).
enum MethodePaiement { especes, bankily, masrivi, sedad }

extension MethodePaiementLabel on MethodePaiement {
  String get label => switch (this) {
        MethodePaiement.especes => 'Espèces',
        MethodePaiement.bankily => 'Bankily',
        MethodePaiement.masrivi => 'Masrivi',
        MethodePaiement.sedad => 'Sedad',
      };

  String get value => name;

  static MethodePaiement fromValue(String value) {
    return MethodePaiement.values.firstWhere((m) => m.name == value, orElse: () => MethodePaiement.especes);
  }
}

/// Un versement encaissé pour un étudiant. Le "reste à payer" n'est pas
/// stocké ici : il se calcule à l'affichage (montantDu de l'étudiant moins
/// la somme de ses paiements), pour ne jamais avoir deux sources de vérité
/// qui peuvent diverger.
class Paiement {
  final String id;
  final String etudiantUid;
  final String etudiantNom;
  final String formationTitre;
  final double montant;
  final MethodePaiement methode;
  final String? note;
  final String enregistreParNom;
  final DateTime? date;

  const Paiement({
    required this.id,
    required this.etudiantUid,
    required this.etudiantNom,
    required this.formationTitre,
    required this.montant,
    required this.methode,
    required this.enregistreParNom,
    this.note,
    this.date,
  });

  Map<String, dynamic> toMap() => {
        'etudiantUid': etudiantUid,
        'etudiantNom': etudiantNom,
        'formationTitre': formationTitre,
        'montant': montant,
        'methode': methode.value,
        'note': note,
        'enregistreParNom': enregistreParNom,
        'date': FieldValue.serverTimestamp(),
      };

  factory Paiement.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final ts = d['date'];
    return Paiement(
      id: doc.id,
      etudiantUid: (d['etudiantUid'] ?? '').toString(),
      etudiantNom: (d['etudiantNom'] ?? '').toString(),
      formationTitre: (d['formationTitre'] ?? '').toString(),
      montant: (d['montant'] as num?)?.toDouble() ?? 0,
      methode: MethodePaiementLabel.fromValue((d['methode'] ?? '').toString()),
      note: d['note']?.toString(),
      enregistreParNom: (d['enregistreParNom'] ?? '').toString(),
      date: ts is Timestamp ? ts.toDate() : null,
    );
  }
}
