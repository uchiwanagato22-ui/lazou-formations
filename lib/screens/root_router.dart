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

    if (auth.initializing) {
      return const _RouterLoading();
    }

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

class _RouterLoading extends StatelessWidget {
  const _RouterLoading();
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF7F8FA),
    body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .06), blurRadius: 24)]), child: const Icon(Icons.school_rounded, color: Color(0xFF0D3B66), size: 36)),
      const SizedBox(height: 18), const CircularProgressIndicator(), const SizedBox(height: 12),
      const Text('Préparation de votre espace…', style: TextStyle(fontWeight: FontWeight.w700)),
    ])),
  );
}
