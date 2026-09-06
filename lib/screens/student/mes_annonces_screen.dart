import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/announcement_model.dart';
import '../../models/student_profile.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class MesAnnoncesScreen extends StatelessWidget {
  const MesAnnoncesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthService>().user?.uid;
    final firestore = context.read<FirestoreService>();

    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Connecte-toi pour voir les annonces.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Annonces')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: firestore.watchEtudiant(uid),
        builder: (context, profilSnap) {
          if (!profilSnap.hasData) return const Center(child: CircularProgressIndicator());
          final student = StudentProfile.fromDoc(profilSnap.data!);

          if (student.groupeId == null || student.groupeId!.isEmpty) {
            return const Center(child: Text('Aucune annonce — tu n\'es pas encore affecté à un groupe.'));
          }

          return StreamBuilder<List<Annonce>>(
            stream: firestore.watchAnnoncesDuGroupe(student.groupeId!),
            builder: (context, snapshot) {
              final annonces = snapshot.data ?? [];
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (annonces.isEmpty) {
                return const Center(child: Text('Aucune annonce pour l\'instant.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: annonces.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final a = annonces[i];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.campaign_outlined, color: LazouColors.secondary, size: 20),
                              const SizedBox(width: 8),
                              Expanded(child: Text(a.titre, style: const TextStyle(fontWeight: FontWeight.w800))),
                            ],
                          ),
                          if (a.message.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(a.message, style: const TextStyle(fontSize: 13.5, height: 1.4)),
                          ],
                          const SizedBox(height: 6),
                          Text('— ${a.formateurNom}', style: const TextStyle(fontSize: 11.5, color: LazouColors.textSecondary)),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
