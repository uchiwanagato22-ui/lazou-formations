import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';
import 'admin/admin_dashboard_screen.dart';
import 'caissier/caissier_dashboard_screen.dart';
import 'formateur/formateur_dashboard_screen.dart';
import 'main_shell.dart';

/// Point d'entrée après le splash. Le catalogue reste public (MainShell,
/// avec navigation par onglets) — seuls les rôles staff sont redirigés
/// directement vers leur dashboard dédié, tout le reste (invité ou
/// étudiant connecté) voit la même coquille publique.
class RootRouter extends StatelessWidget {
  const RootRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    switch (auth.role) {
      case UserRole.admin:
        return const AdminDashboardScreen();
      case UserRole.formateur:
        return const FormateurDashboardScreen();
      case UserRole.caissier:
        return const CaissierDashboardScreen();
      case UserRole.etudiant:
      case null:
        return const MainShell();
    }
  }
}
