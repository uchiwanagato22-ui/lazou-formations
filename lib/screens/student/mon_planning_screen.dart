import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/group_model.dart';
import '../../models/student_profile.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class MonPlanningScreen extends StatelessWidget {
  const MonPlanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthService>().user?.uid;
    final firestore = context.read<FirestoreService>();

    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Connecte-toi pour voir ton planning.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mon planning')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: firestore.watchEtudiant(uid),
        builder: (context, profilSnap) {
          if (!profilSnap.hasData) return const Center(child: CircularProgressIndicator());
          final student = StudentProfile.fromDoc(profilSnap.data!);

          if (student.groupeId == null || student.groupeId!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Pas encore de planning — tu seras affecté à un groupe par l\'administration après validation de ton inscription.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: LazouColors.textSecondary),
                ),
              ),
            );
          }

          return StreamBuilder<FormationGroup?>(
            stream: firestore.watchGroupe(student.groupeId!),
            builder: (context, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final groupe = snap.data;
              if (groupe == null) return const Center(child: Text('Groupe introuvable.'));

              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      color: LazouColors.primary,
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(groupe.formationTitre,
                                style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            Text(groupe.nom,
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _LigneInfo(icon: Icons.calendar_today_outlined, label: 'Jours', valeur: groupe.jours.isNotEmpty ? groupe.jours : 'À confirmer'),
                    _LigneInfo(icon: Icons.schedule, label: 'Horaire', valeur: groupe.horaire.isNotEmpty ? groupe.horaire : 'À confirmer'),
                    _LigneInfo(icon: Icons.meeting_room_outlined, label: 'Salle', valeur: groupe.salle.isNotEmpty ? groupe.salle : 'À confirmer'),
                    _LigneInfo(icon: Icons.person_outline, label: 'Formateur', valeur: groupe.formateurNom ?? 'À confirmer'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _LigneInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valeur;
  const _LigneInfo({required this.icon, required this.label, required this.valeur});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: LazouColors.primary),
        title: Text(label, style: const TextStyle(color: LazouColors.textSecondary, fontSize: 12)),
        subtitle: Text(valeur, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      ),
    );
  }
}
