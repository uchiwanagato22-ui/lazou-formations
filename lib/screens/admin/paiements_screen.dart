import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/payment_model.dart';
import '../../models/student_profile.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

/// Écran commun admin/caissier — c'est le rôle qui décide de ce qui est
/// accessible autour (voir CaissierDashboardScreen), pas cet écran lui-même.
class PaiementsScreen extends StatelessWidget {
  const PaiementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Paiements')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => PaiementsScreen.ouvrirFormulaire(context, firestore),
        icon: const Icon(Icons.add),
        label: const Text('Encaisser'),
      ),
      body: Column(
        children: [
          StreamBuilder<double>(
            stream: firestore.watchTotalEncaisse(),
            builder: (context, snapshot) => Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: LazouColors.primary,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      const Icon(Icons.payments, color: Colors.white, size: 28),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${(snapshot.data ?? 0).toStringAsFixed(0)} MRU',
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                          ),
                          const Text('Total encaissé', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Paiement>>(
              stream: firestore.watchTousLesPaiements(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final paiements = snapshot.data ?? [];
                if (paiements.isEmpty) {
                  return const Center(child: Text('Aucun paiement enregistré pour l\'instant.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                  itemCount: paiements.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final p = paiements[i];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: LazouColors.success.withValues(alpha: .12),
                          child: const Icon(Icons.check, color: LazouColors.success),
                        ),
                        title: Text(p.etudiantNom, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text('${p.formationTitre} • ${p.methode.label}${p.note != null && p.note!.isNotEmpty ? ' • ${p.note}' : ''}'),
                        trailing: Text(
                          '${p.montant.toStringAsFixed(0)} MRU',
                          style: const TextStyle(fontWeight: FontWeight.w800, color: LazouColors.primary),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static void ouvrirFormulaire(BuildContext context, FirestoreService firestore, {StudentProfile? etudiantPreselectionne}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _FormulairePaiement(firestore: firestore, etudiantPreselectionne: etudiantPreselectionne),
    );
  }
}

class _FormulairePaiement extends StatefulWidget {
  final FirestoreService firestore;
  final StudentProfile? etudiantPreselectionne;
  const _FormulairePaiement({required this.firestore, this.etudiantPreselectionne});

  @override
  State<_FormulairePaiement> createState() => _FormulairePaiementState();
}

class _FormulairePaiementState extends State<_FormulairePaiement> {
  final _formKey = GlobalKey<FormState>();
  final _montantCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  StudentProfile? _etudiant;
  MethodePaiement _methode = MethodePaiement.especes;
  bool _envoi = false;

  @override
  void initState() {
    super.initState();
    _etudiant = widget.etudiantPreselectionne;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Encaisser un paiement', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
              const SizedBox(height: 16),
              if (widget.etudiantPreselectionne == null)
                FutureBuilder<List<StudentProfile>>(
                  future: widget.firestore.getEtudiantsOnce(),
                  builder: (context, snap) {
                    final etudiants = snap.data ?? [];
                    return DropdownButtonFormField<StudentProfile>(
                      initialValue: _etudiant,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Étudiant'),
                      items: etudiants
                          .map((e) => DropdownMenuItem(value: e, child: Text(e.nomComplet, overflow: TextOverflow.ellipsis)))
                          .toList(),
                      onChanged: (v) => setState(() => _etudiant = v),
                      validator: (v) => v == null ? 'Choisis un étudiant' : null,
                    );
                  },
                )
              else
                Text('Étudiant : ${widget.etudiantPreselectionne!.nomComplet}', style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _montantCtrl,
                decoration: const InputDecoration(labelText: 'Montant (MRU)'),
                keyboardType: TextInputType.number,
                validator: (v) => (double.tryParse(v ?? '') == null) ? 'Montant invalide' : null,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: MethodePaiement.values
                    .map((m) => ChoiceChip(
                          label: Text(m.label),
                          selected: _methode == m,
                          onSelected: (_) => setState(() => _methode = m),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(labelText: 'Note (optionnel)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _envoi ? null : _soumettre,
                child: _envoi
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _soumettre() async {
    if (!_formKey.currentState!.validate() || _etudiant == null) return;
    setState(() => _envoi = true);
    final auth = context.read<AuthService>();
    await widget.firestore.enregistrerPaiement(Paiement(
      id: '',
      etudiantUid: _etudiant!.uid,
      etudiantNom: _etudiant!.nomComplet,
      formationTitre: _etudiant!.formationTitre ?? 'Non affectée',
      montant: double.parse(_montantCtrl.text),
      methode: _methode,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      enregistreParNom: auth.user?.email ?? 'Staff',
    ));
    if (mounted) Navigator.of(context).pop();
  }
}
