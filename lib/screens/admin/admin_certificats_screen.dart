import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/certificate_model.dart';
import '../../models/student_profile.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../certificate_detail_screen.dart';

class AdminCertificatsScreen extends StatelessWidget {
  const AdminCertificatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Certificats')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _ouvrirFormulaire(context, firestore),
        icon: const Icon(Icons.add),
        label: const Text('Délivrer'),
      ),
      body: StreamBuilder<List<Certificate>>(
        stream: firestore.watchCertificats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final certificats = snapshot.data ?? [];
          if (certificats.isEmpty) {
            return const Center(child: Text('Aucun certificat délivré pour l\'instant.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            itemCount: certificats.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final c = certificats[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.workspace_premium_outlined, color: LazouColors.secondary),
                  title: Text(c.etudiantNom, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${c.formationTitre} • ${c.numero}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => CertificateDetailScreen(certificate: c)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _ouvrirFormulaire(BuildContext context, FirestoreService firestore) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _FormulaireCertificat(firestore: firestore),
    );
  }
}

class _FormulaireCertificat extends StatefulWidget {
  final FirestoreService firestore;
  const _FormulaireCertificat({required this.firestore});

  @override
  State<_FormulaireCertificat> createState() => _FormulaireCertificatState();
}

class _FormulaireCertificatState extends State<_FormulaireCertificat> {
  StudentProfile? _etudiant;
  final _moyenneCtrl = TextEditingController();
  bool _envoi = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Délivrer un certificat', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            const SizedBox(height: 6),
            const Text(
              'Un numéro unique est généré automatiquement (LZ-année-000000) — impossible à falsifier ou dupliquer.',
              style: TextStyle(color: LazouColors.textSecondary, fontSize: 12.5),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<StudentProfile>>(
              future: widget.firestore.getEtudiantsOnce(),
              builder: (context, snap) {
                final etudiants = snap.data ?? [];
                return DropdownButtonFormField<StudentProfile>(
                  initialValue: _etudiant,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Étudiant'),
                  items: etudiants.map((e) => DropdownMenuItem(value: e, child: Text(e.nomComplet, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (v) => setState(() => _etudiant = v),
                );
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _moyenneCtrl,
              decoration: const InputDecoration(labelText: 'Moyenne finale (optionnel)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _envoi || _etudiant == null ? null : _delivrer,
              child: _envoi
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Délivrer le certificat'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delivrer() async {
    setState(() => _envoi = true);
    final auth = context.read<AuthService>();
    final numero = await widget.firestore.delivrerCertificat(
      etudiantUid: _etudiant!.uid,
      etudiantNom: _etudiant!.nomComplet,
      formationTitre: _etudiant!.formationTitre ?? 'Non affectée',
      delivreParNom: auth.user?.email ?? 'Administration',
      moyenne: double.tryParse(_moyenneCtrl.text.replaceAll(',', '.')),
    );
    if (mounted) Navigator.of(context).pop();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Certificat $numero délivré ✓')));
    }
  }
}
