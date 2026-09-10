import 'package:cloud_firestore/cloud_firestore.dart';

class StudentProfile {
  final String uid;
  final String matricule;
  final String nomComplet;
  final String email;
  final String telephone;
  final String? formationId;
  final String? formationTitre;
  final String? groupeId;
  final String statut;
  final double montantDu;
  final double mensualite;
  final String moduleActuel;
  final DateTime? creeLe;

  const StudentProfile({
    required this.uid,
    this.matricule = '',
    required this.nomComplet,
    required this.email,
    required this.telephone,
    this.formationId,
    this.formationTitre,
    this.groupeId,
    this.statut = 'actif',
    this.montantDu = 0,
    this.mensualite = 0,
    this.moduleActuel = '',
    this.creeLe,
  });

  factory StudentProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final ts = d['creeLe'];
    return StudentProfile(
      uid: doc.id,
      matricule: (d['matricule'] ?? '').toString(),
      nomComplet: (d['nomComplet'] ?? '').toString(),
      email: (d['email'] ?? '').toString(),
      telephone: (d['telephone'] ?? '').toString(),
      formationId: d['formationId']?.toString(),
      formationTitre: d['formationTitre']?.toString(),
      groupeId: d['groupeId']?.toString(),
      statut: (d['statut'] ?? 'actif').toString(),
      montantDu: (d['montantDu'] as num?)?.toDouble() ?? 0,
      mensualite: (d['mensualite'] as num?)?.toDouble() ?? 0,
      moduleActuel: (d['moduleActuel'] ?? '').toString(),
      creeLe: ts is Timestamp ? ts.toDate() : null,
    );
  }
}
