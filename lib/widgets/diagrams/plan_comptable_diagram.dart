import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Schéma des 7 classes du plan comptable (norme SYSCOHADA, utilisée en
/// Afrique de l'Ouest/Centrale). Dessiné directement — pas d'image externe,
/// donc ça marche hors-ligne et reste net sur tous les écrans.
class PlanComptableDiagram extends StatelessWidget {
  const PlanComptableDiagram({super.key});

  static const _classes = [
    ('1', 'Comptes de ressources durables', LazouColors.primary),
    ('2', 'Comptes d\'actif immobilisé', LazouColors.primary),
    ('3', 'Comptes de stocks', LazouColors.secondary),
    ('4', 'Comptes de tiers', LazouColors.secondary),
    ('5', 'Comptes de trésorerie', LazouColors.secondary),
    ('6', 'Comptes de charges', Color(0xFFC62828)),
    ('7', 'Comptes de produits', Color(0xFF2E7D32)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _classes
            .map(
              (c) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: (c.$3 as Color).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        c.$1,
                        style: TextStyle(fontWeight: FontWeight.w800, color: c.$3),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(c.$2, style: const TextStyle(fontSize: 13.5)),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
