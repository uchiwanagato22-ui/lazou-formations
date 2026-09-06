import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/formation.dart';
import '../../models/group_model.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class AdminGroupsScreen extends StatelessWidget {
  const AdminGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.read<FirestoreService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Sessions & groupes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context, service),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau groupe'),
      ),
      body: StreamBuilder<List<FormationGroup>>(
        stream: service.watchGroupes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Erreur : ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final groups = snapshot.data ?? [];
          if (groups.isEmpty) return const Center(child: Text('Aucun groupe créé.'));
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: groups.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final g = groups[i];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: LazouColors.primary.withValues(alpha: .12), child: const Icon(Icons.groups_outlined, color: LazouColors.primary)),
                  title: Text(g.nom, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('${g.formationTitre}\n${g.jours.isEmpty ? 'Jours non définis' : g.jours} · ${g.horaire.isEmpty ? 'Horaire non défini' : g.horaire}\n${g.formateurNom ?? 'Formateur non affecté'}${g.salle.isEmpty ? '' : ' · Salle ${g.salle}'}'),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'assign') await _assignStudent(context, service, g);
                      if (value == 'delete') await service.supprimerGroupe(g.id);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'assign', child: Text('Affecter un étudiant')),
                      PopupMenuItem(value: 'delete', child: Text('Supprimer')),
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

  Future<void> _create(BuildContext context, FirestoreService service) async {
    final formations = await service.getFormationsOnce();
    final formateurs = await service.getFormateursOnce();
    if (!context.mounted) return;
    final nom = TextEditingController();
    final salle = TextEditingController();
    final jours = TextEditingController(text: 'Lundi - Mercredi - Vendredi');
    final horaire = TextEditingController(text: '14:00 - 16:00');
    Formation? formation = formations.isEmpty ? null : formations.first;
    Map<String, dynamic>? formateur = formateurs.isEmpty ? null : formateurs.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setState) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Créer un groupe', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          TextField(controller: nom, decoration: const InputDecoration(labelText: 'Nom du groupe', hintText: 'Bureautique A')),
          const SizedBox(height: 10),
          DropdownButtonFormField<Formation>(
            initialValue: formation,
            decoration: const InputDecoration(labelText: 'Formation'),
            items: formations.map((f) => DropdownMenuItem(value: f, child: Text(f.titre))).toList(),
            onChanged: (v) => setState(() => formation = v),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<Map<String, dynamic>>(
            initialValue: formateur,
            decoration: const InputDecoration(labelText: 'Formateur'),
            items: formateurs.map((f) => DropdownMenuItem(value: f, child: Text((f['nomComplet'] ?? 'Formateur').toString()))).toList(),
            onChanged: (v) => setState(() => formateur = v),
          ),
          const SizedBox(height: 10),
          TextField(controller: jours, decoration: const InputDecoration(labelText: 'Jours')),
          const SizedBox(height: 10),
          TextField(controller: horaire, decoration: const InputDecoration(labelText: 'Horaire')),
          const SizedBox(height: 10),
          TextField(controller: salle, decoration: const InputDecoration(labelText: 'Salle')),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: formation == null || nom.text.trim().isEmpty ? null : () async {
              final id = '${formation!.id}-${DateTime.now().millisecondsSinceEpoch}';
              await service.creerGroupe(FormationGroup(
                id: id,
                nom: nom.text.trim(),
                formationId: formation!.id,
                formationTitre: formation!.titre,
                formateurUid: formateur?['uid']?.toString(),
                formateurNom: formateur?['nomComplet']?.toString(),
                jours: jours.text.trim(),
                horaire: horaire.text.trim(),
                salle: salle.text.trim(),
              ));
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Créer le groupe'),
          ),
        ])),
      )),
    );
  }

  Future<void> _assignStudent(BuildContext context, FirestoreService service, FormationGroup group) async {
    final students = await service.getEtudiantsOnce();
    if (!context.mounted) return;
    StudentChoice? selected = students.isEmpty ? null : StudentChoice.from(students.first);
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setState) => AlertDialog(
        title: Text('Affecter à ${group.nom}'),
        content: DropdownButtonFormField<StudentChoice>(
          initialValue: selected,
          items: students.map((s) => DropdownMenuItem(value: StudentChoice.from(s), child: Text(s.nomComplet))).toList(),
          onChanged: (v) => setState(() => selected = v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(onPressed: selected == null ? null : () async {
            await service.affecterEtudiantAuGroupe(selected!.uid, group);
            if (ctx.mounted) Navigator.pop(ctx);
          }, child: const Text('Affecter')),
        ],
      )),
    );
  }
}

class StudentChoice {
  final String uid;
  final String nomComplet;
  const StudentChoice({required this.uid, required this.nomComplet});
  factory StudentChoice.from(dynamic s) => StudentChoice(uid: s.uid.toString(), nomComplet: s.nomComplet.toString());
  @override bool operator ==(Object other) => other is StudentChoice && other.uid == uid;
  @override int get hashCode => uid.hashCode;
}
