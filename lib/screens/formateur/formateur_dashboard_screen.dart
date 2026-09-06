import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/group_model.dart';
import '../admin/attendance_screen.dart';
import 'evaluations_screen.dart';
import 'annonces_screen.dart';
import 'cours_screen.dart';
import '../../theme/app_theme.dart';

class FormateurDashboardScreen extends StatelessWidget {
  const FormateurDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.read<FirestoreService>();
    final uid = context.read<AuthService>().user?.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace formateur'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => context.read<AuthService>().deconnexion())],
      ),
      body: uid == null
          ? const Center(child: Text('Session formateur introuvable.'))
          : StreamBuilder<List<FormationGroup>>(
              stream: service.watchGroupes(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Erreur : ${snapshot.error}'));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final groups = (snapshot.data ?? []).where((g) => g.formateurUid == uid).toList();
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text('Mon activité', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Text('${groups.length} groupe(s) affecté(s)', style: const TextStyle(color: LazouColors.textSecondary)),
                    const SizedBox(height: 18),
                    if (groups.isEmpty)
                      const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('Aucun groupe ne vous est encore affecté par la direction.'))),
                    ...groups.map((g) => _GroupCard(group: g)),
                    const SizedBox(height: 12),
                    _ActionCard(icon: Icons.fact_check_outlined, title: 'Présences', subtitle: 'Choisir un groupe et enregistrer les présences', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AttendanceScreen()))),
                    _ActionCard(icon: Icons.menu_book_outlined, title: 'Mes cours', subtitle: 'Publier des cours et supports pédagogiques', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CoursScreen()))),
                    _ActionCard(icon: Icons.assignment_outlined, title: 'Évaluations & notes', subtitle: 'Créer des évaluations et saisir les notes', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EvaluationsScreen()))),
                    _ActionCard(icon: Icons.campaign_outlined, title: 'Annonces', subtitle: 'Informer les étudiants de mes groupes', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnnoncesScreen()))),
                  ],
                );
              },
            ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final FormationGroup group;
  const _GroupCard({required this.group});
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: CircleAvatar(backgroundColor: LazouColors.primary.withValues(alpha: .12), child: const Icon(Icons.groups_outlined, color: LazouColors.primary)),
          title: Text(group.nom, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text('${group.formationTitre}\n${group.jours} · ${group.horaire}${group.salle.isEmpty ? '' : ' · Salle ${group.salle}'}'),
          isThreeLine: true,
          trailing: const Icon(Icons.chevron_right),
        ),
      );
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  const _ActionCard({required this.icon, required this.title, required this.subtitle, this.onTap});
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: Icon(icon, color: LazouColors.primary),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap ?? () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title sera connecté aux données de classe dans la prochaine étape.'))),
        ),
      );
}
