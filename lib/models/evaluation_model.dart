import 'package:cloud_firestore/cloud_firestore.dart';

/// Une évaluation appartient à un groupe. Les notes sont stockées dans une
/// map {uid: note} directement sur le document — même principe que les
/// présences (un doc par séance/évaluation plutôt qu'une sous-collection),
/// pour rester cohérent avec le reste du projet.
class Evaluation {
  final String id;
  final String groupeId;
  final String formationTitre;
  final String titre;
  final Map<String, double> notes;
  final DateTime? date;

  const Evaluation({
    required this.id,
    required this.groupeId,
    required this.formationTitre,
    required this.titre,
    this.notes = const {},
    this.date,
  });

  double? noteDe(String uid) => notes[uid];

  double? get moyenne {
    if (notes.isEmpty) return null;
    return notes.values.reduce((a, b) => a + b) / notes.length;
  }

  Map<String, dynamic> toMap() => {
        'groupeId': groupeId,
        'formationTitre': formationTitre,
        'titre': titre,
        'notes': notes,
        'date': FieldValue.serverTimestamp(),
      };

  factory Evaluation.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final ts = d['date'];
    final notesRaw = (d['notes'] as Map?) ?? {};
    return Evaluation(
      id: doc.id,
      groupeId: (d['groupeId'] ?? '').toString(),
      formationTitre: (d['formationTitre'] ?? '').toString(),
      titre: (d['titre'] ?? '').toString(),
      notes: notesRaw.map((k, v) => MapEntry(k.toString(), (v as num).toDouble())),
      date: ts is Timestamp ? ts.toDate() : null,
    );
  }
}
