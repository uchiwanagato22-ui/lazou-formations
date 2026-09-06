import 'package:cloud_firestore/cloud_firestore.dart';

class FormationGroup {
  final String id;
  final String nom;
  final String formationId;
  final String formationTitre;
  final String? formateurUid;
  final String? formateurNom;
  final String salle;
  final String jours;
  final String horaire;
  final String statut;
  final DateTime? creeLe;

  const FormationGroup({
    required this.id,
    required this.nom,
    required this.formationId,
    required this.formationTitre,
    this.formateurUid,
    this.formateurNom,
    this.salle = '',
    this.jours = '',
    this.horaire = '',
    this.statut = 'actif',
    this.creeLe,
  });

  Map<String, dynamic> toMap() => {
        'nom': nom,
        'formationId': formationId,
        'formationTitre': formationTitre,
        'formateurUid': formateurUid,
        'formateurNom': formateurNom,
        'salle': salle,
        'jours': jours,
        'horaire': horaire,
        'statut': statut,
        'creeLe': FieldValue.serverTimestamp(),
      };

  factory FormationGroup.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final ts = d['creeLe'];
    return FormationGroup(
      id: doc.id,
      nom: (d['nom'] ?? '').toString(),
      formationId: (d['formationId'] ?? '').toString(),
      formationTitre: (d['formationTitre'] ?? '').toString(),
      formateurUid: d['formateurUid']?.toString(),
      formateurNom: d['formateurNom']?.toString(),
      salle: (d['salle'] ?? '').toString(),
      jours: (d['jours'] ?? '').toString(),
      horaire: (d['horaire'] ?? '').toString(),
      statut: (d['statut'] ?? 'actif').toString(),
      creeLe: ts is Timestamp ? ts.toDate() : null,
    );
  }
}
