import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mock_courses.dart';
import '../models/course_content.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import 'lesson_screen.dart';

/// Le cours complet d'une formation, consultable directement dans l'app —
/// c'est ce qui remplace le livre papier pour l'étudiant. Si l'étudiant est
/// connecté, la progression (leçons terminées) s'affiche en direct.
class CourseScreen extends StatelessWidget {
  final String formationId;
  final String formationTitre;

  const CourseScreen({super.key, required this.formationId, required this.formationTitre});

  @override
  Widget build(BuildContext context) {
    final course = mockCourses[formationId];
    final auth = context.watch<AuthService?>();
    final firestore = context.read<FirestoreService?>();
    final peutSuivreProgression = auth?.user != null && firestore != null;

    return Scaffold(
      appBar: AppBar(title: Text('Cours — $formationTitre')),
      body: course == null
          ? const _CoursePasEncorePret()
          : peutSuivreProgression
              ? StreamBuilder<Set<String>>(
                  stream: firestore.watchLeconsTerminees(auth!.user!.uid, formationId),
                  builder: (context, snapshot) => _ListeLecons(
                    course: course,
                    formationId: formationId,
                    terminees: snapshot.data ?? {},
                  ),
                )
              : _ListeLecons(course: course, formationId: formationId, terminees: const {}),
    );
  }
}

class _ListeLecons extends StatelessWidget {
  final Course course;
  final String formationId;
  final Set<String> terminees;

  const _ListeLecons({required this.course, required this.formationId, required this.terminees});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (terminees.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: LinearProgressIndicator(
              value: terminees.length / course.lessons.length,
              backgroundColor: LazouColors.primary.withValues(alpha: 0.1),
              color: LazouColors.secondary,
              minHeight: 6,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: course.lessons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final lesson = course.lessons[i];
              final estTerminee = terminees.contains(lesson.id);
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: estTerminee
                        ? LazouColors.success.withValues(alpha: 0.12)
                        : LazouColors.primary.withValues(alpha: 0.1),
                    foregroundColor: estTerminee ? LazouColors.success : LazouColors.primary,
                    child: estTerminee
                        ? const Icon(Icons.check, size: 18)
                        : Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  title: Text(lesson.titre, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(lesson.resume),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LessonScreen(lesson: lesson, formationId: formationId),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CoursePasEncorePret extends StatelessWidget {
  const _CoursePasEncorePret();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_outlined, size: 48, color: LazouColors.textSecondary),
            SizedBox(height: 12),
            Text(
              'Le contenu de ce cours est en cours de préparation.',
              textAlign: TextAlign.center,
              style: TextStyle(color: LazouColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
