import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'animations.dart';

class PremiumPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<Widget>? actions;
  const PremiumPageHeader({super.key, required this.title, this.subtitle, this.icon, this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [LazouColors.primary, Color(0xFF14538F)]),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: LazouColors.primary.withValues(alpha: .16), blurRadius: 22, offset: const Offset(0, 8))],
      ),
      child: Row(children: [
        if (icon != null) ...[
          Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .13), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: Colors.white)),
          const SizedBox(width: 12),
        ],
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)),
          if (subtitle != null) ...[const SizedBox(height: 4), Text(subtitle!, style: const TextStyle(color: Colors.white70, height: 1.35))],
        ])),
        if (actions != null) ...actions!,
      ]),
    );
  }
}

class PremiumEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;
  const PremiumEmptyState({super.key, required this.icon, required this.title, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(28),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: LazouColors.primary.withValues(alpha: .07), shape: BoxShape.circle), child: Icon(icon, size: 34, color: LazouColors.primary)),
      const SizedBox(height: 16),
      Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Text(message, textAlign: TextAlign.center, style: const TextStyle(color: LazouColors.textSecondary, height: 1.45)),
      if (onRetry != null) ...[const SizedBox(height: 16), OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Réessayer'))],
    ]),
  ));
}

class PremiumStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool highlight;
  const PremiumStatCard({super.key, required this.label, required this.value, required this.icon, this.highlight = false});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFECEFF3)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .035), blurRadius: 12, offset: const Offset(0, 4))]),
    child: Row(children: [
      Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: (highlight ? LazouColors.secondary : LazouColors.primary).withValues(alpha: .10), borderRadius: BorderRadius.circular(11)), child: Icon(icon, size: 19, color: highlight ? LazouColors.secondary : LazouColors.primary)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: LazouColors.textSecondary, fontSize: 11.5)), const SizedBox(height: 2), Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900))])),
    ]),
  );
}


class PremiumSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onAction;
  final String actionLabel;

  const PremiumSectionHeader({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
    this.onAction,
    this.actionLabel = 'Voir tout',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: LazouColors.primary.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 19, color: LazouColors.primary),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: const TextStyle(fontSize: 11.5, color: LazouColors.textSecondary)),
              ],
            ],
          ),
        ),
        if (onAction != null)
          TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}

class PremiumActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool accent;

  const PremiumActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final tint = accent ? LazouColors.secondary : LazouColors.primary;
    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE9EDF2)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: .035), blurRadius: 18, offset: const Offset(0, 7)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: tint.withValues(alpha: .10), borderRadius: BorderRadius.circular(13)),
              child: Icon(icon, color: tint, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                  const SizedBox(height: 3),
                  Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: LazouColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Color(0xFF9AA3AF)),
          ],
        ),
      ),
    );
  }
}
