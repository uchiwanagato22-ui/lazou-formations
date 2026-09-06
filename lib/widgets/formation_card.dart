import 'package:flutter/material.dart';
import '../models/formation.dart';
import '../theme/app_theme.dart';
import 'animations.dart';

class FormationCard extends StatelessWidget {
  final Formation formation;
  final VoidCallback onTap;

  const FormationCard({super.key, required this.formation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Hero(
                tag: 'formation_icon_${formation.id}',
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: LazouColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(formation.domaine.icone, color: LazouColors.primary),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formation.titre,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formation.duree,
                      style: const TextStyle(color: LazouColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: LazouColors.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        formation.domaine.label,
                        style: const TextStyle(
                          color: LazouColors.secondary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: LazouColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
