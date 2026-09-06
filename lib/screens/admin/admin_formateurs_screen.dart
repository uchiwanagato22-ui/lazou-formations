import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class AdminFormateursScreen extends StatelessWidget {
  const AdminFormateursScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Formateurs')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreate(context, firestore),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Ajouter'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestore.watchFormateurs(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Erreur : ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data ?? [];
          if (items.isEmpty) return const Center(child: Text('Aucun formateur pour le moment.'));
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final f = items[i];
              final name = (f['nomComplet'] ?? 'Formateur').toString();
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: LazouColors.primary.withValues(alpha: .12),
                    child: Text(_initials(name), style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text((f['email'] ?? f['telephone'] ?? 'Compte formateur').toString()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showEdit(context, firestore, f),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static String _initials(String value) {
    final p = value.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (p.isEmpty) return '?';
    return p.length == 1 ? p.first[0].toUpperCase() : '${p.first[0]}${p.last[0]}'.toUpperCase();
  }

  void _showCreate(BuildContext context, FirestoreService service) {
    final uid = TextEditingController();
    final name = TextEditingController();
    final email = TextEditingController();
    final phone = TextEditingController();
    _form(context, 'Nouveau formateur', uid, name, email, phone, () async {
      if (uid.text.trim().isEmpty || name.text.trim().isEmpty) return;
      await service.creerProfilFormateur(
        uid: uid.text.trim(),
        nomComplet: name.text.trim(),
        email: email.text.trim(),
        telephone: phone.text.trim(),
      );
      if (context.mounted) Navigator.pop(context);
    });
  }

  void _showEdit(BuildContext context, FirestoreService service, Map<String, dynamic> data) {
    final name = TextEditingController(text: (data['nomComplet'] ?? '').toString());
    final email = TextEditingController(text: (data['email'] ?? '').toString());
    final phone = TextEditingController(text: (data['telephone'] ?? '').toString());
    _form(context, 'Modifier le formateur', TextEditingController(text: data['uid'].toString()), name, email, phone, () async {
      await service.mettreAJourFormateur(data['uid'].toString(), {
        'nomComplet': name.text.trim(),
        'email': email.text.trim(),
        'telephone': phone.text.trim(),
      });
      if (context.mounted) Navigator.pop(context);
    });
  }

  void _form(BuildContext context, String title, TextEditingController uid, TextEditingController name, TextEditingController email,
      TextEditingController phone, Future<void> Function() save) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          if (uid.text.isEmpty) ...[TextField(controller: uid, decoration: const InputDecoration(labelText: 'UID Firebase du formateur')) , const SizedBox(height: 10)],
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Nom complet')),
          const SizedBox(height: 10),
          TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 10),
          TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Téléphone')),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: save, child: const Text('Enregistrer')),
        ]),
      ),
    );
  }
}
