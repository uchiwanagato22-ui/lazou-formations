import 'package:cloud_firestore/cloud_firestore.dart';

class Annonce {
  final String id;
  final String groupeId;
  final String formationTitre;
  final String titre;
  final String message;
  final String formateurNom;
  final DateTime? date;

  const Annonce({
    required this.id,
    required this.groupeId,
    required this.formationTitre,
    required this.titre,
    required this.message,
    required this.formateurNom,
    this.date,
  });

  Map<String, dynamic> toMap() => {
        'groupeId': groupeId,
        'formationTitre': formationTitre,
        'titre': titre,
        'message': message,
        'formateurNom': formateurNom,
        'date': FieldValue.serverTimestamp(),
      };

  factory Annonce.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final ts = d['date'];
    return Annonce(
      id: doc.id,
      groupeId: (d['groupeId'] ?? '').toString(),
      formationTitre: (d['formationTitre'] ?? '').toString(),
      titre: (d['titre'] ?? '').toString(),
      message: (d['message'] ?? '').toString(),
      formateurNom: (d['formateurNom'] ?? '').toString(),
      date: ts is Timestamp ? ts.toDate() : null,
    );
  }
}
