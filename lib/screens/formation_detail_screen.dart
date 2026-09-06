import 'package:flutter/material.dart';
import '../models/formation.dart';
import '../theme/app_theme.dart';
import 'course_screen.dart';
import 'inscription_screen.dart';

class FormationDetailScreen extends StatelessWidget {
  final Formation formation;
  const FormationDetailScreen({super.key, required this.formation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(formation.titre)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Hero(
            tag: 'formation_icon_${formation.id}',
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: LazouColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(formation.domaine.icone, color: LazouColors.primary, size: 30),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: LazouColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              formation.domaine.label,
              style: const TextStyle(
                color: LazouColors.secondary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(formation.description, style: const TextStyle(fontSize: 15, height: 1.5)),
          const SizedBox(height: 20),
          _InfoRow(icon: Icons.schedule, label: 'Durée', value: formation.duree),
          if (formation.niveau != null)
            _InfoRow(icon: Icons.bar_chart, label: 'Niveau', value: formation.niveau!),
          _InfoRow(
            icon: Icons.workspace_premium_outlined,
            label: 'Certificat',
            value: formation.certifiante ? 'Oui, délivré par Lazou' : 'Non',
          ),
          if (formation.prix != null)
            _InfoRow(icon: Icons.payments_outlined, label: 'Tarif', value: '${formation.prix} MRU')
          else if (formation.formulesTarifaires == null)
            const _InfoRow(icon: Icons.payments_outlined, label: 'Tarif', value: 'Sur demande'),
          if (formation.formulesTarifaires != null) ...[
            const SizedBox(height: 16),
            const Text('Formules tarifaires', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...formation.formulesTarifaires!.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6, right: 8),
                      child: Icon(Icons.circle, size: 6, color: LazouColors.secondary),
                    ),
                    Expanded(child: Text(f, style: const TextStyle(fontSize: 14, height: 1.4))),
                  ],
                ),
              ),
            ),
          ],
          if (formation.modules.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('Programme / logiciels', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: formation.modules
                  .map((m) => Chip(label: Text(m), backgroundColor: LazouColors.background))
                  .toList(),
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CourseScreen(
                        formationId: formation.id,
                        formationTitre: formation.titre,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.menu_book_outlined, size: 18),
                  label: const Text('Voir le cours'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => InscriptionScreen(formation: formation)),
                  ),
                  child: const Text("S'inscrire"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: LazouColors.primary),
          const SizedBox(width: 10),
          Text('$label : ', style: const TextStyle(color: LazouColors.textSecondary)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
