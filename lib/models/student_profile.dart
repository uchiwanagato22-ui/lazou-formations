import 'package:cloud_firestore/cloud_firestore.dart';

class StudentProfile {
  final String uid;
  final String nomComplet;
  final String email;
  final String telephone;
  final String? formationId;
  final String? formationTitre;
  final String? groupeId;
  final String statut;
  final double montantDu;
  final DateTime? creeLe;

  const StudentProfile({
    required this.uid,
    required this.nomComplet,
    required this.email,
    required this.telephone,
    this.formationId,
    this.formationTitre,
    this.groupeId,
    this.statut = 'actif',
    this.montantDu = 0,
    this.creeLe,
  });

  factory StudentProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final ts = d['creeLe'];
    return StudentProfile(
      uid: doc.id,
      nomComplet: (d['nomComplet'] ?? '').toString(),
      email: (d['email'] ?? '').toString(),
      telephone: (d['telephone'] ?? '').toString(),
      formationId: d['formationId']?.toString(),
      formationTitre: d['formationTitre']?.toString(),
      groupeId: d['groupeId']?.toString(),
      statut: (d['statut'] ?? 'actif').toString(),
      montantDu: (d['montantDu'] as num?)?.toDouble() ?? 0,
      creeLe: ts is Timestamp ? ts.toDate() : null,
    );
  }
}
