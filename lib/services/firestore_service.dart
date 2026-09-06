import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/formation.dart';
import '../models/student_profile.dart';
import '../models/group_model.dart';
import '../models/payment_model.dart';
import '../models/evaluation_model.dart';
import '../models/announcement_model.dart';
import '../models/certificate_model.dart';
import '../models/material_model.dart';

/// Accès Firestore centralisé. Un seul endroit à modifier si les noms de
/// collections changent. Toutes les méthodes supposent que Firebase est
/// configuré (voir README_FIREBASE.md) — l'app tourne en mode démo sinon
/// et n'appelle jamais ce service.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Formations (catalogue) ---

  /// Flux temps réel du catalogue : dès que l'admin ajoute une formation,
  /// tous les étudiants connectés la voient apparaître sans recharger.
  Stream<List<Formation>> watchFormations() {
    return _db.collection('formations').orderBy('titre').snapshots().map(
          (snap) => snap.docs.map((d) => Formation.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<void> ajouterFormation(Formation formation) {
    return _db.collection('formations').doc(formation.id).set(formation.toMap());
  }

  Future<void> supprimerFormation(String id) {
    return _db.collection('formations').doc(id).delete();
  }

  // --- Inscriptions ---

  Future<void> creerInscription({
    required String formationId,
    required String formationTitre,
    required String nom,
    required String prenom,
    required String telephone,
    String? email,
    String? uid,
  }) {
    return _db.collection('inscriptions').add({
      'formationId': formationId,
      'formationTitre': formationTitre,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'email': email,
      'uid': uid,
      'statut': 'en_attente', // en_attente -> validee / refusee, changé par l'admin
      'creeLe': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchInscriptions() {
    return _db.collection('inscriptions').orderBy('creeLe', descending: true).snapshots();
  }

  Future<void> mettreAJourStatutInscription(String inscriptionId, String statut) {
    return _db.collection('inscriptions').doc(inscriptionId).update({'statut': statut});
  }


  // --- Étudiants ---

  Stream<List<StudentProfile>> watchEtudiants() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'etudiant')
        .snapshots()
        .map((snap) => snap.docs.map(StudentProfile.fromDoc).toList()
          ..sort((a, b) => a.nomComplet.toLowerCase().compareTo(b.nomComplet.toLowerCase())));
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchEtudiant(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  Future<void> mettreAJourEtudiant(String uid, Map<String, dynamic> data) {
    return _db.collection('users').doc(uid).update(data);
  }

  Stream<int> watchNombreEtudiants() {
    return _db.collection('users').where('role', isEqualTo: 'etudiant').snapshots().map((s) => s.size);
  }

  Stream<int> watchNombreFormateurs() {
    return _db.collection('users').where('role', isEqualTo: 'formateur').snapshots().map((s) => s.size);
  }

  Stream<int> watchNombreInscriptionsEnAttente() {
    return _db.collection('inscriptions').where('statut', isEqualTo: 'en_attente').snapshots().map((s) => s.size);
  }

  /// Répartition des étudiants par formation — pour le graphique de
  /// statistiques. Calculé côté client sur watchEtudiants() plutôt qu'une
  /// requête d'agrégation séparée : le volume de données d'un centre comme
  /// Lazou reste largement dans les limites d'une lecture simple.
  Stream<Map<String, int>> watchRepartitionParFormation() {
    return watchEtudiants().map((etudiants) {
      final repartition = <String, int>{};
      for (final e in etudiants) {
        final titre = (e.formationTitre?.isNotEmpty ?? false) ? e.formationTitre! : 'Non affecté';
        repartition[titre] = (repartition[titre] ?? 0) + 1;
      }
      return repartition;
    });
  }

  /// Moyenne générale tous groupes/évaluations confondus.
  Stream<double?> watchMoyenneGenerale() {
    return _db.collection('evaluations').snapshots().map((snap) {
      final toutesLesNotes = <double>[];
      for (final doc in snap.docs) {
        final notes = (doc.data()['notes'] as Map?) ?? {};
        toutesLesNotes.addAll(notes.values.map((v) => (v as num).toDouble()));
      }
      if (toutesLesNotes.isEmpty) return null;
      return toutesLesNotes.reduce((a, b) => a + b) / toutesLesNotes.length;
    });
  }

  /// Taux de présence global (% de "present" sur toutes les présences prises).
  Stream<double?> watchTauxPresenceGlobal() {
    return _db.collection('presences').snapshots().map((snap) {
      var total = 0;
      var presents = 0;
      for (final doc in snap.docs) {
        final statuts = (doc.data()['etudiants'] as Map?) ?? {};
        for (final v in statuts.values) {
          total++;
          if (v == 'present') presents++;
        }
      }
      if (total == 0) return null;
      return presents / total * 100;
    });
  }

  Stream<int> watchNombreInscriptionsValidees() {
    return _db.collection('inscriptions').where('statut', isEqualTo: 'validee').snapshots().map((s) => s.size);
  }


  // --- Formateurs ---

  Stream<List<Map<String, dynamic>>> watchFormateurs() {
    return _db.collection('users').where('role', isEqualTo: 'formateur').snapshots().map((snap) {
      final list = snap.docs.map((d) => {'uid': d.id, ...d.data()}).toList();
      list.sort((a, b) => (a['nomComplet'] ?? '').toString().toLowerCase().compareTo((b['nomComplet'] ?? '').toString().toLowerCase()));
      return list;
    });
  }

  Future<List<Map<String, dynamic>>> getFormateursOnce() async {
    final snap = await _db.collection('users').where('role', isEqualTo: 'formateur').get();
    return snap.docs.map((d) => {'uid': d.id, ...d.data()}).toList();
  }

  Future<void> creerProfilFormateur({required String uid, required String nomComplet, String? email, String? telephone}) {
    return _db.collection('users').doc(uid).set({
      'nomComplet': nomComplet,
      'email': email ?? '',
      'telephone': telephone ?? '',
      'role': 'formateur',
      'statut': 'actif',
      'creeLe': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> mettreAJourFormateur(String uid, Map<String, dynamic> data) {
    return _db.collection('users').doc(uid).update(data);
  }

  // --- Groupes ---

  Stream<List<FormationGroup>> watchGroupes() {
    return _db.collection('groupes').orderBy('nom').snapshots().map(
      (snap) => snap.docs.map(FormationGroup.fromDoc).toList(),
    );
  }

  Stream<FormationGroup?> watchGroupe(String groupeId) {
    return _db.collection('groupes').doc(groupeId).snapshots().map(
          (doc) => doc.exists ? FormationGroup.fromDoc(doc) : null,
        );
  }

  Future<List<Formation>> getFormationsOnce() async {
    final snap = await _db.collection('formations').orderBy('titre').get();
    return snap.docs.map((d) => Formation.fromMap(d.id, d.data())).toList();
  }

  Future<List<StudentProfile>> getEtudiantsOnce() async {
    final snap = await _db.collection('users').where('role', isEqualTo: 'etudiant').get();
    final list = snap.docs.map(StudentProfile.fromDoc).toList();
    list.sort((a, b) => a.nomComplet.toLowerCase().compareTo(b.nomComplet.toLowerCase()));
    return list;
  }

  Future<void> creerGroupe(FormationGroup groupe) {
    return _db.collection('groupes').doc(groupe.id).set(groupe.toMap());
  }

  Future<void> supprimerGroupe(String id) {
    return _db.collection('groupes').doc(id).delete();
  }

  Future<void> affecterEtudiantAuGroupe(String uid, FormationGroup groupe) {
    return _db.collection('users').doc(uid).update({
      'formationId': groupe.formationId,
      'formationTitre': groupe.formationTitre,
      'groupeId': groupe.id,
      'groupeNom': groupe.nom,
      'formateurUid': groupe.formateurUid,
      'formateurNom': groupe.formateurNom,
      'statut': 'actif',
    });
  }


  // --- Présences ---

  Stream<List<StudentProfile>> watchEtudiantsDuGroupe(String groupeId) {
    return _db.collection('users').where('groupeId', isEqualTo: groupeId).snapshots().map(
      (snap) => snap.docs.where((d) => d.data()['role'] == 'etudiant').map(StudentProfile.fromDoc).toList()
        ..sort((a, b) => a.nomComplet.toLowerCase().compareTo(b.nomComplet.toLowerCase())),
    );
  }

  Future<List<StudentProfile>> getEtudiantsDuGroupeOnce(String groupeId) async {
    final snap = await _db.collection('users').where('groupeId', isEqualTo: groupeId).get();
    final list = snap.docs.where((d) => d.data()['role'] == 'etudiant').map(StudentProfile.fromDoc).toList();
    list.sort((a, b) => a.nomComplet.toLowerCase().compareTo(b.nomComplet.toLowerCase()));
    return list;
  }

  String _attendanceId(String groupeId, DateTime date) => '${groupeId}_${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<Map<String, String>> getPresences(String groupeId, DateTime date) async {
    final doc = await _db.collection('presences').doc(_attendanceId(groupeId, date)).get();
    final raw = doc.data()?['etudiants'];
    if (raw is! Map) return {};
    return raw.map((key, value) => MapEntry(key.toString(), value.toString()));
  }

  Future<void> enregistrerPresences(FormationGroup groupe, DateTime date, Map<String, String> statuses) {
    return _db.collection('presences').doc(_attendanceId(groupe.id, date)).set({
      'groupeId': groupe.id,
      'groupeNom': groupe.nom,
      'formationId': groupe.formationId,
      'formationTitre': groupe.formationTitre,
      'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
      'etudiants': statuses,
      'misAJourLe': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // --- Progression étudiant (leçons terminées) ---
  // Stocké sous users/{uid}/progression/{formationId} = { lessonIds: [...] }
  // Base pour un futur badge/pourcentage d'avancement par formation.

  Stream<Set<String>> watchLeconsTerminees(String uid, String formationId) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('progression')
        .doc(formationId)
        .snapshots()
        .map((doc) {
      final data = doc.data();
      final liste = data?['lessonIds'] as List?;
      return liste?.map((e) => e.toString()).toSet() ?? <String>{};
    });
  }

  Future<void> marquerLeconTerminee(String uid, String formationId, String lessonId) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('progression')
        .doc(formationId)
        .set({
      'lessonIds': FieldValue.arrayUnion([lessonId]),
    }, SetOptions(merge: true));
  }

  // --- Paiements ---
  // "Reste à payer" toujours recalculé (montantDu de l'étudiant - somme de
  // ses paiements), jamais stocké séparément — une seule source de vérité.

  Future<void> enregistrerPaiement(Paiement paiement) {
    return _db.collection('paiements').add(paiement.toMap());
  }

  Stream<List<Paiement>> watchTousLesPaiements() {
    return _db.collection('paiements').orderBy('date', descending: true).snapshots().map(
          (snap) => snap.docs.map(Paiement.fromDoc).toList(),
        );
  }

  Stream<List<Paiement>> watchPaiementsEtudiant(String uid) {
    return _db.collection('paiements').where('etudiantUid', isEqualTo: uid).snapshots().map(
          (snap) => snap.docs.map(Paiement.fromDoc).toList()
            ..sort((a, b) => (b.date ?? DateTime(2000)).compareTo(a.date ?? DateTime(2000))),
        );
  }

  Future<void> definirMontantDu(String uid, double montant) {
    return _db.collection('users').doc(uid).update({'montantDu': montant});
  }

  Stream<double> watchTotalEncaisse() {
    return _db.collection('paiements').snapshots().map(
          (snap) => snap.docs.fold<double>(0, (total, d) => total + ((d.data()['montant'] as num?)?.toDouble() ?? 0)),
        );
  }

  // --- Évaluations / Notes ---
  // Une évaluation = une note par étudiant du groupe, stockée dans une map
  // sur le document (comme les présences). L'étudiant retrouve les siennes
  // en filtrant par son propre groupeId, pas par une requête sur la map.

  Future<void> creerEvaluation(FormationGroup groupe, String titre) {
    return _db.collection('evaluations').add(Evaluation(
      id: '',
      groupeId: groupe.id,
      formationTitre: groupe.formationTitre,
      titre: titre,
    ).toMap());
  }

  Stream<List<Evaluation>> watchEvaluationsDuGroupe(String groupeId) {
    return _db
        .collection('evaluations')
        .where('groupeId', isEqualTo: groupeId)
        .snapshots()
        .map((snap) => snap.docs.map(Evaluation.fromDoc).toList()
          ..sort((a, b) => (b.date ?? DateTime(2000)).compareTo(a.date ?? DateTime(2000))));
  }

  Future<void> enregistrerNotes(String evaluationId, Map<String, double> notes) {
    return _db.collection('evaluations').doc(evaluationId).update({'notes': notes});
  }

  // --- Annonces ---

  Future<void> creerAnnonce(Annonce annonce) {
    return _db.collection('annonces').add(annonce.toMap());
  }

  Stream<List<Annonce>> watchAnnoncesDuGroupe(String groupeId) {
    return _db
        .collection('annonces')
        .where('groupeId', isEqualTo: groupeId)
        .snapshots()
        .map((snap) => snap.docs.map(Annonce.fromDoc).toList()
          ..sort((a, b) => (b.date ?? DateTime(2000)).compareTo(a.date ?? DateTime(2000))));
  }

  // --- Certificats ---
  // Le numéro (LZ-{année}-{compteur sur 6 chiffres}) est généré par
  // transaction atomique sur compteurs/certificats pour ne jamais avoir
  // deux certificats avec le même numéro, même si deux admins délivrent en
  // même temps.

  Future<String> _genererNumeroCertificat() {
    final compteurRef = _db.collection('compteurs').doc('certificats');
    return _db.runTransaction<String>((tx) async {
      final snap = await tx.get(compteurRef);
      final dernier = (snap.data()?['dernier'] as int?) ?? 0;
      final nouveau = dernier + 1;
      tx.set(compteurRef, {'dernier': nouveau}, SetOptions(merge: true));
      final annee = DateTime.now().year;
      return 'LZ-$annee-${nouveau.toString().padLeft(6, '0')}';
    });
  }

  /// Délivre un certificat et retourne son numéro (déjà attribué en base).
  Future<String> delivrerCertificat({
    required String etudiantUid,
    required String etudiantNom,
    required String formationTitre,
    required String delivreParNom,
    double? moyenne,
  }) async {
    final numero = await _genererNumeroCertificat();
    await _db.collection('certificats').doc(numero).set(Certificate(
      numero: numero,
      etudiantUid: etudiantUid,
      etudiantNom: etudiantNom,
      formationTitre: formationTitre,
      delivreParNom: delivreParNom,
      moyenne: moyenne,
    ).toMap());
    return numero;
  }

  Stream<List<Certificate>> watchCertificats() {
    return _db.collection('certificats').orderBy('dateDelivrance', descending: true).snapshots().map(
          (snap) => snap.docs.map(Certificate.fromDoc).toList(),
        );
  }

  Stream<List<Certificate>> watchCertificatsEtudiant(String uid) {
    return _db.collection('certificats').where('etudiantUid', isEqualTo: uid).snapshots().map(
          (snap) => snap.docs.map(Certificate.fromDoc).toList(),
        );
  }

  /// Vérification publique par numéro — accessible sans compte, c'est le
  /// principe même de la vérification d'un certificat par un tiers.
  Future<Certificate?> verifierCertificat(String numero) async {
    final doc = await _db.collection('certificats').doc(numero.trim().toUpperCase()).get();
    if (!doc.exists) return null;
    return Certificate.fromDoc(doc);
  }

  // --- Matériaux de cours ---
  // Le fichier lui-même vit sur Cloudinary (voir CloudinaryService) —
  // Firestore ne stocke que l'URL et les métadonnées.

  Future<void> publierMateriau(Materiau materiau) {
    return _db.collection('materiaux').add(materiau.toMap());
  }

  Stream<List<Materiau>> watchMateriauxDuGroupe(String groupeId) {
    return _db
        .collection('materiaux')
        .where('groupeId', isEqualTo: groupeId)
        .snapshots()
        .map((snap) => snap.docs.map(Materiau.fromDoc).toList()
          ..sort((a, b) => (b.date ?? DateTime(2000)).compareTo(a.date ?? DateTime(2000))));
  }

  Future<void> supprimerMateriau(String id) {
    return _db.collection('materiaux').doc(id).delete();
  }

  /// Historique de présence d'UN étudiant sur son groupe — parcourt les
  /// séances du groupe et extrait juste son propre statut de chacune.
  Stream<List<({DateTime date, String statut})>> watchMesPresences(String uid, String groupeId) {
    return _db.collection('presences').where('groupeId', isEqualTo: groupeId).snapshots().map((snap) {
      final resultats = <({DateTime date, String statut})>[];
      for (final doc in snap.docs) {
        final d = doc.data();
        final ts = d['date'];
        final etudiants = (d['etudiants'] as Map?) ?? {};
        if (ts is Timestamp && etudiants.containsKey(uid)) {
          resultats.add((date: ts.toDate(), statut: etudiants[uid].toString()));
        }
      }
      resultats.sort((a, b) => b.date.compareTo(a.date));
      return resultats;
    });
  }
}
