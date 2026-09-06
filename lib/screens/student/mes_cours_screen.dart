import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/material_model.dart';
import '../../models/student_profile.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class MesCoursScreen extends StatelessWidget {
  const MesCoursScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthService>().user?.uid;
    final firestore = context.read<FirestoreService>();

    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Connecte-toi pour voir tes cours.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mes cours')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: firestore.watchEtudiant(uid),
        builder: (context, profilSnap) {
          if (!profilSnap.hasData) return const Center(child: CircularProgressIndicator());
          final student = StudentProfile.fromDoc(profilSnap.data!);

          if (student.groupeId == null || student.groupeId!.isEmpty) {
            return const Center(child: Text('Aucun support — tu n\'es pas encore affecté à un groupe.'));
          }

          return StreamBuilder<List<Materiau>>(
            stream: firestore.watchMateriauxDuGroupe(student.groupeId!),
            builder: (context, snapshot) {
              final materiaux = snapshot.data ?? [];
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (materiaux.isEmpty) {
                return const Center(child: Text('Aucun support publié pour l\'instant.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: materiaux.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final m = materiaux[i];
                  return Card(
                    child: ListTile(
                      leading: Icon(_iconePour(m.type), color: LazouColors.primary),
                      title: Text(m.titre, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('${m.type.label} • par ${m.publieParNom}'),
                      trailing: const Icon(Icons.download_outlined),
                      onTap: () => launchUrl(Uri.parse(m.url), mode: LaunchMode.externalApplication),
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

  IconData _iconePour(TypeMateriau type) => switch (type) {
        TypeMateriau.pdf => Icons.picture_as_pdf_outlined,
        TypeMateriau.image => Icons.image_outlined,
        TypeMateriau.document => Icons.description_outlined,
        TypeMateriau.autre => Icons.insert_drive_file_outlined,
      };
}
