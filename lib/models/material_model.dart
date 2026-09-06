import 'package:cloud_firestore/cloud_firestore.dart';

enum TypeMateriau { pdf, image, document, autre }

extension TypeMateriauX on TypeMateriau {
  String get label => switch (this) {
        TypeMateriau.pdf => 'PDF',
        TypeMateriau.image => 'Image',
        TypeMateriau.document => 'Document',
        TypeMateriau.autre => 'Fichier',
      };

  static TypeMateriau depuisExtension(String nomFichier) {
    final ext = nomFichier.toLowerCase().split('.').last;
    if (ext == 'pdf') return TypeMateriau.pdf;
    if (['jpg', 'jpeg', 'png', 'webp'].contains(ext)) return TypeMateriau.image;
    if (['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'].contains(ext)) return TypeMateriau.document;
    return TypeMateriau.autre;
  }
}

class Materiau {
  final String id;
  final String groupeId;
  final String formationTitre;
  final String titre;
  final String url;
  final TypeMateriau type;
  final String publieParNom;
  final DateTime? date;

  const Materiau({
    required this.id,
    required this.groupeId,
    required this.formationTitre,
    required this.titre,
    required this.url,
    required this.type,
    required this.publieParNom,
    this.date,
  });

  Map<String, dynamic> toMap() => {
        'groupeId': groupeId,
        'formationTitre': formationTitre,
        'titre': titre,
        'url': url,
        'type': type.name,
        'publieParNom': publieParNom,
        'date': FieldValue.serverTimestamp(),
      };

  factory Materiau.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final ts = d['date'];
    return Materiau(
      id: doc.id,
      groupeId: (d['groupeId'] ?? '').toString(),
      formationTitre: (d['formationTitre'] ?? '').toString(),
      titre: (d['titre'] ?? '').toString(),
      url: (d['url'] ?? '').toString(),
      type: TypeMateriau.values.firstWhere((t) => t.name == d['type'], orElse: () => TypeMateriau.autre),
      publieParNom: (d['publieParNom'] ?? '').toString(),
      date: ts is Timestamp ? ts.toDate() : null,
    );
  }
}
