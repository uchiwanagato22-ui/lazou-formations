import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/formation.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/formation_card.dart';
import 'formation_detail_screen.dart';
import 'formations_screen.dart';
import 'verify_certificate_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('LAZOU Formations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.verified_outlined),
            tooltip: 'Vérifier un certificat',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const VerifyCertificateScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeroBanner(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Nos formations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              TextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FormationsScreen())),
                child: const Text('Voir tout'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<Formation>>(
            stream: firestore.watchFormations(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return const _HomeNotice(message: 'Le catalogue est momentanément indisponible.');
              }
              final formations = (snapshot.data ?? const <Formation>[]).take(3).toList();
              if (formations.isEmpty) {
                return const _HomeNotice(message: 'Les prochaines formations seront publiées ici.');
              }
              return Column(
                children: formations.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FormationCard(
                    formation: f,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => FormationDetailScreen(formation: f))),
                  ),
                )).toList(),
              );
            },
          ),
          const SizedBox(height: 8),
          const _ContactCard(),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [LazouColors.primary, Color(0xFF14538F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Formes décoratives en arrière-plan — donnent de la profondeur
            // à un simple aplat de couleur, sans image à charger.
            Positioned(
              right: -30,
              top: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: -50,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: LazouColors.secondary.withValues(alpha: 0.18),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LAZOU\nFormation professionnelle',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Développez des compétences utiles pour vos études et votre carrière.',
                  style: TextStyle(color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatChip(label: 'Formations certifiantes'),
                    _StatChip(label: 'Inscription en ligne'),
                  ],
                ),              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  const _StatChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nous contacter', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => launchUrl(Uri.parse('tel:+22222171785')),
              child: const _ContactRow(icon: Icons.phone, label: '22 17 17 85 · Appeler'),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: () => launchUrl(Uri.parse('https://wa.me/22222171785')),
              child: const _ContactRow(icon: Icons.chat_outlined, label: 'WhatsApp · Nous écrire'),
            ),
            const SizedBox(height: 6),
            const _ContactRow(icon: Icons.access_time, label: 'Lun–Sam · 8h–12h / 15h–19h30'),
          ],
        ),
      ),
    );
  }
}

class _HomeNotice extends StatelessWidget {
  final String message;
  const _HomeNotice({required this.message});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: LazouColors.surface, borderRadius: BorderRadius.circular(16)),
    child: Row(children: [
      const Icon(Icons.info_outline, color: LazouColors.secondary),
      const SizedBox(width: 10),
      Expanded(child: Text(message, style: const TextStyle(color: LazouColors.textSecondary))),
    ]),
  );
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ContactRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: LazouColors.textSecondary),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: LazouColors.textSecondary)),
      ],
    );
  }
}
