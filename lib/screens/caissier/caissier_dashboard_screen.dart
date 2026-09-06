import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../admin/paiements_screen.dart';

/// Le caissier n'a accès qu'aux paiements — pas aux notes, pas aux
/// formations, pas aux dossiers étudiants complets. On réutilise
/// volontairement le même écran que l'admin (même logique métier, un seul
/// endroit à maintenir) plutôt que de dupliquer le code.
class CaissierDashboardScreen extends StatelessWidget {
  const CaissierDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const PaiementsScreen(),
      // Un bouton de déconnexion flottant, puisque PaiementsScreen a déjà
      // son propre AppBar sans action de déconnexion (partagé avec l'admin,
      // qui se déconnecte depuis son propre dashboard).
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'deconnexion_caissier',
        backgroundColor: Colors.grey.shade700,
        onPressed: () => context.read<AuthService>().deconnexion(),
        child: const Icon(Icons.logout, size: 18),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
