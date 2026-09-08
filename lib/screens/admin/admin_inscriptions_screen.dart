import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/group_model.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';

class AdminInscriptionsScreen extends StatelessWidget {
  const AdminInscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Inscriptions')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: firestore.watchInscriptions(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Impossible de charger les inscriptions.\n${snapshot.error}', textAlign: TextAlign.center),
            ));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const EmptyState(icon: Icons.how_to_reg_outlined, message: 'Aucune demande d\'inscription pour l\'instant.');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data();
              final statut = data['statut'] as String? ?? 'en_attente';
              final uid = (data['uid'] ?? '').toString();
              final hasAccount = uid.isNotEmpty;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${data['prenom'] ?? ''} ${data['nom'] ?? ''}'.trim(),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      Text(data['formationTitre'] ?? '', style: const TextStyle(color: LazouColors.textSecondary)),
                      const SizedBox(height: 2),
                      Text(data['telephone'] ?? '', style: const TextStyle(color: LazouColors.textSecondary)),
                      if ((data['email'] ?? '').toString().isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(data['email'], style: const TextStyle(color: LazouColors.textSecondary)),
                      ],
                      if ((data['matricule'] ?? '').toString().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: LazouColors.secondary.withValues(alpha: .15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('Matricule Lazou : #${data['matricule']}',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: LazouColors.secondary)),
                        ),
                      ],
                      if ((data['preuvePaiementUrl'] ?? '').toString().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () => showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              child: InteractiveViewer(
                                child: Image.network(data['preuvePaiementUrl']),
                              ),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.receipt_long_outlined, size: 16, color: LazouColors.primary),
                              SizedBox(width: 4),
                              Text('Voir la preuve de paiement',
                                  style: TextStyle(color: LazouColors.primary, fontWeight: FontWeight.w600, fontSize: 12.5)),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _StatutBadge(statut: statut),
                          const SizedBox(width: 8),
                          if (hasAccount && statut == 'en_attente')
                            const Text('Compte lié', style: TextStyle(fontSize: 12, color: LazouColors.success)),
                          if (!hasAccount && statut == 'en_attente')
                            const Text('Sans compte', style: TextStyle(fontSize: 12, color: LazouColors.textSecondary)),
                          const Spacer(),
                          if (statut == 'en_attente') ...[
                            TextButton(
                              onPressed: () => _refuser(context, firestore, doc.id),
                              child: const Text('Refuser'),
                            ),
                            ElevatedButton(
                              onPressed: () => _valider(context, firestore, doc.id, data),
                              child: const Text('Valider'),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _refuser(BuildContext context, FirestoreService firestore, String id) async {
    try {
      await firestore.mettreAJourStatutInscription(id, 'refusee');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible de refuser cette demande.')));
      }
    }
  }

  Future<void> _valider(
    BuildContext context,
    FirestoreService firestore,
    String inscriptionId,
    Map<String, dynamic> data,
  ) async {
    final uid = (data['uid'] ?? '').toString();
    final formationId = (data['formationId'] ?? '').toString();
    final formationTitre = (data['formationTitre'] ?? '').toString();

    try {
      final groupes = await firestore.getGroupesOnce();
      final groupesCompatibles = groupes.where((g) => g.formationId == formationId).toList();
      FormationGroup? groupe;
      var continuer = true;

      if (uid.isNotEmpty && groupesCompatibles.isNotEmpty) {
        final choix = await _choisirGroupe(context, groupesCompatibles, formationTitre);
        if (!context.mounted) return;
        continuer = choix.$1;
        groupe = choix.$2;
      }
      if (!continuer) return;

      await firestore.validerInscription(
        inscriptionId: inscriptionId,
        uid: uid.isEmpty ? null : uid,
        formationId: formationId,
        formationTitre: formationTitre,
        groupe: groupe,
        matricule: (data['matricule'] as String?)?.trim(),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(uid.isNotEmpty
              ? (groupe == null ? 'Inscription validée et formation affectée.' : 'Inscription validée et étudiant affecté au groupe.')
              : 'Inscription validée. L’étudiant devra créer son compte pour être affecté automatiquement.'),
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible de valider cette inscription.')));
      }
    }
  }

  Future<(bool, FormationGroup?)> _choisirGroupe(
    BuildContext context,
    List<FormationGroup> groupes,
    String formationTitre,
  ) async {
    final result = await showDialog<(bool, FormationGroup?)>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Groupe — $formationTitre'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, (true, null)),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text('Valider sans affecter de groupe'),
            ),
          ),
          ...groupes.map((g) => SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, (true, g)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text('${g.nom} · ${g.jours.isEmpty ? 'Jours non définis' : g.jours} · ${g.horaire.isEmpty ? 'Horaire non défini' : g.horaire}'),
                ),
              )),
        ],
      ),
    );
    return result ?? (false, null);
  }
}

class _StatutBadge extends StatelessWidget {
  final String statut;
  const _StatutBadge({required this.statut});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (statut) {
      'validee' => ('Validée', LazouColors.success),
      'refusee' => ('Refusée', LazouColors.error),
      _ => ('En attente', LazouColors.secondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}
