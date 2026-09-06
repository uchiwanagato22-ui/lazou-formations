import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/certificate_model.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

/// Accessible sans compte — un employeur ou une administration doit
/// pouvoir vérifier un certificat Lazou sans créer de compte étudiant.
class VerifyCertificateScreen extends StatefulWidget {
  const VerifyCertificateScreen({super.key});

  @override
  State<VerifyCertificateScreen> createState() => _VerifyCertificateScreenState();
}

class _VerifyCertificateScreenState extends State<VerifyCertificateScreen> {
  final _ctrl = TextEditingController();
  bool _recherche = false;
  Certificate? _resultat;
  bool _rechercheEffectuee = false;

  Future<void> _verifier() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() {
      _recherche = true;
      _rechercheEffectuee = false;
    });
    final firestore = context.read<FirestoreService>();
    final certificat = await firestore.verifierCertificat(_ctrl.text.trim());
    if (!mounted) return;
    setState(() {
      _resultat = certificat;
      _recherche = false;
      _rechercheEffectuee = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vérifier un certificat')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Entre le numéro inscrit sur le certificat (ex: LZ-2026-000421) pour confirmer son authenticité.',
              style: TextStyle(color: LazouColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: 'Numéro du certificat', prefixIcon: Icon(Icons.qr_code)),
              onSubmitted: (_) => _verifier(),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _recherche ? null : _verifier,
              child: _recherche
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Vérifier'),
            ),
            const SizedBox(height: 24),
            if (_rechercheEffectuee) _ResultatVerification(certificat: _resultat),
          ],
        ),
      ),
    );
  }
}

class _ResultatVerification extends StatelessWidget {
  final Certificate? certificat;
  const _ResultatVerification({required this.certificat});

  @override
  Widget build(BuildContext context) {
    if (certificat == null) {
      return Card(
        color: LazouColors.error.withValues(alpha: 0.08),
        child: const Padding(
          padding: EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(Icons.cancel_outlined, color: LazouColors.error),
              SizedBox(width: 12),
              Expanded(child: Text('Aucun certificat ne correspond à ce numéro.', style: TextStyle(fontWeight: FontWeight.w600))),
            ],
          ),
        ),
      );
    }
    return Card(
      color: LazouColors.success.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.verified, color: LazouColors.success),
                SizedBox(width: 10),
                Text('Certificat authentique', style: TextStyle(fontWeight: FontWeight.w800, color: LazouColors.success)),
              ],
            ),
            const SizedBox(height: 14),
            _Ligne('Nom', certificat!.etudiantNom),
            _Ligne('Formation', certificat!.formationTitre),
            if (certificat!.moyenne != null) _Ligne('Moyenne', '${certificat!.moyenne!.toStringAsFixed(1)}/20'),
            if (certificat!.dateDelivrance != null)
              _Ligne('Délivré le', '${certificat!.dateDelivrance!.day}/${certificat!.dateDelivrance!.month}/${certificat!.dateDelivrance!.year}'),
            _Ligne('Centre', 'LAZOU Formations'),
          ],
        ),
      ),
    );
  }
}

class _Ligne extends StatelessWidget {
  final String label;
  final String valeur;
  const _Ligne(this.label, this.valeur);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(color: LazouColors.textSecondary, fontSize: 13))),
          Expanded(child: Text(valeur, style: const TextStyle(fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}
