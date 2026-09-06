import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/evaluation_model.dart';
import '../../models/student_profile.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class MesResultatsScreen extends StatelessWidget {
  const MesResultatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthService>().user?.uid;
    final firestore = context.read<FirestoreService>();

    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Connecte-toi pour voir tes résultats.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mes résultats')),
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
                  'Tu n\'es affecté à aucun groupe pour l\'instant — reviens une fois inscrit et affecté par l\'administration.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return StreamBuilder<List<Evaluation>>(
            stream: firestore.watchEvaluationsDuGroupe(student.groupeId!),
            builder: (context, snapshot) {
              final evaluations = snapshot.data ?? [];
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (evaluations.isEmpty) {
                return const Center(child: Text('Aucune évaluation notée pour l\'instant.'));
              }

              final mesNotes = evaluations.where((e) => e.noteDe(uid) != null).toList();
              final moyennePersonnelle = mesNotes.isEmpty
                  ? null
                  : mesNotes.map((e) => e.noteDe(uid)!).reduce((a, b) => a + b) / mesNotes.length;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (moyennePersonnelle != null)
                    Card(
                      color: LazouColors.primary,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: LazouColors.secondary, size: 28),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${moyennePersonnelle.toStringAsFixed(1)}/20',
                                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                                const Text('Ma moyenne générale', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  ...evaluations.map((e) {
                    final maNote = e.noteDe(uid);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(e.titre, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(e.moyenne != null ? 'Moyenne du groupe : ${e.moyenne!.toStringAsFixed(1)}/20' : 'Pas encore de moyenne'),
                        trailing: Text(
                          maNote != null ? '${maNote.toStringAsFixed(1)}/20' : 'En attente',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: maNote != null ? LazouColors.primary : LazouColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
