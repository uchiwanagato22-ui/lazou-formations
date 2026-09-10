import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';
import '../widgets/premium_ui.dart';
import 'student/mes_paiements_screen.dart';
import 'student/mes_resultats_screen.dart';
import 'student/mes_annonces_screen.dart';
import 'student/mes_certificats_screen.dart';
import 'student/mes_cours_screen.dart';
import 'student/mes_formations_screen.dart';
import 'student/mon_planning_screen.dart';
import 'student/mes_presences_screen.dart';

class StudentSpaceScreen extends StatelessWidget {
  const StudentSpaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tuiles = [
      _Tuile(Icons.school_outlined, 'Mes formations', 'Formations suivies', () => const MesFormationsScreen()),
      _Tuile(Icons.folder_open_outlined, 'Mes cours', 'Supports et documents', () => const MesCoursScreen()),
      _Tuile(Icons.calendar_month_outlined, 'Mon planning', 'Cours et horaires', () => const MonPlanningScreen()),
      _Tuile(Icons.fact_check_outlined, 'Mes présences', 'Suivi des séances', () => const MesPresencesScreen()),
      _Tuile(Icons.grade_outlined, 'Mes résultats', 'Notes et progression', () => const MesResultatsScreen()),
      _Tuile(Icons.campaign_outlined, 'Annonces', 'Infos du centre', () => const MesAnnoncesScreen()),
      _Tuile(Icons.workspace_premium_outlined, 'Mes certificats', 'Documents obtenus', () => const MesCertificatsScreen()),
      _Tuile(Icons.payments_outlined, 'Mes paiements', 'Historique et reçus', () => const MesPaiementsScreen()),
    ];

    return Scaffold(
      backgroundColor: LazouColors.background,
      appBar: AppBar(title: const Text('Mon espace')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          const PremiumPageHeader(
            title: 'Mon espace étudiant',
            subtitle: 'Retrouve rapidement tes formations, cours, planning et suivi administratif.',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 18),
          const PremiumSectionHeader(title: 'Mes services', subtitle: 'Tout ton parcours au même endroit', icon: Icons.dashboard_outlined),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: .98),
            itemCount: tuiles.length,
            itemBuilder: (context, i) => FadeSlideIn(index: i, child: tuiles[i]),
          ),
        ],
      ),
    );
  }
}

class _Tuile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Widget Function() builder;
  const _Tuile(this.icon, this.label, this.subtitle, this.builder);

  @override
  Widget build(BuildContext context) => TapScale(
    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => builder())),
    child: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFECEFF3)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .035), blurRadius: 14, offset: const Offset(0, 5))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: LazouColors.primary.withValues(alpha: .08), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: LazouColors.primary, size: 23)),
        const Spacer(),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: LazouColors.textSecondary, fontSize: 11.5), maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 8),
        const Align(alignment: Alignment.bottomRight, child: Icon(Icons.arrow_forward_rounded, size: 17, color: LazouColors.secondary)),
      ]),
    ),
  );
}
