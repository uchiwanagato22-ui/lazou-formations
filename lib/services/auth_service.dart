import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../models/user_role.dart';

/// Gère la connexion/inscription et expose le rôle de l'utilisateur courant
/// (étudiant/formateur/admin) une fois connecté. Branché via Provider dans
/// main.dart. Ne fait rien tant que Firebase n'est pas configuré pour ce
/// projet (voir README_FIREBASE.md) — utilisable en mode démo sans compte
/// en attendant.
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? _user;
  UserRole? _role;
  bool _loading = false;

  User? get user => _user;
  UserRole? get role => _role;
  bool get loading => _loading;
  bool get isConnecte => _user != null;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(User? user) async {
    _user = user;
    if (user == null) {
      _role = null;
      notifyListeners();
      return;
    }
    await _chargerRole(user.uid);
  }

  Future<void> _chargerRole(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      final roleValue = doc.data()?['role'] as String?;
      _role = roleValue != null ? UserRoleParsing.fromValue(roleValue) : UserRole.etudiant;
    } catch (_) {
      // Pas de connexion / règles Firestore pas encore posées : on retombe
      // sur étudiant plutôt que de bloquer l'utilisateur.
      _role = UserRole.etudiant;
    }
    notifyListeners();
  }

  Future<String?> connexion({required String email, required String motDePasse}) async {
    _loading = true;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: motDePasse);
      return null; // succès
    } on FirebaseAuthException catch (e) {
      return _messageErreur(e.code);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<String?> inscription({
    required String email,
    required String motDePasse,
    required String nomComplet,
  }) async {
    _loading = true;
    notifyListeners();
    try {
      final credentials = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: motDePasse,
      );
      final uid = credentials.user!.uid;
      // Nouveau compte = étudiant par défaut ; le rôle formateur/admin est
      // attribué manuellement par un admin depuis Firestore (jamais choisi
      // par l'utilisateur lui-même, pour éviter qu'on s'auto-promeuve admin).
      await _db.collection('users').doc(uid).set({
        'nomComplet': nomComplet,
        'email': email,
        'role': UserRole.etudiant.value,
        'creeLe': FieldValue.serverTimestamp(),
      });
      return null;
    } on FirebaseAuthException catch (e) {
      return _messageErreur(e.code);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<String?> connexionGoogle() async {
    _loading = true;
    notifyListeners();
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // annulé par l'utilisateur, pas une erreur

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);

      // Première connexion Google : on crée le document users/{uid} comme
      // pour l'inscription email, sinon _chargerRole() ne trouverait rien.
      final doc = await _db.collection('users').doc(result.user!.uid).get();
      if (!doc.exists) {
        await _db.collection('users').doc(result.user!.uid).set({
          'nomComplet': result.user!.displayName ?? '',
          'email': result.user!.email ?? '',
          'role': UserRole.etudiant.value,
          'creeLe': FieldValue.serverTimestamp(),
        });
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _messageErreur(e.code);
    } catch (_) {
      return 'Connexion Google impossible. Réessaie.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // TODO: remplacer par ta vraie URL une fois déployée sur Vercel
  // (voir lazou-staff-auth/README_DEPLOY.md).
  static const _staffAuthUrl = 'https://lazou-staff-auth.vercel.app/api/verify-staff-code';

  /// Connexion espace formateur/admin par code PIN à 4 chiffres, vérifié
  /// côté serveur (jamais de code en dur ni de vérification côté client).
  Future<String?> connexionParCodeStaff(String code) async {
    _loading = true;
    notifyListeners();
    try {
      final reponse = await http
          .post(
            Uri.parse(_staffAuthUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'code': code}),
          )
          .timeout(const Duration(seconds: 10));

      if (reponse.statusCode != 200) {
        return 'Code incorrect.';
      }
      final data = jsonDecode(reponse.body) as Map<String, dynamic>;
      await _auth.signInWithCustomToken(data['token'] as String);
      return null;
    } catch (_) {
      return 'Connexion impossible. Vérifie ta connexion internet.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> deconnexion() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  String _messageErreur(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Un compte existe déjà avec cet email.';
      case 'weak-password':
        return 'Mot de passe trop court (6 caractères minimum).';
      default:
        return "Une erreur est survenue ($code).";
    }
  }
}
