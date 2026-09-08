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
import 'impayes_screen.dart';
import 'admin_certificats_screen.dart';
import 'statistiques_screen.dart';
import 'depenses_screen.dart';
import 'prospects_screen.dart';
import '../formateur/annonces_screen.dart';
import '../formateur/evaluations_screen.dart';
import '../formateur/cours_screen.dart';
import '../formateur/ma_classe_screen.dart';
import '../formateur/pointage_matricule_screen.dart';
import '../formateur/suivi_paiements_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    final auth = context.watch<AuthService>();

    return Scaffold(
      backgroundColor: LazouColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 210,
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: _MetricsGrid(firestore: firestore),
            ),
          ),
          SliverToBoxAdapter(
            child: StreamBuilder<int>(
              stream: firestore.watchNombreEtudiantsEnImpayes(),
              builder: (_, s) {
                final n = s.data ?? 0;
                if (n == 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: TapScale(
                    onTap: () => _open(context, const ImpayesScreen()),
                    child: Card(
                      color: LazouColors.warning.withValues(alpha: .10),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: LazouColors.warning.withValues(alpha: .35)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: LazouColors.warning.withValues(alpha: .18), shape: BoxShape.circle),
                              child: const Icon(Icons.warning_amber_rounded, color: LazouColors.warning),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('$n étudiant${n > 1 ? 's' : ''} avec un solde restant',
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                                  const Text('Ouvrir le recouvrement', style: TextStyle(color: LazouColors.textSecondary, fontSize: 12)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: LazouColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _CategorySection(
                  titre: 'Étudiants & pédagogie',
                  icone: Icons.school_outlined,
                  tuiles: [
                    _Tuile(Icons.people_outline, 'Étudiants', () => const AdminStudentsScreen()),
                    _Tuile(Icons.badge_outlined, 'Formateurs', () => const AdminFormateursScreen()),
                    _Tuile(Icons.menu_book_outlined, 'Formations', () => const AdminFormationsScreen()),
                    _Tuile(Icons.event_available_outlined, 'Sessions & groupes', () => const AdminGroupsScreen()),
                    _Tuile(Icons.groups_outlined, 'Classes & matricules', () => const MaClasseScreen()),
                    _Tuile(Icons.fact_check_outlined, 'Présences', () => const AttendanceScreen()),
                    _Tuile(Icons.badge, 'Pointage rapide', () => const PointageMatriculeScreen()),
                    _Tuile(Icons.assignment_outlined, 'Évaluations & notes', () => const EvaluationsScreen()),
                    _Tuile(Icons.folder_open_outlined, 'Cours & supports', () => const CoursScreen()),
                  ],
                ),
                const SizedBox(height: 26),
                _CategorySection(
                  titre: 'Finances',
                  icone: Icons.account_balance_wallet_outlined,
                  tuiles: [
                    _Tuile(Icons.payments_outlined, 'Paiements', () => const PaiementsScreen()),
                    _Tuile(Icons.receipt_long_outlined, 'Suivi paiements', () => const SuiviPaiementsScreen()),
                    _Tuile(Icons.account_balance_wallet_outlined, 'Recouvrement', () => const ImpayesScreen()),
                    _Tuile(Icons.request_quote_outlined, 'Dépenses', () => const DepensesScreen()),
                  ],
                ),
                const SizedBox(height: 26),
                _CategorySection(
                  titre: 'Croissance',
                  icone: Icons.trending_up,
                  tuiles: [
                    _Tuile(Icons.how_to_reg_outlined, 'Inscriptions', () => const AdminInscriptionsScreen()),
                    _Tuile(Icons.person_search_outlined, 'Prospects', () => const ProspectsScreen()),
                  ],
                ),
                const SizedBox(height: 26),
                _CategorySection(
                  titre: 'Communication & bilan',
                  icone: Icons.insights_outlined,
                  tuiles: [
                    _Tuile(Icons.campaign_outlined, 'Annonces', () => const AnnoncesScreen()),
                    _Tuile(Icons.workspace_premium_outlined, 'Certificats', () => const AdminCertificatsScreen()),
                    _Tuile(Icons.bar_chart_outlined, 'Statistiques', () => const StatistiquesScreen()),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  static void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

/// Bannière de tête façon "vrai dashboard" — dégradé + salutation, au lieu
/// d'un simple titre noir sur fond blanc.
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
              width: 160,
              height: 160,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: .06)),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -30,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(shape: BoxShape.circle, color: LazouColors.secondary.withValues(alpha: .16)),
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
                const Text('Centre de contrôle',
                    style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                const Text('Étudiants, finances et pédagogie, en un seul endroit.',
                    style: TextStyle(color: Colors.white70, fontSize: 12.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Les métriques clés en un bloc de cartes glassy sur fond blanc — plus
/// scannable qu'une pile de lignes.
class _MetricsGrid extends StatelessWidget {
  final FirestoreService firestore;
  const _MetricsGrid({required this.firestore});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.55,
      children: [
        StreamBuilder<int>(
          stream: firestore.watchNombreEtudiants(),
          builder: (_, s) => _MiniStat(icon: Icons.people_outline, label: 'Étudiants', value: '${s.data ?? 0}', couleur: LazouColors.primary),
        ),
        StreamBuilder<int>(
          stream: firestore.watchNombreFormateurs(),
          builder: (_, s) => _MiniStat(icon: Icons.badge_outlined, label: 'Formateurs', value: '${s.data ?? 0}', couleur: LazouColors.primary),
        ),
        StreamBuilder<int>(
          stream: firestore.watchNombreInscriptionsEnAttente(),
          builder: (_, s) => _MiniStat(icon: Icons.pending_actions_outlined, label: 'À valider', value: '${s.data ?? 0}', couleur: LazouColors.secondary),
        ),
        StreamBuilder<double>(
          stream: firestore.watchEncaisseMoisCourant(),
          builder: (_, s) => _MiniStat(
            icon: Icons.calendar_month_outlined,
            label: 'Encaissé ce mois',
            value: '${(s.data ?? 0).toStringAsFixed(0)} MRU',
            couleur: LazouColors.success,
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color couleur;
  const _MiniStat({required this.icon, required this.label, required this.value, required this.couleur});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: couleur.withValues(alpha: .12), borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, color: couleur, size: 18),
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(label, style: const TextStyle(fontSize: 11, color: LazouColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

/// Une section = un titre + une grille 2 colonnes de tuiles compactes.
/// Remplace la liste plate de 17 lignes identiques par un vrai classement.
class _CategorySection extends StatelessWidget {
  final String titre;
  final IconData icone;
  final List<_Tuile> tuiles;
  const _CategorySection({required this.titre, required this.icone, required this.tuiles});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icone, size: 17, color: LazouColors.secondary),
            const SizedBox(width: 6),
            Text(titre, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, letterSpacing: .2)),
          ],
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.5,
          children: tuiles,
        ),
      ],
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEF0F3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: LazouColors.primary.withValues(alpha: .08), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: LazouColors.primary, size: 19),
            ),
            const Spacer(),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
