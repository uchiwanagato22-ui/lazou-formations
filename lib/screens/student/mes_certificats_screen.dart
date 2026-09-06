import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/certificate_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../certificate_detail_screen.dart';

class MesCertificatsScreen extends StatelessWidget {
  const MesCertificatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthService>().user?.uid;
    final firestore = context.read<FirestoreService>();

    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Connecte-toi pour voir tes certificats.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mes certificats')),
      body: StreamBuilder<List<Certificate>>(
        stream: firestore.watchCertificatsEtudiant(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final certificats = snapshot.data ?? [];
          if (certificats.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Pas encore de certificat — il sera délivré par Lazou à la fin de ta formation.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: LazouColors.textSecondary),
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: certificats.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final c = certificats[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.workspace_premium, color: LazouColors.secondary),
                  title: Text(c.formationTitre, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(c.numero),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => CertificateDetailScreen(certificate: c)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
