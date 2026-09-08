import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// État vide standard — icône dans un cercle pastel + message centré.
/// Remplace les `Text('Aucun ...')` isolés qui rendaient chaque écran
/// vide différent (et un peu triste) d'un endroit à l'autre de l'app.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? sousMessage;

  const EmptyState({super.key, required this.icon, required this.message, this.sousMessage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: LazouColors.primary.withValues(alpha: .07), shape: BoxShape.circle),
              child: Icon(icon, size: 34, color: LazouColors.primary.withValues(alpha: .55)),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: LazouColors.textPrimary),
            ),
            if (sousMessage != null) ...[
              const SizedBox(height: 6),
              Text(
                sousMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12.5, color: LazouColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
