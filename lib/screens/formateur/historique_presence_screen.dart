import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/student_profile.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';

/// Vue "carnet de présence" par étudiant — exactement ce que Lazou utilise
/// au quotidien : matricule, puis la liste jour par jour (présent/absent/
/// retard). Accessible admin ET formateur, recherche par matricule ou nom.
class HistoriquePresenceScreen extends StatefulWidget {
  const HistoriquePresenceScreen({super.key});

  @override
  State<HistoriquePresenceScreen> createState() => _HistoriquePresenceScreenState();
}

class _HistoriquePresenceScreenState extends State<HistoriquePresenceScreen> {
  String _recherche = '';
  StudentProfile? _selectionne;

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();

    if (_selectionne != null) {
      return _DetailHistorique(
        etudiant: _selectionne!,
        onRetour: () => setState(() => _selectionne = null),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Historique des présences')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _recherche = v.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Matricule ou nom de l\'étudiant...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _recherche.isEmpty
                    ? null
                    : IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _recherche = '')),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<StudentProfile>>(
              future: firestore.getEtudiantsOnce(),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final etudiants = snap.data!.where((e) {
                  if (_recherche.isEmpty) return true;
                  return '${e.matricule} ${e.nomComplet}'.toLowerCase().contains(_recherche);
                }).toList();
                if (etudiants.isEmpty) {
                  return const EmptyState(icon: Icons.badge_outlined, message: 'Aucun étudiant ne correspond.');
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: etudiants.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final e = etudiants[i];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: LazouColors.primary.withValues(alpha: .1),
                          foregroundColor: LazouColors.primary,
                          child: const Icon(Icons.badge_outlined, size: 18),
                        ),
                        title: Text(
                          e.matricule.isNotEmpty ? '#${e.matricule} — ${e.nomComplet}' : e.nomComplet,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(e.formationTitre ?? 'Formation non affectée'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => setState(() => _selectionne = e),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailHistorique extends StatelessWidget {
  final StudentProfile etudiant;
  final VoidCallback onRetour;
  const _DetailHistorique({required this.etudiant, required this.onRetour});

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: onRetour),
        title: Text(etudiant.matricule.isNotEmpty ? '#${etudiant.matricule} — ${etudiant.nomComplet}' : etudiant.nomComplet),
      ),
      body: (etudiant.groupeId == null || etudiant.groupeId!.isEmpty)
          ? const EmptyState(icon: Icons.groups_outlined, message: 'Cet étudiant n\'est affecté à aucun groupe — pas d\'historique possible.')
          : StreamBuilder<List<({DateTime date, String statut})>>(
              stream: firestore.watchMesPresences(etudiant.uid, etudiant.groupeId!),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final presences = snap.data ?? [];
                if (presences.isEmpty) {
                  return const EmptyState(icon: Icons.fact_check_outlined, message: 'Aucune présence enregistrée pour l\'instant.');
                }
                final presents = presences.where((p) => p.statut == 'present').length;
                final taux = presents / presences.length * 100;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      color: LazouColors.primary,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            const Icon(Icons.fact_check_outlined, color: Colors.white, size: 26),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${taux.toStringAsFixed(0)}%',
                                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                                Text('$presents/${presences.length} séances présentes',
                                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Journal jour par jour', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                    const SizedBox(height: 8),
                    ...presences.map((p) => Card(
                          margin: const EdgeInsets.only(bottom: 6),
                          child: ListTile(
                            dense: true,
                            leading: Icon(_icone(p.statut), color: _couleur(p.statut)),
                            title: Text('${p.date.day.toString().padLeft(2, '0')}/${p.date.month.toString().padLeft(2, '0')}/${p.date.year}'),
                            trailing: Text(_label(p.statut), style: TextStyle(color: _couleur(p.statut), fontWeight: FontWeight.w700)),
                          ),
                        )),
                  ],
                );
              },
            ),
    );
  }

  IconData _icone(String s) => switch (s) {
        'present' => Icons.check_circle_outline,
        'retard' => Icons.access_time,
        _ => Icons.cancel_outlined,
      };
  Color _couleur(String s) => switch (s) {
        'present' => LazouColors.success,
        'retard' => LazouColors.secondary,
        _ => LazouColors.error,
      };
  String _label(String s) => switch (s) {
        'present' => 'PRÉSENT',
        'retard' => 'RETARD',
        _ => 'ABSENT',
      };
}
