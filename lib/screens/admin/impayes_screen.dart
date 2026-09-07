import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/payment_model.dart';
import '../../models/student_profile.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import 'paiements_screen.dart';

/// Vue de recouvrement : le solde est toujours recalculé depuis les paiements
/// et le montant dû de l'étudiant. Aucun « reste » n'est stocké en double.
class ImpayesScreen extends StatefulWidget {
  const ImpayesScreen({super.key});

  @override
  State<ImpayesScreen> createState() => _ImpayesScreenState();
}

class _ImpayesScreenState extends State<ImpayesScreen> {
  String _recherche = '';
  bool _seulementImpayes = true;

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Suivi des impayés')),
      body: FutureBuilder<List<StudentProfile>>(
        future: firestore.getEtudiantsOnce(),
        builder: (context, studentsSnap) {
          if (studentsSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (studentsSnap.hasError) {
            return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Impossible de charger les étudiants.\n${studentsSnap.error}')));
          }
          final students = studentsSnap.data ?? const <StudentProfile>[];
          return StreamBuilder<List<Paiement>>(
            stream: firestore.watchTousLesPaiements(),
            builder: (context, paymentsSnap) {
              if (paymentsSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (paymentsSnap.hasError) {
                return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Impossible de charger les paiements.\n${paymentsSnap.error}')));
              }
              final payments = paymentsSnap.data ?? const <Paiement>[];
              final totals = <String, double>{};
              for (final payment in payments) {
                totals[payment.etudiantUid] = (totals[payment.etudiantUid] ?? 0) + payment.montant;
              }

              final rows = students.map((student) {
                final paid = totals[student.uid] ?? 0;
                final reste = (student.montantDu - paid).clamp(0, double.infinity).toDouble();
                return _DebtRow(student: student, paid: paid, reste: reste);
              }).where((row) {
                final matches = _recherche.isEmpty ||
                    '${row.student.nomComplet} ${row.student.email} ${row.student.telephone} ${row.student.formationTitre ?? ''}'
                        .toLowerCase()
                        .contains(_recherche);
                return matches && (!_seulementImpayes || row.reste > 0);
              }).toList()
                ..sort((a, b) => b.reste.compareTo(a.reste));

              final totalDu = rows.fold<double>(0, (sum, row) => sum + row.reste);
              final nombreImpayes = rows.where((row) => row.reste > 0).length;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: TextField(
                      onChanged: (v) => setState(() => _recherche = v.trim().toLowerCase()),
                      decoration: InputDecoration(
                        hintText: 'Rechercher un étudiant...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _recherche.isEmpty ? null : IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _recherche = '')),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(backgroundColor: LazouColors.error.withValues(alpha: .12), child: const Icon(Icons.account_balance_wallet_outlined, color: LazouColors.error)),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('${totalDu.toStringAsFixed(0)} MRU', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                              Text('$nombreImpayes étudiant${nombreImpayes > 1 ? 's' : ''} avec un solde', style: const TextStyle(color: LazouColors.textSecondary)),
                            ])),
                            Switch(value: _seulementImpayes, onChanged: (v) => setState(() => _seulementImpayes = v)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: rows.isEmpty
                        ? Center(child: Text(_seulementImpayes ? 'Aucun impayé 🎉' : 'Aucun étudiant trouvé.'))
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            itemCount: rows.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (_, index) => _DebtCard(row: rows[index]),
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _DebtRow {
  final StudentProfile student;
  final double paid;
  final double reste;
  const _DebtRow({required this.student, required this.paid, required this.reste});
}

class _DebtCard extends StatelessWidget {
  final _DebtRow row;
  const _DebtCard({required this.row});

  @override
  Widget build(BuildContext context) {
    final student = row.student;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: LazouColors.primary.withValues(alpha: .10), child: Text(student.nomComplet.isEmpty ? '?' : student.nomComplet[0].toUpperCase())),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(student.nomComplet.isEmpty ? 'Étudiant sans nom' : student.nomComplet, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(student.formationTitre ?? 'Formation non affectée', style: const TextStyle(color: LazouColors.textSecondary)),
              const SizedBox(height: 8),
              Text('Payé : ${row.paid.toStringAsFixed(0)} MRU  •  Dû : ${student.montantDu.toStringAsFixed(0)} MRU', style: const TextStyle(fontSize: 12, color: LazouColors.textSecondary)),
            ])),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${row.reste.toStringAsFixed(0)} MRU', style: const TextStyle(fontWeight: FontWeight.w900, color: LazouColors.error)),
              const SizedBox(height: 6),
              FilledButton.tonal(
                onPressed: () => PaiementsScreen.ouvrirFormulaire(context, context.read<FirestoreService>(), etudiantPreselectionne: student),
                child: const Text('Encaisser'),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
