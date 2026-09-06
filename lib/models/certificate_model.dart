import 'package:cloud_firestore/cloud_firestore.dart';

/// Un certificat délivré. L'ID du document Firestore EST le numéro
/// (ex: "LZ-2026-000421") — c'est ce numéro qu'un tiers tape pour vérifier
/// l'authenticité, donc il doit être lisible et mémorisable, pas un ID
/// Firestore auto-généré illisible.
class Certificate {
  final String numero;
  final String etudiantUid;
  final String etudiantNom;
  final String formationTitre;
  final double? moyenne;
  final String delivreParNom;
  final DateTime? dateDelivrance;

  const Certificate({
    required this.numero,
    required this.etudiantUid,
    required this.etudiantNom,
    required this.formationTitre,
    required this.delivreParNom,
    this.moyenne,
    this.dateDelivrance,
  });

  Map<String, dynamic> toMap() => {
        'etudiantUid': etudiantUid,
        'etudiantNom': etudiantNom,
        'formationTitre': formationTitre,
        'moyenne': moyenne,
        'delivreParNom': delivreParNom,
        'dateDelivrance': FieldValue.serverTimestamp(),
      };

  factory Certificate.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final ts = d['dateDelivrance'];
    return Certificate(
      numero: doc.id,
      etudiantUid: (d['etudiantUid'] ?? '').toString(),
      etudiantNom: (d['etudiantNom'] ?? '').toString(),
      formationTitre: (d['formationTitre'] ?? '').toString(),
      moyenne: (d['moyenne'] as num?)?.toDouble(),
      delivreParNom: (d['delivreParNom'] ?? '').toString(),
      dateDelivrance: ts is Timestamp ? ts.toDate() : null,
    );
  }
}
