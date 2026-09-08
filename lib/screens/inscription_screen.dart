import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/formation.dart';
import '../services/auth_service.dart';
import '../services/cloudinary_service.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

/// Pensé pour remplacer le formulaire papier de Lazou, pas juste l'imiter :
/// matricule (si l'étudiant connaît déjà son numéro), preuve de paiement
/// (capture) uploadée directement ou envoyée par WhatsApp en secours.
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
  final _matricule = TextEditingController();

  Uint8List? _captureBytes;
  String? _captureNom;
  bool _uploadEnCours = false;
  bool _envoiEnCours = false;

  @override
  void dispose() {
    _nom.dispose();
    _prenom.dispose();
    _telephone.dispose();
    _email.dispose();
    _matricule.dispose();
    super.dispose();
  }

  Future<void> _choisirCapture() async {
    final resultat = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (resultat == null || resultat.files.isEmpty) return;
    setState(() {
      _captureBytes = resultat.files.first.bytes;
      _captureNom = resultat.files.first.name;
    });
  }

  Future<void> _envoyerParWhatsapp() async {
    // Repli simple si l'étudiant préfère envoyer sa capture directement au
    // centre plutôt que de l'uploader — même numéro que la carte "Nous
    // contacter" de l'accueil.
    final texte = Uri.encodeComponent(
      'Bonjour, voici ma preuve de paiement pour la formation "${widget.formation.titre}" '
      '(${_prenom.text.trim()} ${_nom.text.trim()}).',
    );
    await launchUrl(Uri.parse('https://wa.me/22232171785?text=$texte'), mode: LaunchMode.externalApplication);
  }

  Future<void> _soumettre() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _envoiEnCours = true);

    String? erreur;
    try {
      final firestore = context.read<FirestoreService?>();
      if (firestore != null) {
        final uid = context.read<AuthService?>()?.user?.uid;

        String? preuveUrl;
        if (_captureBytes != null && _captureNom != null) {
          setState(() => _uploadEnCours = true);
          preuveUrl = await CloudinaryService.uploaderFichier(_captureBytes!, _captureNom!);
          if (mounted) setState(() => _uploadEnCours = false);
        }

        await firestore.creerInscription(
          formationId: widget.formation.id,
          formationTitre: widget.formation.titre,
          nom: _nom.text.trim(),
          prenom: _prenom.text.trim(),
          telephone: _telephone.text.trim(),
          email: _email.text.trim().isEmpty ? null : _email.text.trim(),
          uid: uid,
          matricule: _matricule.text.trim().isEmpty ? null : _matricule.text.trim(),
          preuvePaiementUrl: preuveUrl,
        );
      } else {
        await Future.delayed(const Duration(milliseconds: 600));
      }
    } catch (_) {
      erreur = "Impossible d'envoyer la demande. Vérifie ta connexion puis réessaie.";
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
        icon: const Icon(Icons.check_circle, color: LazouColors.success, size: 40),
        title: const Text('Inscription envoyée', textAlign: TextAlign.center),
        content: Text(
          'Ta demande pour "${widget.formation.titre}" a bien été envoyée. '
          "L'équipe Lazou va la valider prochainement.",
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('OK'),
            ),
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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: LazouColors.primary.withValues(alpha: .06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: LazouColors.primary.withValues(alpha: .15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.school_outlined, color: LazouColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.formation.titre,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5, color: LazouColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const _SectionLabel('Tes informations'),
            const SizedBox(height: 12),
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
            const SizedBox(height: 14),
            TextFormField(
              controller: _matricule,
              decoration: const InputDecoration(
                labelText: 'Matricule Lazou (si tu en as déjà un)',
                helperText: 'Déjà venu chez Lazou ? Indique ton numéro pour ne rien perdre de ton historique.',
                helperMaxLines: 2,
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 28),
            const _SectionLabel('Preuve de paiement (optionnel)'),
            const SizedBox(height: 6),
            const Text(
              "Si tu as déjà versé un acompte, ajoute la capture de la transaction — ça accélère la validation.",
              style: TextStyle(color: LazouColors.textSecondary, fontSize: 12.5, height: 1.4),
            ),
            const SizedBox(height: 12),
            if (_captureBytes != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: LazouColors.success.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.image_outlined, color: LazouColors.success),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(_captureNom ?? 'Capture sélectionnée',
                          overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => setState(() {
                        _captureBytes = null;
                        _captureNom = null;
                      }),
                    ),
                  ],
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _choisirCapture,
                      icon: const Icon(Icons.upload_file, size: 18),
                      label: const Text('Joindre la capture'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _envoyerParWhatsapp,
                      icon: const Icon(Icons.chat_outlined, size: 18),
                      label: const Text('Par WhatsApp'),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _envoiEnCours ? null : _soumettre,
              child: _envoiEnCours
                  ? Text(_uploadEnCours ? 'Envoi de la capture...' : 'Envoi en cours...')
                  : const Text('Envoyer ma demande'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String texte;
  const _SectionLabel(this.texte);

  @override
  Widget build(BuildContext context) {
    return Text(
      texte,
      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: LazouColors.primary, letterSpacing: .3),
    );
  }
}
