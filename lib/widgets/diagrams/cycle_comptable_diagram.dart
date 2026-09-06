import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Schéma du cycle comptable classique, en étapes reliées par des flèches.
class CycleComptableDiagram extends StatelessWidget {
  const CycleComptableDiagram({super.key});

  static const _etapes = [
    'Pièce justificative',
    'Journal',
    'Grand livre',
    'Balance',
    'Bilan & compte de résultat',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _etapes.length; i++) ...[
          _StepBox(label: _etapes[i], index: i + 1),
          if (i != _etapes.length - 1)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 2),
              child: Icon(Icons.arrow_downward, color: LazouColors.textSecondary, size: 20),
            ),
        ],
      ],
    );
  }
}

class _StepBox extends StatelessWidget {
  final String label;
  final int index;
  const _StepBox({required this.label, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: LazouColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LazouColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: LazouColors.primary,
            child: Text(
              '$index',
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
