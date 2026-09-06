import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class StatistiquesScreen extends StatelessWidget {
  const StatistiquesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: StreamBuilder<int>(
                  stream: firestore.watchNombreEtudiants(),
                  builder: (_, s) => _StatBox(icon: Icons.people_outline, label: 'Étudiants', valeur: '${s.data ?? 0}'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StreamBuilder<double>(
                  stream: firestore.watchTotalEncaisse(),
                  builder: (_, s) => _StatBox(icon: Icons.payments_outlined, label: 'Encaissé', valeur: '${(s.data ?? 0).toStringAsFixed(0)} MRU'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: StreamBuilder<double?>(
                  stream: firestore.watchMoyenneGenerale(),
                  builder: (_, s) => _StatBox(
                    icon: Icons.grade_outlined,
                    label: 'Moyenne générale',
                    valeur: s.data != null ? '${s.data!.toStringAsFixed(1)}/20' : '—',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StreamBuilder<double?>(
                  stream: firestore.watchTauxPresenceGlobal(),
                  builder: (_, s) => _StatBox(
                    icon: Icons.fact_check_outlined,
                    label: 'Taux de présence',
                    valeur: s.data != null ? '${s.data!.toStringAsFixed(0)}%' : '—',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: StreamBuilder<int>(
                  stream: firestore.watchNombreInscriptionsEnAttente(),
                  builder: (_, s) => _StatBox(icon: Icons.pending_actions_outlined, label: 'Inscriptions en attente', valeur: '${s.data ?? 0}'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StreamBuilder<int>(
                  stream: firestore.watchNombreInscriptionsValidees(),
                  builder: (_, s) => _StatBox(icon: Icons.how_to_reg_outlined, label: 'Inscriptions validées', valeur: '${s.data ?? 0}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Étudiants par formation', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          StreamBuilder<Map<String, int>>(
            stream: firestore.watchRepartitionParFormation(),
            builder: (context, snapshot) {
              final repartition = snapshot.data ?? {};
              if (repartition.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('Pas encore assez de données.', style: TextStyle(color: LazouColors.textSecondary)),
                );
              }
              final total = repartition.values.fold<int>(0, (a, b) => a + b);
              final entries = repartition.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
              return Column(
                children: entries.map((e) => _BarreFormation(titre: e.key, valeur: e.value, total: total)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valeur;
  const _StatBox({required this.icon, required this.label, required this.valeur});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: LazouColors.primary, size: 22),
            const SizedBox(height: 8),
            Text(valeur, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: LazouColors.textSecondary, fontSize: 11.5)),
          ],
        ),
      ),
    );
  }
}

/// Barre proportionnelle sans dépendance à un package de graphiques —
/// suffisant pour une répartition simple, et ça évite d'ajouter un nouveau
/// paquet qui pourrait encore casser le build Android.
class _BarreFormation extends StatelessWidget {
  final String titre;
  final int valeur;
  final int total;
  const _BarreFormation({required this.titre, required this.valeur, required this.total});

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : valeur / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(titre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
              Text('$valeur', style: const TextStyle(fontWeight: FontWeight.w800, color: LazouColors.primary)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: LazouColors.primary.withValues(alpha: 0.08),
              color: LazouColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
