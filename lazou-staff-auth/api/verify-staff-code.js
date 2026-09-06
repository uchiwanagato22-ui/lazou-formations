const admin = require('firebase-admin');

// Initialisé une seule fois (les fonctions Vercel réutilisent l'instance
// entre invocations tant que le conteneur reste chaud).
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(
      JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON)
    ),
  });
}

const db = admin.firestore();

module.exports = async (req, res) => {
  // CORS : autorise l'app Flutter (web) à appeler cette fonction.
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Méthode non autorisée' });

  const { code } = req.body || {};
  if (!code || typeof code !== 'string' || !/^\d{4}$/.test(code)) {
    return res.status(400).json({ error: 'Code invalide (4 chiffres attendus)' });
  }

  try {
    const staffDoc = await db.collection('staffCodes').doc(code).get();

    if (!staffDoc.exists || staffDoc.data().actif === false) {
      // Réponse volontairement identique que le code existe ou non, pour ne
      // pas laisser deviner quels codes sont valides par tâtonnement.
      return res.status(401).json({ error: 'Code incorrect' });
    }

    const { role, nom } = staffDoc.data();
    const uid = `staff_${code}`;

    // Crée le compte Firebase Auth associé au staff s'il n'existe pas déjà
    // (première utilisation de ce code), sinon le réutilise.
    try {
      await admin.auth().getUser(uid);
    } catch (_) {
      await admin.auth().createUser({ uid });
    }

    // Garde users/{uid} synchronisé, pour que le AuthService Flutter (qui
    // lit le rôle depuis Firestore, pas depuis le token) route correctement.
    await db.collection('users').doc(uid).set(
      { role, nomComplet: nom || '', staffCode: code },
      { merge: true }
    );

    const token = await admin.auth().createCustomToken(uid, { role });
    return res.status(200).json({ token, role });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Erreur serveur' });
  }
};
