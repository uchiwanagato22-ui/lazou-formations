import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/group_model.dart';
import '../../models/student_profile.dart';
import '../../models/user_role.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

/// Sert deux besoins à la fois : voir qui est dans sa classe (formateur ET
/// directeur, dès qu'un étudiant est affecté à un groupe il apparaît ici),
/// et rentrer/corriger les matricules de toute une classe en une seule
/// saisie plutôt qu'étudiant par étudiant.
class MaClasseScreen extends StatefulWidget {
  const MaClasseScreen({super.key});

  @override
  State<MaClasseScreen> createState() => _MaClasseScreenState();
}

class _MaClasseScreenState extends State<MaClasseScreen> {
  FormationGroup? _groupe;
  final Map<String, TextEditingController> _controllers = {};
  bool _enregistrement = false;

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
    final auth = context.read<AuthService>();
    final uid = auth.user?.uid;
    final role = auth.role;

    return Scaffold(
      appBar: AppBar(title: const Text('Ma classe')),
      floatingActionButton: _groupe == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _enregistrement ? null : _enregistrerTout,
              icon: _enregistrement
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save),
              label: Text(_enregistrement ? 'Enregistrement...' : 'Enregistrer les matricules'),
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
                if (role == UserRole.formateur) {
                  groupes = groupes.where((g) => g.formateurUid == uid).toList();
                }
                if (groupes.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Aucun groupe pour l\'instant.', textAlign: TextAlign.center),
                    ),
                  );
                }
                _groupe ??= groupes.first;
                if (!groupes.any((g) => g.id == _groupe!.id)) _groupe = groupes.first;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: DropdownButtonFormField<FormationGroup>(
                        initialValue: _groupe,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Groupe'),
                        items: groupes
                            .map((g) => DropdownMenuItem(
                                  value: g,
                                  child: Text(
                                    '${g.nom}${g.horaire.isNotEmpty ? ' — ${g.horaire}' : ''}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (g) => setState(() => _groupe = g),
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<List<StudentProfile>>(
                        stream: service.watchEtudiantsDuGroupe(_groupe!.id),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final etudiants = snap.data ?? [];
                          if (etudiants.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: Text(
                                  'Aucun étudiant affecté à ce groupe pour l\'instant.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: LazouColors.textSecondary),
                                ),
                              ),
                            );
                          }
                          for (final e in etudiants) {
                            _controllers.putIfAbsent(e.uid, () => TextEditingController(text: e.matricule));
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                            itemCount: etudiants.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, i) {
                              final e = etudiants[i];
                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: LazouColors.primary.withValues(alpha: .1),
                                    foregroundColor: LazouColors.primary,
                                    child: Text('${i + 1}'),
                                  ),
                                  title: Text(
                                    e.nomComplet.isEmpty ? 'Étudiant sans nom' : e.nomComplet,
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  subtitle: e.telephone.isNotEmpty ? Text(e.telephone) : null,
                                  trailing: SizedBox(
                                    width: 100,
                                    child: TextField(
                                      controller: _controllers[e.uid],
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(hintText: 'Matricule', isDense: true),
                                    ),
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

  Future<void> _enregistrerTout() async {
    setState(() => _enregistrement = true);
    final service = context.read<FirestoreService>();
    final matricules = {for (final e in _controllers.entries) e.key: e.value.text.trim()};
    try {
      await service.enregistrerMatriculesGroupe(matricules);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Matricules enregistrés ✓')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Échec : $e')));
      }
    } finally {
      if (mounted) setState(() => _enregistrement = false);
    }
  }
}
