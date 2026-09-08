import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/group_model.dart';
import '../../models/student_profile.dart';
import '../../models/user_role.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

/// L'étudiant dit son matricule ("33842"), le formateur le tape, l'app
/// affiche son nom pour confirmation, un tap sur Présent/Retard/Absent
/// enregistre et prépare direct la saisie du suivant. Pensé pour aller
/// aussi vite que le cahier papier, pas plus lent.
class PointageMatriculeScreen extends StatefulWidget {
  const PointageMatriculeScreen({super.key});

  @override
  State<PointageMatriculeScreen> createState() => _PointageMatriculeScreenState();
}

class _PointageMatriculeScreenState extends State<PointageMatriculeScreen> {
  FormationGroup? _groupe;
  final _matriculeCtrl = TextEditingController();
  final _focusMatricule = FocusNode();
  StudentProfile? _etudiantTrouve;
  bool _recherche = false;
  String? _erreur;

  @override
  void dispose() {
    _matriculeCtrl.dispose();
    _focusMatricule.dispose();
    super.dispose();
  }

  Future<void> _chercher(FirestoreService service) async {
    final matricule = _matriculeCtrl.text.trim();
    if (matricule.isEmpty) return;
    setState(() {
      _recherche = true;
      _erreur = null;
      _etudiantTrouve = null;
    });
    final resultat = await service.chercherParMatricule(matricule);
    if (!mounted) return;
    setState(() {
      _recherche = false;
      if (resultat == null) {
        _erreur = 'Aucun étudiant avec le matricule $matricule.';
      } else {
        _etudiantTrouve = resultat;
      }
    });
  }

  Future<void> _pointer(FirestoreService service, String statut) async {
    if (_etudiantTrouve == null || _groupe == null) return;
    await service.pointerPresenceUnique(_groupe!, DateTime.now(), _etudiantTrouve!.uid, statut);
    setState(() {
      _etudiantTrouve = null;
      _matriculeCtrl.clear();
    });
    _focusMatricule.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final service = context.read<FirestoreService>();
    final auth = context.read<AuthService>();
    final uid = auth.user?.uid;
    final role = auth.role;
    final aujourdhui = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Pointage rapide')),
      body: uid == null
          ? const Center(child: Text('Session introuvable.'))
          : StreamBuilder<List<FormationGroup>>(
              stream: service.watchGroupes(),
              builder: (context, groupsSnap) {
                var groupes = groupsSnap.data ?? [];
                if (role == UserRole.formateur) {
                  groupes = groupes.where((g) => g.formateurUid == uid).toList();
                }
                if (groupsSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (groupes.isEmpty) {
                  return const Center(child: Text('Aucun groupe disponible.'));
                }
                _groupe ??= groupes.first;
                if (!groupes.any((g) => g.id == _groupe!.id)) _groupe = groupes.first;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: DropdownButtonFormField<FormationGroup>(
                        initialValue: _groupe,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Groupe — séance d\'aujourd\'hui'),
                        items: groupes.map((g) => DropdownMenuItem(value: g, child: Text(g.nom))).toList(),
                        onChanged: (g) => setState(() {
                          _groupe = g;
                          _etudiantTrouve = null;
                        }),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _matriculeCtrl,
                              focusNode: _focusMatricule,
                              autofocus: true,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _chercher(service),
                              decoration: const InputDecoration(
                                labelText: 'Matricule',
                                hintText: 'ex: 33842',
                                prefixIcon: Icon(Icons.badge_outlined),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _recherche ? null : () => _chercher(service),
                            child: _recherche
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('OK'),
                          ),
                        ],
                      ),
                    ),
                    if (_erreur != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(_erreur!, style: const TextStyle(color: LazouColors.error)),
                      ),
                    if (_etudiantTrouve != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Card(
                          color: LazouColors.primary,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('#${_etudiantTrouve!.matricule}',
                                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                Text(_etudiantTrouve!.nomComplet,
                                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _BoutonStatut(
                                        label: 'Présent',
                                        couleur: LazouColors.success,
                                        onTap: () => _pointer(service, 'present'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _BoutonStatut(
                                        label: 'Retard',
                                        couleur: LazouColors.secondary,
                                        onTap: () => _pointer(service, 'retard'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _BoutonStatut(
                                        label: 'Absent',
                                        couleur: LazouColors.error,
                                        onTap: () => _pointer(service, 'absent'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const Divider(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Déjà pointés aujourd\'hui', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.grey.shade700)),
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<Map<String, String>>(
                        stream: service.watchPresencesJour(_groupe!.id, aujourdhui),
                        builder: (context, presSnap) {
                          final pointes = presSnap.data ?? {};
                          if (pointes.isEmpty) {
                            return const Center(child: Text('Personne pointé pour l\'instant.'));
                          }
                          return StreamBuilder<List<StudentProfile>>(
                            stream: service.watchEtudiantsDuGroupe(_groupe!.id),
                            builder: (context, etudSnap) {
                              final etudiants = {for (final e in etudSnap.data ?? <StudentProfile>[]) e.uid: e};
                              final entrees = pointes.entries.toList();
                              return ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                                itemCount: entrees.length,
                                itemBuilder: (context, i) {
                                  final uid = entrees[i].key;
                                  final statut = entrees[i].value;
                                  final e = etudiants[uid];
                                  return ListTile(
                                    dense: true,
                                    leading: Icon(
                                      statut == 'present'
                                          ? Icons.check_circle_outline
                                          : statut == 'retard'
                                              ? Icons.access_time
                                              : Icons.cancel_outlined,
                                      color: statut == 'present'
                                          ? LazouColors.success
                                          : statut == 'retard'
                                              ? LazouColors.secondary
                                              : LazouColors.error,
                                    ),
                                    title: Text(e != null ? '#${e.matricule} — ${e.nomComplet}' : uid),
                                  );
                                },
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
}

class _BoutonStatut extends StatelessWidget {
  final String label;
  final Color couleur;
  final VoidCallback onTap;
  const _BoutonStatut({required this.label, required this.couleur, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(backgroundColor: couleur, foregroundColor: Colors.white),
      child: Text(label),
    );
  }
}
