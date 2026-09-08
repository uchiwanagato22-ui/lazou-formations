import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/expense_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/empty_state.dart';

class DepensesScreen extends StatelessWidget {
  const DepensesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final fs = context.read<FirestoreService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Dépenses du centre')),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _ajouter(context), icon: const Icon(Icons.add), label: const Text('Dépense')),
      body: StreamBuilder<List<Depense>>(
        stream: fs.watchDepenses(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final items = snap.data ?? [];
          final total = items.fold<double>(0, (s, e) => s + e.montant);
          return ListView(padding: const EdgeInsets.all(16), children: [
            Card(child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [const Icon(Icons.account_balance_wallet_outlined), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Total enregistré'), Text('${total.toStringAsFixed(0)} MRU', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900))])]))),
            const SizedBox(height: 12),
            if (items.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(24), child: EmptyState(icon: Icons.request_quote_outlined, message: 'Aucune dépense enregistrée.'))),
            ...items.map((e) => Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.receipt_long_outlined)), title: Text(e.libelle, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text('${e.categorie.label}${e.note?.isNotEmpty == true ? ' · ${e.note}' : ''}'), trailing: Text('${e.montant.toStringAsFixed(0)} MRU', style: const TextStyle(fontWeight: FontWeight.w800))))),
          ]);
        },
      ),
    );
  }

  static Future<void> _ajouter(BuildContext context) async {
    final libelle = TextEditingController();
    final montant = TextEditingController();
    final note = TextEditingController();
    var categorie = CategorieDepense.autre;
    await showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, set) => AlertDialog(
      title: const Text('Nouvelle dépense'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: libelle, decoration: const InputDecoration(labelText: 'Libellé')),
        TextField(controller: montant, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Montant (MRU)')),
        DropdownButtonFormField<CategorieDepense>(value: categorie, items: CategorieDepense.values.map((c) => DropdownMenuItem(value: c, child: Text(c.label))).toList(), onChanged: (v) => set(() => categorie = v ?? categorie), decoration: const InputDecoration(labelText: 'Catégorie')),
        TextField(controller: note, decoration: const InputDecoration(labelText: 'Note (facultatif)')),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')), ElevatedButton(onPressed: () async { final m = double.tryParse(montant.text.replaceAll(',', '.')); if (libelle.text.trim().isEmpty || m == null || m <= 0) return; await context.read<FirestoreService>().ajouterDepense(Depense(id: '', libelle: libelle.text.trim(), montant: m, categorie: categorie, enregistrePar: 'Administration', note: note.text.trim().isEmpty ? null : note.text.trim())); if (ctx.mounted) Navigator.pop(ctx); }, child: const Text('Enregistrer'))],
    )));
  }
}
