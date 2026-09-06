import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course_content.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/diagrams/cycle_comptable_diagram.dart';
import '../widgets/diagrams/plan_comptable_diagram.dart';

class LessonScreen extends StatelessWidget {
  final Lesson lesson;
  final String formationId;
  const LessonScreen({super.key, required this.lesson, required this.formationId});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService?>();
    final firestore = context.read<FirestoreService?>();
    final peutSuivreProgression = auth?.user != null && firestore != null;

    return Scaffold(
      appBar: AppBar(title: Text(lesson.titre)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: lesson.sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 18),
        itemBuilder: (context, i) => _SectionView(section: lesson.sections[i]),
      ),
      bottomNavigationBar: peutSuivreProgression
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: StreamBuilder<Set<String>>(
                  stream: firestore.watchLeconsTerminees(auth!.user!.uid, formationId),
                  builder: (context, snapshot) {
                    final termine = snapshot.data?.contains(lesson.id) ?? false;
                    return ElevatedButton.icon(
                      onPressed: termine
                          ? null
                          : () => firestore.marquerLeconTerminee(auth.user!.uid, formationId, lesson.id),
                      icon: Icon(termine ? Icons.check_circle : Icons.check_circle_outline),
                      label: Text(termine ? 'Leçon terminée' : 'Marquer comme terminé'),
                    );
                  },
                ),
              ),
            )
          : null,
    );
  }
}

class _SectionView extends StatelessWidget {
  final ContentSection section;
  const _SectionView({required this.section});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section.titre != null) ...[
          Text(
            section.titre!,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5, color: LazouColors.primary),
          ),
          const SizedBox(height: 8),
        ],
        if (section.texte != null)
          Text(section.texte!, style: const TextStyle(fontSize: 14.5, height: 1.55)),
        if (section.puces != null)
          ...section.puces!.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6, right: 8),
                    child: Icon(Icons.circle, size: 6, color: LazouColors.secondary),
                  ),
                  Expanded(child: Text(p, style: const TextStyle(fontSize: 14.5, height: 1.4))),
                ],
              ),
            ),
          ),
        if (section.diagramme == DiagramType.planComptable) ...[
          const SizedBox(height: 4),
          const PlanComptableDiagram(),
        ],
        if (section.diagramme == DiagramType.cycleComptable) ...[
          const SizedBox(height: 4),
          const CycleComptableDiagram(),
        ],
      ],
    );
  }
}
