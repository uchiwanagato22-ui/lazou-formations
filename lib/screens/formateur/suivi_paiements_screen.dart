import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/group_model.dart';
import '../../models/payment_model.dart';
import '../../models/student_profile.dart';
import '../../models/user_role.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';

/// "Qui a payé, qui n'a pas payé" par groupe — la question de fin de mois.
/// Lecture seule ici : l'encaissement reste sur PaiementsScreen (admin/caissier).
class SuiviPaiementsScreen extends StatefulWidget {
  const SuiviPaiementsScreen({super.key});

  @override
  State<SuiviPaiementsScreen> createState() => _SuiviPaiementsScreenState();
}

class _SuiviPaiementsScreenState extends State<SuiviPaiementsScreen> {
  FormationGroup? _groupe;

  @override
  Widget build(BuildContext context) {
    final service = context.read<FirestoreService>();
    final auth = context.read<AuthService>();
    final uid = auth.user?.uid;
    final role = auth.role;

    return Scaffold(
      appBar: AppBar(title: const Text('Suivi des paiements')),
      body: uid == null
          ? const EmptyState(icon: Icons.inbox_outlined, message: 'Session introuvable.')
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
                if (groupes.isEmpty) return const EmptyState(icon: Icons.groups_outlined, message: 'Aucun groupe disponible.');
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
                        items: groupes.map((g) => DropdownMenuItem(value: g, child: Text(g.nom))).toList(),
                        onChanged: (g) => setState(() => _groupe = g),
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<List<StudentProfile>>(
                        stream: service.watchEtudiantsDuGroupe(_groupe!.id),
                        builder: (context, snap) {
                          final etudiants = snap.data ?? [];
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (etudiants.isEmpty) {
                            return const EmptyState(icon: Icons.groups_outlined, message: 'Aucun étudiant dans ce groupe.');
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: etudiants.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, i) => _LigneEtudiant(etudiant: etudiants[i]),
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

class _LigneEtudiant extends StatelessWidget {
  final StudentProfile etudiant;
  const _LigneEtudiant({required this.etudiant});

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();

    // Mensualité définie -> la vraie question de Lazou : "ce mois est-il
    // payé ?", pas un solde théorique global.
    if (etudiant.mensualite > 0) {
      final moisCourant = cleMois(DateTime.now());
      return StreamBuilder<bool>(
        stream: firestore.watchMoisPaye(etudiant.uid, moisCourant),
        builder: (context, snap) {
          final paye = snap.data ?? false;
          return Card(
            child: ListTile(
              leading: Icon(
                paye ? Icons.check_circle_outline : Icons.error_outline,
                color: paye ? LazouColors.success : LazouColors.error,
              ),
              title: Text(
                etudiant.matricule.isNotEmpty ? '#${etudiant.matricule} — ${etudiant.nomComplet}' : etudiant.nomComplet,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text('Mensualité : ${etudiant.mensualite.toStringAsFixed(0)} MRU/mois'),
              trailing: paye
                  ? const Text('Mois payé', style: TextStyle(color: LazouColors.success, fontWeight: FontWeight.w700))
                  : const Text('Mois dû', style: TextStyle(color: LazouColors.error, fontWeight: FontWeight.w700)),
            ),
          );
        },
      );
    }

    // Repli : logique historique par montant total (formations à tarif
    // unique plutôt que mensuel).
    return StreamBuilder<List<Paiement>>(
      stream: firestore.watchPaiementsEtudiant(etudiant.uid),
      builder: (context, snap) {
        final paiements = snap.data ?? [];
        final paye = paiements.fold<double>(0, (t, p) => t + p.montant);
        final reste = (etudiant.montantDu - paye).clamp(0, double.infinity);
        final estAJour = etudiant.montantDu > 0 && reste <= 0;

        return Card(
          child: ListTile(
            leading: Icon(
              estAJour ? Icons.check_circle_outline : Icons.error_outline,
              color: estAJour ? LazouColors.success : LazouColors.error,
            ),
            title: Text(
              etudiant.matricule.isNotEmpty ? '#${etudiant.matricule} — ${etudiant.nomComplet}' : etudiant.nomComplet,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              etudiant.montantDu <= 0
                  ? 'Montant dû non défini'
                  : 'Payé ${paye.toStringAsFixed(0)} / ${etudiant.montantDu.toStringAsFixed(0)} MRU',
            ),
            trailing: reste > 0
                ? Text('${reste.toStringAsFixed(0)} MRU\nrestant',
                    textAlign: TextAlign.right, style: const TextStyle(color: LazouColors.error, fontWeight: FontWeight.w700, fontSize: 12))
                : const Text('À jour', style: TextStyle(color: LazouColors.success, fontWeight: FontWeight.w700)),
          ),
        );
      },
    );
  }
}
