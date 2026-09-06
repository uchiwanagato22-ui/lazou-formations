import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

/// Vérifie l'état de l'abonnement Lazou (config/abonnement.actif dans
/// Firestore) et bloque tout accès à l'app si c'est faux — même logique
/// que le kill-switch par restaurant de Shokugeki Menu, mais ici un seul
/// client donc un seul document plutôt qu'une collection par client.
///
/// Fail-open volontaire : si le document n'existe pas encore (avant que tu
/// l'aies créé) ou en cas d'erreur réseau, l'app reste accessible plutôt
/// que de bloquer tout le monde par accident pendant la mise en place.
class SubscriptionGate extends StatelessWidget {
  final Widget child;
  const SubscriptionGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('config').doc('abonnement').snapshots(),
      builder: (context, snapshot) {
        final actif = snapshot.data?.data()?['actif'];
        final bloque = actif == false; // uniquement si explicitement à false
        if (bloque) return const _EcranBloque();
        return child;
      },
    );
  }
}

class _EcranBloque extends StatelessWidget {
  const _EcranBloque();

  // TODO Drak : mets tes vraies coordonnées ici (numéro confirmé,
  // adresse à ajouter) avant de déployer en vrai.
  static const _telephone = '+222 32 65 23 00';
  static const _email = 'uchiwanagato22@gmail.com';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LazouColors.primary,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 56, color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                'Accès suspendu',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              const Text(
                "L'abonnement de cette application n'est plus à jour. "
                'Contacte le développeur pour le réactiver.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, height: 1.5),
              ),
              const SizedBox(height: 28),
              _ContactButton(
                icon: Icons.call,
                label: _telephone,
                onTap: () => launchUrl(Uri.parse('tel:$_telephone')),
              ),
              const SizedBox(height: 10),
              _ContactButton(
                icon: Icons.email_outlined,
                label: _email,
                onTap: () => launchUrl(Uri.parse('mailto:$_email')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ContactButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white54),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
