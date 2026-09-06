import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animations.dart';
import 'admin_formations_screen.dart';
import 'admin_inscriptions_screen.dart';
import 'admin_formateurs_screen.dart';
import 'admin_groups_screen.dart';
import 'attendance_screen.dart';
import 'admin_students_screen.dart';
import 'paiements_screen.dart';
import 'admin_certificats_screen.dart';
import 'statistiques_screen.dart';
import '../formateur/annonces_screen.dart';
import '../formateur/evaluations_screen.dart';
import '../formateur/cours_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration Lazou'),
        actions: [
          IconButton(
            tooltip: 'Déconnexion',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthService>().deconnexion(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          const Text('Centre de contrôle', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('Pilote les étudiants, formations et inscriptions depuis un seul endroit.', style: TextStyle(color: LazouColors.textSecondary)),
          const SizedBox(height: 18),
          StreamBuilder<int>(
            stream: firestore.watchNombreEtudiants(),
            builder: (_, s) => _MetricCard(icon: Icons.people_outline, label: 'Étudiants', value: '${s.data ?? 0}', onTap: () => _open(context, const AdminStudentsScreen())),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: StreamBuilder<int>(stream: firestore.watchNombreFormateurs(), builder: (_, s) => _SmallMetric(icon: Icons.badge_outlined, label: 'Formateurs', value: '${s.data ?? 0}'))),
            const SizedBox(width: 10),
            Expanded(child: StreamBuilder<int>(stream: firestore.watchNombreInscriptionsEnAttente(), builder: (_, s) => _SmallMetric(icon: Icons.pending_actions_outlined, label: 'À valider', value: '${s.data ?? 0}'))),
          ]),
          const SizedBox(height: 18),
          const Text('Gestion du centre', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          _AdminCard(icon: Icons.people_outline, label: 'Étudiants', description: 'Dossiers, formations et groupes', builder: () => const AdminStudentsScreen()),
          _AdminCard(icon: Icons.badge_outlined, label: 'Formateurs', description: 'Équipe pédagogique et affectations', builder: () => const AdminFormateursScreen()),
          _AdminCard(icon: Icons.menu_book_outlined, label: 'Formations', description: 'Catalogue, programmes et tarifs', builder: () => const AdminFormationsScreen()),
          _AdminCard(icon: Icons.how_to_reg_outlined, label: 'Inscriptions', description: 'Demandes à valider', builder: () => const AdminInscriptionsScreen()),
          _AdminCard(icon: Icons.event_available_outlined, label: 'Sessions & groupes', description: 'Planning, salles et affectations', builder: () => const AdminGroupsScreen()),
          _AdminCard(icon: Icons.fact_check_outlined, label: 'Présences', description: 'Suivi quotidien des étudiants', builder: () => const AttendanceScreen()),
          _AdminCard(icon: Icons.payments_outlined, label: 'Paiements', description: 'Encaissements et impayés', builder: () => const PaiementsScreen()),
          _AdminCard(icon: Icons.workspace_premium_outlined, label: 'Certificats', description: 'Émission et vérification', builder: () => const AdminCertificatsScreen()),
          _AdminCard(icon: Icons.bar_chart_outlined, label: 'Statistiques', description: 'Activité et performance du centre', builder: () => const StatistiquesScreen()),
          _AdminCard(icon: Icons.assignment_outlined, label: 'Évaluations & notes', description: 'Tous les groupes, tous les formateurs', builder: () => const EvaluationsScreen()),
          _AdminCard(icon: Icons.campaign_outlined, label: 'Annonces', description: 'Publier à n\'importe quel groupe', builder: () => const AnnoncesScreen()),
          _AdminCard(icon: Icons.folder_open_outlined, label: 'Cours & supports', description: 'Publier des fichiers pour tous les groupes', builder: () => const CoursScreen()),
        ],
      ),
    );
  }

  static void _open(BuildContext context, Widget screen) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  const _MetricCard({required this.icon, required this.label, required this.value, required this.onTap});
  @override
  Widget build(BuildContext context) => TapScale(
        onTap: onTap,
        child: Card(
          child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [
            CircleAvatar(radius: 25, backgroundColor: LazouColors.primary.withValues(alpha: .12), child: Icon(icon, color: LazouColors.primary)),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), Text(label, style: const TextStyle(color: LazouColors.textSecondary))]),
            const Spacer(), const Icon(Icons.chevron_right),
          ])),
        ),
      );
}

class _SmallMetric extends StatelessWidget {
  final IconData icon; final String label; final String value;
  const _SmallMetric({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [Icon(icon, color: LazouColors.primary), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), Text(label, style: const TextStyle(fontSize: 12, color: LazouColors.textSecondary))]))])));
}

class _AdminCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Widget Function()? builder;
  const _AdminCard({required this.icon, required this.label, required this.description, this.builder});

  @override
  Widget build(BuildContext context) => TapScale(
        onTap: () {
          if (builder != null) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => builder!()));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label sera branché sur Firebase dans la prochaine étape.')));
          }
        },
        child: Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: LazouColors.primary.withValues(alpha: .10), child: Icon(icon, color: LazouColors.primary)),
            title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(description),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      );
}
