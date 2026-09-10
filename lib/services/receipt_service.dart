import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/payment_model.dart';

/// Reçu simple, une page — nom, matricule, formation, date, montant,
/// méthode. Partagé via la feuille de partage native (WhatsApp, email,
/// enregistrer...) plutôt que d'envoyer nous-mêmes le message : plus
/// simple, pas besoin d'API WhatsApp, l'utilisateur choisit le canal.
class ReceiptService {
  static Future<void> partagerRecu(Paiement paiement, {String? matriculeEtudiant}) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('LAZOU FORMATIONS',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0D3B66'))),
            pw.Text('Reçu de paiement', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
            pw.SizedBox(height: 24),
            pw.Divider(),
            pw.SizedBox(height: 12),
            _ligne('Étudiant', paiement.etudiantNom),
            if (matriculeEtudiant != null && matriculeEtudiant.isNotEmpty) _ligne('Matricule', matriculeEtudiant),
            _ligne('Formation', paiement.formationTitre),
            _ligne('Date', paiement.date != null ? _formaterDate(paiement.date!) : '—'),
            if (paiement.moisLabel.isNotEmpty) _ligne('Mois concerné', paiement.moisLabel),
            _ligne('Méthode', paiement.methode.label),
            if (paiement.note != null && paiement.note!.isNotEmpty) _ligne('Note', paiement.note!),
            pw.SizedBox(height: 12),
            pw.Divider(),
            pw.SizedBox(height: 12),
            pw.Text('Montant versé', style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
            pw.Text('${paiement.montant.toStringAsFixed(0)} MRU',
                style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0D3B66'))),
            pw.SizedBox(height: 24),
            pw.Text('Encaissé par ${paiement.enregistreParNom}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
          ],
        ),
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'recu-lazou-${paiement.id.isEmpty ? DateTime.now().millisecondsSinceEpoch : paiement.id}.pdf',
    );
  }

  static pw.Widget _ligne(String label, String valeur) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 90, child: pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700))),
          pw.Expanded(child: pw.Text(valeur, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold))),
        ],
      ),
    );
  }

  static String _formaterDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
