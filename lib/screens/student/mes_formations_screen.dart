import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/student_profile.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../course_screen.dart';
import '../formations_screen.dart';

class MesFormationsScreen extends StatelessWidget {
  const MesFormationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthService>().user?.uid;
    final firestore = context.read<FirestoreService>();

    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Connecte-toi pour voir tes formations.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mes formations')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: firestore.watchEtudiant(uid),
        builder: (context, profilSnap) {
          if (!profilSnap.hasData) return const Center(child: CircularProgressIndicator());
          final student = StudentProfile.fromDoc(profilSnap.data!);
          final aUneFormation = student.formationId != null && student.formationId!.isNotEmpty;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (aUneFormation)
                  Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const Icon(Icons.school, color: LazouColors.primary, size: 32),
                      title: Text(student.formationTitre ?? '', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      subtitle: const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text('Ta formation en cours'),
                      ),
                      trailing: FilledButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CourseScreen(
                              formationId: student.formationId!,
                              formationTitre: student.formationTitre ?? '',
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.menu_book_outlined, size: 18),
                        label: const Text('Cours'),
                      ),
                    ),
                  )
                else
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Tu n\'es pas encore affecté à une formation — ça se fait automatiquement une fois ton inscription validée par l\'administration.',
                        style: TextStyle(color: LazouColors.textSecondary),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FormationsScreen()),
                  ),
                  icon: const Icon(Icons.explore_outlined),
                  label: const Text('Voir tout le catalogue'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
