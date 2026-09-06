import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/root_router.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'theme/app_theme.dart';
import 'widgets/subscription_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? erreurFirebase;
  try {
    await Firebase.initializeApp();
  } catch (e) {
    erreurFirebase = e.toString();
    debugPrint('Échec Firebase.initializeApp() : $e');
  }

  runApp(LazouApp(erreurFirebase: erreurFirebase));
}

class LazouApp extends StatelessWidget {
  final String? erreurFirebase;
  const LazouApp({super.key, this.erreurFirebase});

  @override
  Widget build(BuildContext context) {
    if (erreurFirebase != null) {
      return MaterialApp(
        title: 'LAZOU Formations',
        debugShowCheckedModeBanner: false,
        theme: LazouTheme.light(),
        home: _EcranErreurFirebase(erreur: erreurFirebase!),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => FirestoreService()),
      ],
      child: MaterialApp(
        title: 'LAZOU Formations',
        debugShowCheckedModeBanner: false,
        theme: LazouTheme.light(),
        home: const SubscriptionGate(child: RootRouter()),
      ),
    );
  }
}

class _EcranErreurFirebase extends StatelessWidget {
  final String erreur;
  const _EcranErreurFirebase({required this.erreur});

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
              const Icon(Icons.cloud_off, size: 48, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                "Connexion au serveur impossible",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              const Text(
                "Vérifie ta connexion internet et réessaie. Si le problème persiste, contacte le développeur avec le message ci-dessous.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, height: 1.5),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  erreur,
                  style: const TextStyle(color: Colors.white54, fontSize: 11, fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
