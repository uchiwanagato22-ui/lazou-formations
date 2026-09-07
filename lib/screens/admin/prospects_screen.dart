import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/prospect_model.dart';
import '../../services/firestore_service.dart';

class ProspectsScreen extends StatelessWidget {
  const ProspectsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final fs = context.read<FirestoreService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Prospects & admissions')),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _ajouter(context), icon: const Icon(Icons.person_add_alt_1), label: const Text('Prospect')),
      body: StreamBuilder<List<Prospect>>(
        stream: fs.watchProspects(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final items = snap.data ?? [];
          final actifs = items.where((p) => p.statut != StatutProspect.perdu && p.statut != StatutProspect.inscrit).length;
          return ListView(padding: const EdgeInsets.all(16), children: [
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [const Icon(Icons.filter_alt_outlined), const SizedBox(width: 10), Text('$actifs prospects à suivre', style: const TextStyle(fontWeight: FontWeight.w800))]))),
            const SizedBox(height: 12),
            ...items.map((p) => Card(child: ListTile(
              leading: CircleAvatar(child: Text(p.nom.isEmpty ? '?' : p.nom.substring(0, 1).toUpperCase())),
              title: Text(p.nom, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${p.telephone} · ${p.formationInteressee ?? 'Formation non précisée'}\n${p.statut.label}${p.prochainContact != null ? ' · rappel ${p.prochainContact!.day}/${p.prochainContact!.month}' : ''}'),
              isThreeLine: true,
              trailing: PopupMenuButton<StatutProspect>(onSelected: (s) => fs.mettreAJourStatutProspect(p.id, s), itemBuilder: (_) => StatutProspect.values.map((s) => PopupMenuItem(value: s, child: Text(s.label))).toList()),
              onTap: () => launchUrl(Uri.parse('https://wa.me/${p.telephone.replaceAll(RegExp(r'[^0-9]'), '')}')),
            )))
          ]);
        },
      ),
    );
  }

  static Future<void> _ajouter(BuildContext context) async {
    final nom = TextEditingController(), tel = TextEditingController(), formation = TextEditingController(), note = TextEditingController();
    await showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Nouveau prospect'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: nom, decoration: const InputDecoration(labelText: 'Nom complet')), TextField(controller: tel, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Téléphone')), TextField(controller: formation, decoration: const InputDecoration(labelText: 'Formation souhaitée')), TextField(controller: note, decoration: const InputDecoration(labelText: 'Note'))])), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')), ElevatedButton(onPressed: () async { if (nom.text.trim().isEmpty || tel.text.trim().isEmpty) return; await context.read<FirestoreService>().ajouterProspect(Prospect(id: '', nom: nom.text.trim(), telephone: tel.text.trim(), formationInteressee: formation.text.trim().isEmpty ? null : formation.text.trim(), note: note.text.trim().isEmpty ? null : note.text.trim())); if (ctx.mounted) Navigator.pop(ctx); }, child: const Text('Ajouter'))]));
  }
}
