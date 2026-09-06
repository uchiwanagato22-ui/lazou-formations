import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/announcement_model.dart';
import '../../models/group_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class AnnoncesScreen extends StatefulWidget {
  const AnnoncesScreen({super.key});

  @override
  State<AnnoncesScreen> createState() => _AnnoncesScreenState();
}

class _AnnoncesScreenState extends State<AnnoncesScreen> {
  FormationGroup? _groupe;

  @override
  Widget build(BuildContext context) {
    final service = context.read<FirestoreService>();
    final auth = context.read<AuthService>();
    final uid = auth.user?.uid;
    final role = auth.role?.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Annonces')),
      floatingActionButton: _groupe == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _dialogueNouvelleAnnonce(context, service, _groupe!, auth.user?.email ?? 'Formateur'),
              icon: const Icon(Icons.add),
              label: const Text('Publier'),
            ),
      body: uid == null
          ? const Center(child: Text('Session introuvable.'))
          : StreamBuilder<List<FormationGroup>>(
              stream: service.watchGroupes(),
              builder: (context, groupsSnap) {
                if (groupsSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                var groupes = groupsSnap.data ?? [];
                if (role == 'formateur') groupes = groupes.where((g) => g.formateurUid == uid).toList();
                if (groupes.isEmpty) return const Center(child: Text('Aucun groupe disponible.'));
                _groupe ??= groupes.first;
                if (!groupes.any((g) => g.id == _groupe!.id)) _groupe = groupes.first;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: DropdownButtonFormField<FormationGroup>(
                        initialValue: _groupe,
                        decoration: const InputDecoration(labelText: 'Groupe'),
                        items: groupes.map((g) => DropdownMenuItem(value: g, child: Text(g.nom))).toList(),
                        onChanged: (g) => setState(() => _groupe = g),
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<List<Annonce>>(
                        stream: service.watchAnnoncesDuGroupe(_groupe!.id),
                        builder: (context, snap) {
                          final annonces = snap.data ?? [];
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (annonces.isEmpty) {
                            return const Center(child: Text('Aucune annonce publiée pour ce groupe.'));
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                            itemCount: annonces.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, i) => _AnnonceCard(annonce: annonces[i]),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  void _dialogueNouvelleAnnonce(BuildContext context, FirestoreService service, FormationGroup groupe, String formateurNom) {
    final titreCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouvelle annonce'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titreCtrl, decoration: const InputDecoration(labelText: 'Titre')),
            const SizedBox(height: 10),
            TextField(controller: messageCtrl, decoration: const InputDecoration(labelText: 'Message'), maxLines: 3),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              if (titreCtrl.text.trim().isEmpty) return;
              service.creerAnnonce(Annonce(
                id: '',
                groupeId: groupe.id,
                formationTitre: groupe.formationTitre,
                titre: titreCtrl.text.trim(),
                message: messageCtrl.text.trim(),
                formateurNom: formateurNom,
              ));
              Navigator.of(ctx).pop();
            },
            child: const Text('Publier'),
          ),
        ],
      ),
    );
  }
}

class _AnnonceCard extends StatelessWidget {
  final Annonce annonce;
  const _AnnonceCard({required this.annonce});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.campaign_outlined, color: LazouColors.secondary, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(annonce.titre, style: const TextStyle(fontWeight: FontWeight.w800))),
                if (annonce.date != null)
                  Text('${annonce.date!.day}/${annonce.date!.month}', style: const TextStyle(fontSize: 11, color: LazouColors.textSecondary)),
              ],
            ),
            if (annonce.message.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(annonce.message, style: const TextStyle(fontSize: 13.5, height: 1.4)),
            ],
          ],
        ),
      ),
    );
  }
}
