import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// Upload non signé vers Cloudinary — pas besoin de Firebase Storage (qui
/// demande le plan payant Blaze depuis le changement de politique Google),
/// même principe que ce qui a été mis en place sur Shokugeki Menu.
///
/// ⚠️ À CONFIGURER avant de pouvoir uploader quoi que ce soit :
/// 1. Sur cloudinary.com (compte gratuit) → Settings → Upload →
///    "Add upload preset" → mode "Unsigned" → note le nom du preset.
/// 2. Remplace _cloudName et _uploadPreset ci-dessous par tes vraies valeurs.
class CloudinaryService {
  static const _cloudName = 'dr1rbdtph';
  static const _uploadPreset = 'lazou_preset';

  /// Envoie un fichier (bytes en mémoire, marche sur mobile ET web) et
  /// retourne son URL publique HTTPS, à stocker dans Firestore.
  static Future<String> uploaderFichier(Uint8List bytes, String nomFichier) async {
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/auto/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: nomFichier));

    final reponse = await request.send();
    final corps = await reponse.stream.bytesToString();

    if (reponse.statusCode != 200) {
      throw Exception('Échec upload Cloudinary (${reponse.statusCode}) : $corps');
    }
    final data = jsonDecode(corps) as Map<String, dynamic>;
    return data['secure_url'] as String;
  }
}
