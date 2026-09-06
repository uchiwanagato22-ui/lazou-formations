import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'student/mes_paiements_screen.dart';
import 'student/mes_resultats_screen.dart';
import 'student/mes_annonces_screen.dart';
import 'student/mes_certificats_screen.dart';
import 'student/mes_cours_screen.dart';
import 'student/mes_formations_screen.dart';
import 'student/mon_planning_screen.dart';
import 'student/mes_presences_screen.dart';

/// Espace étudiant — toutes les tuiles sont branchées sur Firestore.
class StudentSpaceScreen extends StatelessWidget {
  const StudentSpaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon espace')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTile(
            icon: Icons.school_outlined,
            title: 'Mes formations',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MesFormationsScreen()),
            ),
          ),
          _SectionTile(
            icon: Icons.folder_open_outlined,
            title: 'Mes cours (supports)',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MesCoursScreen()),
            ),
          ),
          _SectionTile(
            icon: Icons.calendar_today_outlined,
            title: 'Mon planning',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MonPlanningScreen()),
            ),
          ),
          _SectionTile(
            icon: Icons.fact_check_outlined,
            title: 'Mes présences',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MesPresencesScreen()),
            ),
          ),
          _SectionTile(
            icon: Icons.grade_outlined,
            title: 'Mes résultats',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MesResultatsScreen()),
            ),
          ),
          _SectionTile(
            icon: Icons.campaign_outlined,
            title: 'Annonces',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MesAnnoncesScreen()),
            ),
          ),
          _SectionTile(
            icon: Icons.workspace_premium_outlined,
            title: 'Mes certificats',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MesCertificatsScreen()),
            ),
          ),
          _SectionTile(
            icon: Icons.payments_outlined,
            title: 'Mes paiements',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MesPaiementsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  const _SectionTile({required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: LazouColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bientôt disponible — en attente des données Lazou')),
              );
            },
      ),
    );
  }
}
