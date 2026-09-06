import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/payment_model.dart';
import '../../models/student_profile.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

/// Lecture seule côté étudiant — seul le staff (admin/caissier) peut
/// enregistrer un paiement, depuis PaiementsScreen.
class MesPaiementsScreen extends StatelessWidget {
  const MesPaiementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthService>().user?.uid;
    final firestore = context.read<FirestoreService>();

    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Connecte-toi pour voir tes paiements.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mes paiements')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: firestore.watchEtudiant(uid),
        builder: (context, profilSnap) {
          if (!profilSnap.hasData) return const Center(child: CircularProgressIndicator());
          final student = StudentProfile.fromDoc(profilSnap.data!);

          return StreamBuilder<List<Paiement>>(
            stream: firestore.watchPaiementsEtudiant(uid),
            builder: (context, snapshot) {
              final paiements = snapshot.data ?? [];
              final paye = paiements.fold<double>(0, (t, p) => t + p.montant);
              final reste = (student.montantDu - paye).clamp(0, double.infinity);

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    color: LazouColors.primary,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Formation', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Text(student.formationTitre ?? 'Non affectée',
                              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _Stat(label: 'Dû', valeur: student.montantDu),
                              _Stat(label: 'Payé', valeur: paye),
                              _Stat(label: 'Reste', valeur: reste.toDouble(), accent: true),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Historique', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 10),
                  if (paiements.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('Aucun paiement enregistré pour l\'instant.', style: TextStyle(color: LazouColors.textSecondary)),
                    )
                  else
                    ...paiements.map((p) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.check_circle_outline, color: LazouColors.success),
                            title: Text('${p.montant.toStringAsFixed(0)} MRU', style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text(p.methode.label),
                            trailing: p.date != null
                                ? Text('${p.date!.day}/${p.date!.month}/${p.date!.year}', style: const TextStyle(fontSize: 12))
                                : null,
                          ),
                        )),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final double valeur;
  final bool accent;
  const _Stat({required this.label, required this.valeur, this.accent = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          Text(
            '${valeur.toStringAsFixed(0)}',
            style: TextStyle(
              color: accent ? LazouColors.secondary : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
