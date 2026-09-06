import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/formation.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class AdminFormationsScreen extends StatelessWidget {
  const AdminFormationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Formations')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _ouvrirFormulaireAjout(context, firestore),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
      body: StreamBuilder<List<Formation>>(
        stream: firestore.watchFormations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final formations = snapshot.data ?? [];
          if (formations.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aucune formation ajoutée pour l\'instant.\nAppuie sur "Ajouter" pour créer la première.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            itemCount: formations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final f = formations[i];
              return Card(
                child: ListTile(
                  title: Text(f.titre, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${f.domaine.label} · ${f.duree}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'modifier') {
                        _ouvrirFormulaireAjout(context, firestore, formation: f);
                      } else if (value == 'supprimer') {
                        firestore.supprimerFormation(f.id);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'modifier', child: Text('Modifier')),
                      PopupMenuItem(value: 'supprimer', child: Text('Supprimer')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _ouvrirFormulaireAjout(BuildContext context, FirestoreService firestore, {Formation? formation}) {
    final titreCtrl = TextEditingController(text: formation?.titre ?? '');
    final descCtrl = TextEditingController(text: formation?.description ?? '');
    final dureeCtrl = TextEditingController(text: formation?.duree ?? '');
    final niveauCtrl = TextEditingController(text: formation?.niveau ?? '');
    final prixCtrl = TextEditingController(text: formation?.prix?.toString() ?? '');
    final sessionCtrl = TextEditingController(text: formation?.prochaineSession ?? '');
    final modulesCtrl = TextEditingController(text: formation?.modules.join(', ') ?? '');
    FormationDomaine domaine = formation?.domaine ?? FormationDomaine.informatique;
    bool certifiante = formation?.certifiante ?? true;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (ctx, setState) => Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(formation == null ? 'Nouvelle formation' : 'Modifier la formation', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: titreCtrl,
                    decoration: const InputDecoration(labelText: 'Titre'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<FormationDomaine>(
                    initialValue: domaine,
                    decoration: const InputDecoration(labelText: 'Domaine'),
                    items: FormationDomaine.values
                        .map((d) => DropdownMenuItem(value: d, child: Text(d.label)))
                        .toList(),
                    onChanged: (v) => setState(() => domaine = v ?? domaine),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: dureeCtrl,
                    decoration: const InputDecoration(labelText: 'Durée (ex: 2 mois)'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(controller: niveauCtrl, decoration: const InputDecoration(labelText: 'Niveau (optionnel)')),
                  const SizedBox(height: 12),
                  TextFormField(controller: prixCtrl, decoration: const InputDecoration(labelText: 'Prix en MRU (optionnel)'), keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  TextFormField(controller: sessionCtrl, decoration: const InputDecoration(labelText: 'Prochaine session (optionnel)')),
                  const SizedBox(height: 12),
                  TextFormField(controller: modulesCtrl, decoration: const InputDecoration(labelText: 'Modules (séparés par des virgules)'), maxLines: 2),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile.adaptive(contentPadding: EdgeInsets.zero, title: const Text('Formation certifiante'), value: certifiante, onChanged: (v) => setState(() => certifiante = v)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      final id = formation?.id ?? '${titreCtrl.text.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')}-${DateTime.now().millisecondsSinceEpoch}';
                      final prix = double.tryParse(prixCtrl.text.trim().replaceAll(',', '.'));
                      final modules = modulesCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                      firestore.ajouterFormation(
                        Formation(
                          id: id,
                          titre: titreCtrl.text.trim(),
                          domaine: domaine,
                          description: descCtrl.text.trim(),
                          duree: dureeCtrl.text.trim(),
                          modules: modules,
                          niveau: niveauCtrl.text.trim().isEmpty ? null : niveauCtrl.text.trim(),
                          prix: prix,
                          certifiante: certifiante,
                          prochaineSession: sessionCtrl.text.trim().isEmpty ? null : sessionCtrl.text.trim(),
                        ),
                      );
                      Navigator.of(ctx).pop();
                    },
                    child: Text(formation == null ? 'Créer la formation' : 'Enregistrer les modifications'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
