import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/formation.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class InscriptionScreen extends StatefulWidget {
  final Formation formation;
  const InscriptionScreen({super.key, required this.formation});

  @override
  State<InscriptionScreen> createState() => _InscriptionScreenState();
}

class _InscriptionScreenState extends State<InscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _prenom = TextEditingController();
  final _telephone = TextEditingController();
  final _email = TextEditingController();
  bool _envoiEnCours = false;

  @override
  void dispose() {
    _nom.dispose();
    _prenom.dispose();
    _telephone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _soumettre() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _envoiEnCours = true);

    String? erreur;
    try {
      final firestore = context.read<FirestoreService?>();
      if (firestore != null) {
        final uid = context.read<AuthService?>()?.user?.uid;
        await firestore.creerInscription(
          formationId: widget.formation.id,
          formationTitre: widget.formation.titre,
          nom: _nom.text.trim(),
          prenom: _prenom.text.trim(),
          telephone: _telephone.text.trim(),
          email: _email.text.trim().isEmpty ? null : _email.text.trim(),
          uid: uid,
        );
      } else {
        // Mode démo (Firebase pas encore configuré) : on simule juste l'envoi.
        await Future.delayed(const Duration(milliseconds: 600));
      }
    } catch (_) {
      erreur = 'Impossible d'envoyer la demande. Vérifie ta connexion puis réessaie.';
    }

    if (!mounted) return;
    setState(() => _envoiEnCours = false);

    if (erreur != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erreur!)));
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Inscription envoyée'),
        content: Text(
          'Ta demande pour "${widget.formation.titre}" a bien été envoyée. '
          "L'équipe Lazou va la valider prochainement.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // ferme le dialog
              Navigator.of(context).popUntil((route) => route.isFirst); // retour accueil
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Formation : ${widget.formation.titre}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nom,
              decoration: const InputDecoration(labelText: 'Nom'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _prenom,
              decoration: const InputDecoration(labelText: 'Prénom'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _telephone,
              decoration: const InputDecoration(labelText: 'Téléphone / WhatsApp'),
              keyboardType: TextInputType.phone,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email (optionnel)'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _envoiEnCours ? null : _soumettre,
              child: _envoiEnCours
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Envoyer ma demande'),
            ),
          ],
        ),
      ),
    );
  }
}
