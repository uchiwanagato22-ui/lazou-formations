import 'package:cloud_firestore/cloud_firestore.dart';

enum StatutProspect { nouveau, contacte, interesse, inscrit, perdu }

extension StatutProspectX on StatutProspect {
  String get label => switch (this) {
    StatutProspect.nouveau => 'Nouveau',
    StatutProspect.contacte => 'Contacté',
    StatutProspect.interesse => 'Intéressé',
    StatutProspect.inscrit => 'Inscrit',
    StatutProspect.perdu => 'Perdu',
  };
}

class Prospect {
  final String id;
  final String nom;
  final String telephone;
  final String? email;
  final String? formationInteressee;
  final StatutProspect statut;
  final String? note;
  final DateTime? prochainContact;
  final DateTime? creeLe;

  const Prospect({required this.id, required this.nom, required this.telephone, this.email, this.formationInteressee, this.statut = StatutProspect.nouveau, this.note, this.prochainContact, this.creeLe});

  Map<String, dynamic> toMap() => {
    'nom': nom,
    'telephone': telephone,
    'email': email,
    'formationInteressee': formationInteressee,
    'statut': statut.name,
    'note': note,
    'prochainContact': prochainContact == null ? null : Timestamp.fromDate(prochainContact!),
    'creeLe': FieldValue.serverTimestamp(),
  };

  factory Prospect.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final created = d['creeLe'];
    final next = d['prochainContact'];
    return Prospect(
      id: doc.id,
      nom: (d['nom'] ?? '').toString(),
      telephone: (d['telephone'] ?? '').toString(),
      email: d['email']?.toString(),
      formationInteressee: d['formationInteressee']?.toString(),
      statut: StatutProspect.values.firstWhere((e) => e.name == d['statut'], orElse: () => StatutProspect.nouveau),
      note: d['note']?.toString(),
      prochainContact: next is Timestamp ? next.toDate() : null,
      creeLe: created is Timestamp ? created.toDate() : null,
    );
  }
}
