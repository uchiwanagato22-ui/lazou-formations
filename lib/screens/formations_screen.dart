import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/formation.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';
import '../widgets/formation_card.dart';
import 'formation_detail_screen.dart';

class FormationsScreen extends StatelessWidget {
  const FormationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();

    return StreamBuilder<List<Formation>>(
      stream: firestore.watchFormations(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Formations')),
            body: _CatalogueState(
              icon: Icons.cloud_off_outlined,
              title: 'Catalogue indisponible',
              message: 'Impossible de charger les formations. Vérifie la connexion puis réessaie.',
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return _FormationsListe(formations: snapshot.data ?? const []);
      },
    );
  }
}

class _CatalogueState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const _CatalogueState({required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 52, color: LazouColors.textSecondary),
        const SizedBox(height: 14),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center, style: const TextStyle(color: LazouColors.textSecondary, height: 1.45)),
      ]),
    ),
  );

}

class _FormationsListe extends StatefulWidget {
  final List<Formation> formations;
  const _FormationsListe({required this.formations});

  @override
  State<_FormationsListe> createState() => _FormationsListeState();
}

class _FormationsListeState extends State<_FormationsListe> {
  FormationDomaine? _filtre;

  @override
  Widget build(BuildContext context) {
    final liste = widget.formations
        .where((f) => _filtre == null || f.domaine == _filtre)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Formations')),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: [
                _FilterChip(label: 'Tout', selected: _filtre == null, onTap: () => setState(() => _filtre = null)),
                ...FormationDomaine.values.map(
                  (d) => _FilterChip(
                    label: d.label,
                    selected: _filtre == d,
                    onTap: () => setState(() => _filtre = d),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: liste.isEmpty
                ? _CatalogueState(
                    icon: Icons.menu_book_outlined,
                    title: 'Aucune formation',
                    message: _filtre == null
                        ? 'Aucune formation n’est encore publiée dans le catalogue.'
                        : 'Aucune formation publiée dans cette catégorie.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: liste.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => FadeSlideIn(
                      index: i,
                      child: FormationCard(
                        formation: liste[i],
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => FormationDetailScreen(formation: liste[i])),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
