import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';
import 'student/mes_paiements_screen.dart';
import 'student/mes_resultats_screen.dart';
import 'student/mes_annonces_screen.dart';
import 'student/mes_certificats_screen.dart';
import 'student/mes_cours_screen.dart';
import 'student/mes_formations_screen.dart';
import 'student/mon_planning_screen.dart';
import 'student/mes_presences_screen.dart';

/// Espace étudiant — toutes les tuiles sont branchées sur Firestore,
/// présentées en grille façon dashboard plutôt qu'en simple liste.
class StudentSpaceScreen extends StatelessWidget {
  const StudentSpaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tuiles = [
      _Tuile(Icons.school_outlined, 'Mes formations', () => const MesFormationsScreen()),
      _Tuile(Icons.folder_open_outlined, 'Mes cours', () => const MesCoursScreen()),
      _Tuile(Icons.calendar_today_outlined, 'Mon planning', () => const MonPlanningScreen()),
      _Tuile(Icons.fact_check_outlined, 'Mes présences', () => const MesPresencesScreen()),
      _Tuile(Icons.grade_outlined, 'Mes résultats', () => const MesResultatsScreen()),
      _Tuile(Icons.campaign_outlined, 'Annonces', () => const MesAnnoncesScreen()),
      _Tuile(Icons.workspace_premium_outlined, 'Mes certificats', () => const MesCertificatsScreen()),
      _Tuile(Icons.payments_outlined, 'Mes paiements', () => const MesPaiementsScreen()),
    ];

    return Scaffold(
      backgroundColor: LazouColors.background,
      appBar: AppBar(title: const Text('Mon espace')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.25,
        ),
        itemCount: tuiles.length,
        itemBuilder: (context, i) => tuiles[i],
      ),
    );
  }
}

class _Tuile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget Function() builder;
  const _Tuile(this.icon, this.label, this.builder);

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => builder())),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: LazouColors.primary.withValues(alpha: .08), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: LazouColors.primary, size: 22),
            ),
            const Spacer(),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
