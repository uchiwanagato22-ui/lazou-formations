import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/group_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animations.dart';
import '../../widgets/premium_ui.dart';
import '../admin/attendance_screen.dart';
import 'evaluations_screen.dart';
import 'annonces_screen.dart';
import 'cours_screen.dart';
import 'ma_classe_screen.dart';
import 'pointage_matricule_screen.dart';
import 'historique_presence_screen.dart';
import 'suivi_paiements_screen.dart';

class FormateurDashboardScreen extends StatelessWidget {
  const FormateurDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.read<FirestoreService>();
    final auth = context.watch<AuthService>();
    final uid = auth.user?.uid;

    return Scaffold(
      backgroundColor: LazouColors.background,
      body: uid == null
          ? const Center(child: Text('Session formateur introuvable.'))
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 190,
                  backgroundColor: LazouColors.primary,
                  foregroundColor: Colors.white,
                  actions: [
                    IconButton(
                      tooltip: 'Déconnexion',
                      icon: const Icon(Icons.logout),
                      onPressed: () => auth.deconnexion(),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: _HeroHeader(nom: auth.user?.email?.split('@').first),
                  ),
                ),
                SliverToBoxAdapter(
                  child: StreamBuilder<List<FormationGroup>>(
                    stream: service.watchGroupes(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Padding(padding: const EdgeInsets.all(16), child: Text('Erreur : ${snapshot.error}'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()));
                      }
                      final groupes = (snapshot.data ?? []).where((g) => g.formateurUid == uid).toList();

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.groups_outlined, size: 17, color: LazouColors.secondary),
                                const SizedBox(width: 6),
                                Text('Mes groupes (${groupes.length})',
                                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (groupes.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                                child: const Text(
                                  'Aucun groupe ne vous est encore affecté par la direction.',
                                  style: TextStyle(color: LazouColors.textSecondary),
                                ),
                              )
                            else
                              ...groupes.map((g) => _GroupCard(group: g)),
                            const SizedBox(height: 26),
                            Row(
                              children: const [
                                Icon(Icons.dashboard_outlined, size: 17, color: LazouColors.secondary),
                                SizedBox(width: 6),
                                Text('Mes outils', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 420,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.05,
                    ),
                    delegate: SliverChildListDelegate([
                      _Tuile(Icons.badge, 'Pointage rapide', () => const PointageMatriculeScreen()),
                      _Tuile(Icons.history_edu_outlined, 'Historique présences', () => const HistoriquePresenceScreen()),
                      _Tuile(Icons.fact_check_outlined, 'Présences', () => const AttendanceScreen()),
                      _Tuile(Icons.groups_outlined, 'Ma classe', () => const MaClasseScreen()),
                      _Tuile(Icons.payments_outlined, 'Suivi paiements', () => const SuiviPaiementsScreen()),
                      _Tuile(Icons.assignment_outlined, 'Évaluations & notes', () => const EvaluationsScreen()),
                      _Tuile(Icons.folder_open_outlined, 'Mes cours', () => const CoursScreen()),
                      _Tuile(Icons.campaign_outlined, 'Annonces', () => const AnnoncesScreen()),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final String? nom;
  const _HeroHeader({this.nom});

  @override
  Widget build(BuildContext context) {
    final heure = DateTime.now().hour;
    final salutation = heure < 12 ? 'Bonjour' : (heure < 18 ? 'Bon après-midi' : 'Bonsoir');
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [LazouColors.primary, Color(0xFF14538F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: .06)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('$salutation ${nom != null && nom!.isNotEmpty ? nom : ''} 👋',
                    style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                const Text('Espace formateur', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                const Text('Tes classes, présences et notes du jour.', style: TextStyle(color: Colors.white70, fontSize: 12.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final FormationGroup group;
  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: LazouColors.primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.groups_outlined, color: LazouColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(group.nom, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
                const SizedBox(height: 2),
                Text(group.formationTitre, style: const TextStyle(color: LazouColors.textSecondary, fontSize: 12.5)),
                const SizedBox(height: 2),
                Text(
                  '${group.jours}${group.jours.isNotEmpty && group.horaire.isNotEmpty ? ' · ' : ''}${group.horaire}${group.salle.isEmpty ? '' : ' · Salle ${group.salle}'}',
                  style: const TextStyle(color: LazouColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
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
    return PremiumActionTile(
      icon: icon,
      title: label,
      subtitle: 'Accéder à cet espace',
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => builder()),
      ),
    );
  }
}
