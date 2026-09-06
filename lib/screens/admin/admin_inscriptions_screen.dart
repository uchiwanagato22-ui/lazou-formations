import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('Aucune demande d\'inscription pour l\'instant.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final data = docs[i].data();
              final statut = data['statut'] as String? ?? 'en_attente';
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${data['prenom'] ?? ''} ${data['nom'] ?? ''}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(data['formationTitre'] ?? '', style: const TextStyle(color: LazouColors.textSecondary)),
                      const SizedBox(height: 2),
                      Text(data['telephone'] ?? '', style: const TextStyle(color: LazouColors.textSecondary)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _StatutBadge(statut: statut),
                          const Spacer(),
                          if (statut == 'en_attente') ...[
                            TextButton(
                              onPressed: () => firestore.mettreAJourStatutInscription(docs[i].id, 'refusee'),
                              child: const Text('Refuser'),
                            ),
                            ElevatedButton(
                              onPressed: () => firestore.mettreAJourStatutInscription(docs[i].id, 'validee'),
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
