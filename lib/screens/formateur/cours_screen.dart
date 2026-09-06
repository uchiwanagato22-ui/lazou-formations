import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/group_model.dart';
import '../../models/material_model.dart';
import '../../services/auth_service.dart';
import '../../services/cloudinary_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class CoursScreen extends StatefulWidget {
  const CoursScreen({super.key});

  @override
  State<CoursScreen> createState() => _CoursScreenState();
}

class _CoursScreenState extends State<CoursScreen> {
  FormationGroup? _groupe;
  bool _uploadEnCours = false;

  @override
  Widget build(BuildContext context) {
    final service = context.read<FirestoreService>();
    final auth = context.read<AuthService>();
    final uid = auth.user?.uid;
    final role = auth.role?.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Mes cours')),
      floatingActionButton: _groupe == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _uploadEnCours ? null : () => _choisirEtPublier(context, service, _groupe!, auth.user?.email ?? 'Formateur'),
              icon: _uploadEnCours
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.upload_file),
              label: Text(_uploadEnCours ? 'Envoi en cours...' : 'Publier un fichier'),
            ),
      body: uid == null
          ? const Center(child: Text('Session introuvable.'))
          : StreamBuilder<List<FormationGroup>>(
              stream: service.watchGroupes(),
              builder: (context, groupsSnap) {
                if (groupsSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                var groupes = groupsSnap.data ?? [];
                if (role == 'formateur') groupes = groupes.where((g) => g.formateurUid == uid).toList();
                if (groupes.isEmpty) return const Center(child: Text('Aucun groupe disponible.'));
                _groupe ??= groupes.first;
                if (!groupes.any((g) => g.id == _groupe!.id)) _groupe = groupes.first;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: DropdownButtonFormField<FormationGroup>(
                        initialValue: _groupe,
                        decoration: const InputDecoration(labelText: 'Groupe'),
                        items: groupes.map((g) => DropdownMenuItem(value: g, child: Text(g.nom))).toList(),
                        onChanged: (g) => setState(() => _groupe = g),
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<List<Materiau>>(
                        stream: service.watchMateriauxDuGroupe(_groupe!.id),
                        builder: (context, snap) {
                          final materiaux = snap.data ?? [];
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (materiaux.isEmpty) {
                            return const Center(child: Text('Aucun support publié pour ce groupe.'));
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                            itemCount: materiaux.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, i) {
                              final m = materiaux[i];
                              return Card(
                                child: ListTile(
                                  leading: Icon(_iconePour(m.type), color: LazouColors.primary),
                                  title: Text(m.titre, style: const TextStyle(fontWeight: FontWeight.w700)),
                                  subtitle: Text(m.type.label),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline, color: LazouColors.error),
                                    onPressed: () => service.supprimerMateriau(m.id),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  IconData _iconePour(TypeMateriau type) => switch (type) {
        TypeMateriau.pdf => Icons.picture_as_pdf_outlined,
        TypeMateriau.image => Icons.image_outlined,
        TypeMateriau.document => Icons.description_outlined,
        TypeMateriau.autre => Icons.insert_drive_file_outlined,
      };

  Future<void> _choisirEtPublier(BuildContext context, FirestoreService service, FormationGroup groupe, String formateurNom) async {
    final resultat = await FilePicker.platform.pickFiles(withData: true);
    if (resultat == null || resultat.files.isEmpty) return;
    final fichier = resultat.files.first;
    if (fichier.bytes == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible de lire ce fichier.')));
      }
      return;
    }

    setState(() => _uploadEnCours = true);
    try {
      final url = await CloudinaryService.uploaderFichier(fichier.bytes!, fichier.name);
      await service.publierMateriau(Materiau(
        id: '',
        groupeId: groupe.id,
        formationTitre: groupe.formationTitre,
        titre: fichier.name,
        url: url,
        type: TypeMateriauX.depuisExtension(fichier.name),
        publieParNom: formateurNom,
      ));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Support publié ✓')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Échec de l\'envoi : $e')));
      }
    } finally {
      if (mounted) setState(() => _uploadEnCours = false);
    }
  }
}
