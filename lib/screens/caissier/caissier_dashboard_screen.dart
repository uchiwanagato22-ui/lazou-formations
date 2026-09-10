import 'package:flutter/material.dart';
import '../admin/paiements_screen.dart';

/// Espace caisse dédié : même logique de paiement, mais avec une navigation
/// et une sortie propres pour le rôle caissier.
class CaissierDashboardScreen extends StatelessWidget {
  const CaissierDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PaiementsScreen(showLogout: true);
  }
}
