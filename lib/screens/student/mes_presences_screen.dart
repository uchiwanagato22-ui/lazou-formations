import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/student_profile.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class MesPresencesScreen extends StatelessWidget {
  const MesPresencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthService>().user?.uid;
    final firestore = context.read<FirestoreService>();

    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Connecte-toi pour voir tes présences.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mes présences')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: firestore.watchEtudiant(uid),
        builder: (context, profilSnap) {
          if (!profilSnap.hasData) return const Center(child: CircularProgressIndicator());
          final student = StudentProfile.fromDoc(profilSnap.data!);

          if (student.groupeId == null || student.groupeId!.isEmpty) {
            return const Center(child: Text('Pas encore de groupe — rien à afficher.'));
          }

          return StreamBuilder<List<({DateTime date, String statut})>>(
            stream: firestore.watchMesPresences(uid, student.groupeId!),
            builder: (context, snapshot) {
              final presences = snapshot.data ?? [];
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (presences.isEmpty) {
                return const Center(child: Text('Aucune présence enregistrée pour l\'instant.'));
              }
              final presents = presences.where((p) => p.statut == 'present').length;
              final taux = presents / presences.length * 100;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    color: LazouColors.primary,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          const Icon(Icons.fact_check_outlined, color: Colors.white, size: 28),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${taux.toStringAsFixed(0)}%',
                                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                              Text('Taux de présence ($presents/${presences.length} séances)',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...presences.map((p) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(_iconePour(p.statut), color: _couleurPour(p.statut)),
                          title: Text('${p.date.day}/${p.date.month}/${p.date.year}'),
                          trailing: Text(_labelPour(p.statut), style: TextStyle(color: _couleurPour(p.statut), fontWeight: FontWeight.w700)),
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

  IconData _iconePour(String statut) => switch (statut) {
        'present' => Icons.check_circle_outline,
        'retard' => Icons.access_time,
        _ => Icons.cancel_outlined,
      };

  Color _couleurPour(String statut) => switch (statut) {
        'present' => LazouColors.success,
        'retard' => LazouColors.secondary,
        _ => LazouColors.error,
      };

  String _labelPour(String statut) => switch (statut) {
        'present' => 'Présent',
        'retard' => 'Retard',
        _ => 'Absent',
      };
}
