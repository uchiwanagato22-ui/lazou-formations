import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';
import 'auth/staff_login_screen.dart';
import 'student_space_screen.dart';

/// Le catalogue reste consultable sans compte (comme une vraie vitrine),
/// mais "Mon espace" (planning, présences, certificats...) nécessite un
/// compte — donc cet onglet bascule entre un prompt de connexion et le
/// vrai espace étudiant selon que la personne est connectée ou non.
class EspaceTab extends StatelessWidget {
  const EspaceTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService?>();
    if (auth?.user != null) return const StudentSpaceScreen();
    return const _PromptConnexion();
  }
}

class _PromptConnexion extends StatelessWidget {
  const _PromptConnexion();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon espace')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.school_outlined, size: 56, color: LazouColors.primary),
              const SizedBox(height: 16),
              const Text(
                'Crée un compte pour suivre ta formation',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
              ),
              const SizedBox(height: 8),
              const Text(
                'Planning, présences, résultats et certificats — tout au même endroit une fois connecté.',
                textAlign: TextAlign.center,
                style: TextStyle(color: LazouColors.textSecondary),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: const Text('Se connecter'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                  ),
                  child: const Text('Créer un compte'),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const StaffLoginScreen()),
                ),
                child: Text(
                  'Espace formateur / administration',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
