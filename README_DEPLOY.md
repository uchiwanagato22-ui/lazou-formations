# Déployer la vérification des codes staff (Vercel — gratuit)

Même principe que `shokugeki-staff-auth.vercel.app` sur ton autre projet :
une fonction serveur qui vérifie le code PIN et renvoie un jeton Firebase,
sans jamais exposer les codes dans Firestore côté client.

## 1. Créer le projet sur Vercel

```bash
npm install -g vercel
cd lazou-staff-auth
vercel login
vercel
```

Accepte les valeurs par défaut à chaque question. Vercel te donne une URL
du style `https://lazou-staff-auth.vercel.app`.

## 2. Ajouter la clé de service Firebase

Console Firebase → ⚙️ Paramètres du projet → **Comptes de service** →
**Générer une nouvelle clé privée** → télécharge le fichier JSON.

Puis, dans le dossier `lazou-staff-auth` :

```bash
vercel env add FIREBASE_SERVICE_ACCOUNT_JSON
```

Colle le contenu **complet** du fichier JSON téléchargé (tout sur une
ligne) quand c'est demandé. Choisis "Production" (et "Preview"/"Development"
si tu comptes tester en local).

Redéploie ensuite pour que la variable soit prise en compte :

```bash
vercel --prod
```

## 3. Créer les codes staff dans Firestore

Console Firebase → Firestore → collection `staffCodes` → un document par
personne, **l'ID du document = le code PIN à 4 chiffres** :

```
staffCodes/1234
  role: "admin"
  nom: "Abdoulaye Diallo"
  actif: true

staffCodes/5678
  role: "formateur"
  nom: "Nom du formateur"
  actif: true
```

Pour désactiver quelqu'un (départ, code compromis) : passe `actif` à
`false` plutôt que de supprimer le document — plus facile à réactiver.

## 4. Brancher l'URL dans l'app Flutter

Dans `lib/services/auth_service.dart`, remplace la constante
`_staffAuthUrl` par ton URL Vercel réelle (`https://lazou-staff-auth.vercel.app/api/verify-staff-code`).
