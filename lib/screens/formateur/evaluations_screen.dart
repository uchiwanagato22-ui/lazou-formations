import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/evaluation_model.dart';
import '../../models/group_model.dart';
import '../../models/student_profile.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

/// Même schéma que l'écran Présences : sélection d'un groupe (filtré sur
/// le formateur connecté), puis liste des évaluations de ce groupe.
class EvaluationsScreen extends StatefulWidget {
  const EvaluationsScreen({super.key});

  @override
  State<EvaluationsScreen> createState() => _EvaluationsScreenState();
}

class _EvaluationsScreenState extends State<EvaluationsScreen> {
  FormationGroup? _groupe;

  @override
  Widget build(BuildContext context) {
    final service = context.read<FirestoreService>();
    final uid = context.read<AuthService>().user?.uid;
    final role = context.read<AuthService>().role?.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Évaluations & notes')),
      floatingActionButton: _groupe == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _dialogueNouvelleEvaluation(context, service, _groupe!),
              icon: const Icon(Icons.add),
              label: const Text('Nouvelle évaluation'),
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
                if (groupes.isEmpty) {
                  return const Center(child: Text('Aucun groupe disponible.'));
                }
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
                      child: StreamBuilder<List<Evaluation>>(
                        stream: service.watchEvaluationsDuGroupe(_groupe!.id),
                        builder: (context, evalSnap) {
                          if (evalSnap.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final evaluations = evalSnap.data ?? [];
                          if (evaluations.isEmpty) {
                            return const Center(child: Text('Aucune évaluation pour ce groupe — crée-en une.'));
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                            itemCount: evaluations.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, i) {
                              final e = evaluations[i];
                              return Card(
                                child: ListTile(
                                  leading: const Icon(Icons.assignment_outlined, color: LazouColors.primary),
                                  title: Text(e.titre, style: const TextStyle(fontWeight: FontWeight.w700)),
                                  subtitle: Text(
                                    e.moyenne != null
                                        ? 'Moyenne du groupe : ${e.moyenne!.toStringAsFixed(1)}/20 (${e.notes.length} noté·e·s)'
                                        : 'Pas encore de notes saisies',
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => _SaisieNotesScreen(evaluation: e, groupeId: _groupe!.id)),
                                  ),
                                ),
                              );
                            },
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

  void _dialogueNouvelleEvaluation(BuildContext context, FirestoreService service, FormationGroup groupe) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouvelle évaluation'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Titre (ex: Excel — Évaluation 01)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) service.creerEvaluation(groupe, ctrl.text.trim());
              Navigator.of(ctx).pop();
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }
}

class _SaisieNotesScreen extends StatefulWidget {
  final Evaluation evaluation;
  final String groupeId;
  const _SaisieNotesScreen({required this.evaluation, required this.groupeId});

  @override
  State<_SaisieNotesScreen> createState() => _SaisieNotesScreenState();
}

class _SaisieNotesScreenState extends State<_SaisieNotesScreen> {
  late Map<String, TextEditingController> _controllers;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controllers = {};
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = context.read<FirestoreService>();

    return Scaffold(
      appBar: AppBar(title: Text(widget.evaluation.titre)),
      body: StreamBuilder<List<StudentProfile>>(
        stream: service.watchEtudiantsDuGroupe(widget.groupeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final etudiants = snapshot.data ?? [];
          if (etudiants.isEmpty) {
            return const Center(child: Text('Aucun étudiant dans ce groupe.'));
          }
          for (final e in etudiants) {
            _controllers.putIfAbsent(
              e.uid,
              () => TextEditingController(text: widget.evaluation.noteDe(e.uid)?.toString() ?? ''),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: etudiants.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final e = etudiants[i];
              return Card(
                child: ListTile(
                  title: Text(e.nomComplet, style: const TextStyle(fontWeight: FontWeight.w700)),
                  trailing: SizedBox(
                    width: 70,
                    child: TextField(
                      controller: _controllers[e.uid],
                      textAlign: TextAlign.center,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(suffixText: '/20', isDense: true),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saving
            ? null
            : () async {
                setState(() => _saving = true);
                final notes = <String, double>{};
                _controllers.forEach((uid, ctrl) {
                  final v = double.tryParse(ctrl.text.replaceAll(',', '.'));
                  if (v != null) notes[uid] = v.clamp(0, 20).toDouble();
                });
                await service.enregistrerNotes(widget.evaluation.id, notes);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notes enregistrées ✓')));
                  Navigator.of(context).pop();
                }
              },
        icon: _saving
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.save),
        label: Text(_saving ? 'Enregistrement...' : 'Enregistrer'),
      ),
    );
  }
}
