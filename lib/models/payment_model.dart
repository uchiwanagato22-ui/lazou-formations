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
///
/// [mois] (format "AAAA-MM") identifie POUR QUEL MOIS ce versement compte —
/// c'est ça qui permet de répondre à la vraie question de Lazou : "Ahmed
/// a-t-il payé son mois de février ?", pas juste "combien a-t-il payé au
/// total". Par défaut le mois en cours au moment du paiement.
class Paiement {
  final String id;
  final String etudiantUid;
  final String etudiantNom;
  final String formationTitre;
  final double montant;
  final MethodePaiement methode;
  final String? note;
  final String enregistreParNom;
  final String mois;
  final DateTime? date;

  const Paiement({
    required this.id,
    required this.etudiantUid,
    required this.etudiantNom,
    required this.formationTitre,
    required this.montant,
    required this.methode,
    required this.enregistreParNom,
    required this.mois,
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
        'mois': mois,
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
      mois: (d['mois'] ?? '').toString(),
      date: ts is Timestamp ? ts.toDate() : null,
    );
  }

  /// Libellé humain pour le mois, ex: "Février 2026".
  String get moisLabel {
    if (mois.isEmpty || !mois.contains('-')) return '';
    final parts = mois.split('-');
    const noms = ['', 'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
    final m = int.tryParse(parts[1]) ?? 0;
    return '${noms[m]} ${parts[0]}';
  }
}

/// Clé "AAAA-MM" pour un mois donné — utilisée pour taguer un paiement et
/// pour comparer "est-ce que ce mois est payé".
String cleMois(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}';
