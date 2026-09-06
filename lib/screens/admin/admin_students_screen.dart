import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/payment_model.dart';
import '../../models/student_profile.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import 'paiements_screen.dart';

class AdminStudentsScreen extends StatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  String _recherche = '';

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Étudiants')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: (value) => setState(() => _recherche = value.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Rechercher un étudiant...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _recherche.isEmpty ? null : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _recherche = ''),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<StudentProfile>>(
              stream: firestore.watchEtudiants(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return _ErrorState(message: snapshot.error.toString());
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final students = (snapshot.data ?? []).where((s) {
                  if (_recherche.isEmpty) return true;
                  return '${s.nomComplet} ${s.email} ${s.telephone} ${s.formationTitre ?? ''}'
                      .toLowerCase().contains(_recherche);
                }).toList();
                if (students.isEmpty) {
                  return const Center(child: Text('Aucun étudiant trouvé.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: students.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, index) => _StudentTile(student: students[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  final StudentProfile student;
  const _StudentTile({required this.student});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: LazouColors.primary.withValues(alpha: .12),
          child: Text(_initiales(student.nomComplet), style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
        title: Text(student.nomComplet.isEmpty ? 'Étudiant sans nom' : student.nomComplet,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text([
          if ((student.formationTitre ?? '').isNotEmpty) student.formationTitre!,
          if (student.telephone.isNotEmpty) student.telephone,
          if (student.email.isNotEmpty) student.email,
        ].join(' • ')),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AdminStudentDetailScreen(uid: student.uid)),
        ),
      ),
    );
  }

  static String _initiales(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class AdminStudentDetailScreen extends StatelessWidget {
  final String uid;
  const AdminStudentDetailScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Dossier étudiant')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: firestore.watchEtudiant(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Étudiant introuvable.'));
          }
          final student = StudentProfile.fromDoc(snapshot.data!);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Header(student: student),
              const SizedBox(height: 16),
              _InfoCard(title: 'Formation', icon: Icons.school_outlined, children: [
                _InfoRow('Formation', student.formationTitre ?? 'Non affectée'),
                _InfoRow('Groupe', student.groupeId ?? 'Non affecté'),
                _InfoRow('Statut', student.statut),
              ]),
              const SizedBox(height: 12),
              _InfoCard(title: 'Coordonnées', icon: Icons.contact_phone_outlined, children: [
                _InfoRow('Email', student.email.isEmpty ? '—' : student.email),
                _InfoRow('Téléphone', student.telephone.isEmpty ? '—' : student.telephone),
              ]),
              const SizedBox(height: 12),
              _FinancesCard(student: student),
              const SizedBox(height: 12),
              _InfoCard(title: 'Suivi', icon: Icons.analytics_outlined, children: const [
                _InfoRow('Présence', 'À connecter au module Présences'),
                _InfoRow('Résultats', 'À connecter au module Notes'),
                _InfoRow('Certificat', 'À connecter au module Certificats'),
              ]),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final StudentProfile student;
  const _Header({required this.student});
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(children: [
            CircleAvatar(radius: 30, child: Text(_initiales(student.nomComplet), style: const TextStyle(fontWeight: FontWeight.w800))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(student.nomComplet.isEmpty ? 'Étudiant' : student.nomComplet, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(student.email.isEmpty ? 'Compte étudiant' : student.email),
            ])),
          ]),
        ),
      );

  static String _initiales(String name) {
    final p = name.trim().split(RegExp(r'\s+')).where((x) => x.isNotEmpty).toList();
    if (p.isEmpty) return '?';
    return p.length == 1 ? p[0][0].toUpperCase() : '${p[0][0]}${p.last[0]}'.toUpperCase();
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _InfoCard({required this.title, required this.icon, required this.children});
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(icon, color: LazouColors.primary), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.w800))]),
            const SizedBox(height: 12),
            ...children,
          ]),
        ),
      );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: LazouColors.textSecondary))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ]),
      );
}

void _dialogueMontantDu(BuildContext context, FirestoreService firestore, StudentProfile student) {
  final ctrl = TextEditingController(text: student.montantDu > 0 ? student.montantDu.toStringAsFixed(0) : '');
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Montant dû'),
      content: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Montant total (MRU)'),
        autofocus: true,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Annuler')),
        ElevatedButton(
          onPressed: () {
            final montant = double.tryParse(ctrl.text);
            if (montant != null) firestore.definirMontantDu(student.uid, montant);
            Navigator.of(ctx).pop();
          },
          child: const Text('Enregistrer'),
        ),
      ],
    ),
  );
}

class _FinancesCard extends StatelessWidget {
  final StudentProfile student;
  const _FinancesCard({required this.student});

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.payments_outlined, color: LazouColors.primary),
              const SizedBox(width: 8),
              const Text('Finances', style: TextStyle(fontWeight: FontWeight.w800)),
              const Spacer(),
              TextButton.icon(
                onPressed: () => PaiementsScreen.ouvrirFormulaire(context, firestore, etudiantPreselectionne: student),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Encaisser'),
              ),
            ]),
            const SizedBox(height: 8),
            StreamBuilder<List<Paiement>>(
              stream: firestore.watchPaiementsEtudiant(student.uid),
              builder: (context, snapshot) {
                final paiements = snapshot.data ?? [];
                final paye = paiements.fold<double>(0, (t, p) => t + p.montant);
                final reste = (student.montantDu - paye).clamp(0, double.infinity);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _InfoRow('Montant dû', student.montantDu > 0 ? '${student.montantDu.toStringAsFixed(0)} MRU' : 'Non défini')),
                        TextButton(
                          onPressed: () => _dialogueMontantDu(context, firestore, student),
                          child: const Text('Modifier'),
                        ),
                      ],
                    ),
                    _InfoRow('Payé', '${paye.toStringAsFixed(0)} MRU'),
                    _InfoRow('Reste à payer', '${reste.toStringAsFixed(0)} MRU'),
                    if (paiements.isNotEmpty) ...[
                      const Divider(height: 20),
                      ...paiements.take(3).map((p) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              '${p.montant.toStringAsFixed(0)} MRU • ${p.methode.label}',
                              style: const TextStyle(fontSize: 12.5, color: LazouColors.textSecondary),
                            ),
                          )),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Impossible de charger les étudiants.\n$message', textAlign: TextAlign.center)));
}
