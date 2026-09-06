import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/certificate_model.dart';
import '../theme/app_theme.dart';

/// Rendu "diplôme" du certificat + son QR. Le QR encode simplement le
/// numéro (pas une URL — pas besoin d'un serveur web séparé pour vérifier :
/// n'importe qui tape le numéro dans l'écran Vérification de l'app).
class CertificateDetailScreen extends StatelessWidget {
  final Certificate certificate;
  const CertificateDetailScreen({super.key, required this.certificate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Certificat')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: LazouColors.secondary, width: 3),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Column(
              children: [
                const Icon(Icons.workspace_premium, color: LazouColors.secondary, size: 48),
                const SizedBox(height: 10),
                const Text(
                  'LAZOU FORMATIONS',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1.2, color: LazouColors.primary),
                ),
                const SizedBox(height: 4),
                const Text('Certificat de fin de formation', style: TextStyle(color: LazouColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 24),
                Text(
                  certificate.etudiantNom,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  'a suivi avec succès la formation',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  certificate.formationTitre,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: LazouColors.primary),
                ),
                if (certificate.moyenne != null) ...[
                  const SizedBox(height: 10),
                  Text('Moyenne obtenue : ${certificate.moyenne!.toStringAsFixed(1)}/20',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
                const SizedBox(height: 24),
                QrImageView(
                  data: certificate.numero,
                  size: 140,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 14),
                SelectableText(
                  certificate.numero,
                  style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  'Vérifiable dans l\'app — onglet Vérification',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
                if (certificate.dateDelivrance != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Délivré le ${certificate.dateDelivrance!.day}/${certificate.dateDelivrance!.month}/${certificate.dateDelivrance!.year}',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
