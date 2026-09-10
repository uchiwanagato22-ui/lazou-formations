import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animations.dart';
import 'signup_screen.dart';
import 'staff_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _motDePasse = TextEditingController();
  String? _erreur;
  bool _motDePasseVisible = false;

  @override
  void dispose() {
    _email.dispose();
    _motDePasse.dispose();
    super.dispose();
  }

  Future<void> _seConnecter() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _erreur = null);
    final auth = context.read<AuthService>();
    final erreur = await auth.connexion(email: _email.text.trim(), motDePasse: _motDePasse.text);
    if (!mounted) return;
    if (erreur != null) {
      setState(() => _erreur = erreur);
    } else {
      // Succès : on referme cet écran (poussé par-dessus l'app) pour
      // révéler le RootRouter en dessous, qui a déjà basculé sur le bon
      // espace via authStateChanges() — sinon l'écran de connexion reste
      // affiché indéfiniment malgré la connexion réussie.
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _seConnecterGoogle() async {
    setState(() => _erreur = null);
    final auth = context.read<AuthService>();
    final erreur = await auth.connexionGoogle();
    if (!mounted) return;
    if (erreur != null) {
      setState(() => _erreur = erreur);
    } else {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [LazouColors.primary, Color(0xFF14538F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -50,
              top: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: .06)),
              ),
            ),
            Positioned(
              left: -60,
              bottom: 40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(shape: BoxShape.circle, color: LazouColors.secondary.withValues(alpha: .12)),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), shape: BoxShape.circle),
                        child: const Icon(Icons.school, size: 40, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'LAZOU Formations',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      const Text(
                        "Le monde des solutions d'excellence",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12.5, color: Colors.white70),
                      ),
                      const SizedBox(height: 28),
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .15), blurRadius: 30, offset: const Offset(0, 12))],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text('Connexion', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 18),
                              TextFormField(
                                controller: _email,
                                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline)),
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _motDePasse,
                                decoration: InputDecoration(
                                  labelText: 'Mot de passe',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    tooltip: _motDePasseVisible ? 'Masquer le mot de passe' : 'Afficher le mot de passe',
                                    onPressed: () => setState(() => _motDePasseVisible = !_motDePasseVisible),
                                    icon: Icon(_motDePasseVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                                  ),
                                ),
                                obscureText: !_motDePasseVisible,
                                validator: (v) => (v == null || v.isEmpty) ? 'Champ requis' : null,
                              ),
                              if (_erreur != null) ...[
                                const SizedBox(height: 12),
                                Text(_erreur!, style: const TextStyle(color: LazouColors.error, fontSize: 13)),
                              ],
                              const SizedBox(height: 20),
                              PressFeedback(
                                child: ElevatedButton(
                                  onPressed: auth.loading ? null : _seConnecter,
                                  child: auth.loading
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : const Text('Se connecter'),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(child: Divider(color: Colors.grey.shade300)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Text('ou', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                  ),
                                  Expanded(child: Divider(color: Colors.grey.shade300)),
                                ],
                              ),
                              const SizedBox(height: 14),
                              OutlinedButton.icon(
                                onPressed: auth.loading ? null : _seConnecterGoogle,
                                icon: const Icon(Icons.g_mobiledata, size: 26),
                                label: const Text('Continuer avec Google'),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                                ),
                                child: const Text("Pas encore de compte ? S'inscrire"),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const StaffLoginScreen()),
                        ),
                        child: const Text(
                          'Espace formateur / administration',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
