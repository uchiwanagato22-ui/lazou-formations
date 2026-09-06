# Configurer Firebase pour Lazou Formations

Le code (Auth, Firestore, Storage, Messaging) est déjà écrit et branché,
mais il a besoin d'un vrai projet Firebase pour tourner. Sans ça, l'app
démarre quand même en **mode démo** (accueil, catalogue, cours — pas de
connexion), donc tu peux avancer sur l'UI avant de faire cette étape.

## 1. Créer le projet Firebase

1. https://console.firebase.google.com → **Ajouter un projet** → `lazou-formations`
2. Active **Authentication** → méthode **Email/Mot de passe**
3. Active **Firestore Database** (mode production)
4. Active **Storage**

## 2. Connecter le projet Flutter

Depuis la racine du projet (là où est `pubspec.yaml`) :

```bash
npm install -g firebase-tools
firebase login

dart pub global activate flutterfire_cli
flutterfire configure
```

`flutterfire configure` te demande de choisir le projet `lazou-formations`
et les plateformes (Android/iOS/Web...), puis génère automatiquement
`lib/firebase_options.dart`. Une fois ce fichier présent, relance l'app :
`main.dart` détecte Firebase tout seul et bascule du mode démo vers le
vrai mode connecté (login, rôles, etc.).

## 3. Premier compte admin

Les nouveaux comptes créés depuis l'app sont **toujours étudiant** par
défaut (voir `auth_service.dart` — volontaire, pour éviter qu'un
étudiant se donne lui-même les droits admin). Pour créer le premier
compte admin (toi, ou le directeur) :

1. Inscris-toi normalement dans l'app
2. Dans la console Firebase → Firestore → collection `users` → ton document
3. Change le champ `role` de `"etudiant"` à `"admin"`

Idem pour un formateur : `role: "formateur"`.

## 4. Règles de sécurité Firestore

Le fichier `firestore.rules` est déjà écrit à la racine du projet
(isolation par rôle, rôle non modifiable par le client, catalogue en
lecture publique). À déployer avant toute mise en ligne réelle :

```bash
firebase deploy --only firestore:rules
```

(nécessite d'avoir fait `firebase init` une fois si ce n'est pas déjà fait,
en pointant sur le même projet `lazou-formations`.)

## 5. Verrou d'abonnement (kill-switch)

L'app entière (une fois Firebase branché) vérifie `config/abonnement.actif`
dans Firestore à chaque démarrage. Si tu passes ce champ à `false`,
**tout le monde est bloqué** (étudiants, formateurs, admin) avec un écran
affichant ton numéro/email pour te recontacter — même principe que le
kill-switch de Shokugeki Menu, mais un seul document ici puisqu'il n'y a
qu'un seul client.

Pour activer/couper l'accès : Firestore → collection `config` → document
`abonnement` → champ `actif` (`true`/`false`). Si le document n'existe pas
encore, l'app reste accessible par défaut (fail-open volontaire, pour ne
pas bloquer tout le monde par accident avant que tu l'aies configuré).

⚠️ Pense à mettre tes vraies coordonnées dans
`lib/widgets/subscription_gate.dart` (`_telephone`/`_email`) avant de
déployer — j'ai mis les mêmes que Shokugeki Menu par défaut, à confirmer
ou changer si tu veux un contact différent pour ce projet.

## 6. Espace staff (formateur/admin) — code PIN

Séparé de l'espace étudiant, accessible depuis un lien discret en bas de
l'écran de connexion. Voir `lazou-staff-auth/README_DEPLOY.md` pour
déployer la fonction de vérification (Vercel, gratuit) et créer les codes.
