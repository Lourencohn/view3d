# View3D · ShowCase3D

> Vitrine 3D + AR para vendedores B2B. Compartilhe modelos interativos com qualquer comprador, em qualquer dispositivo, **sem instalar app**.

![status](https://img.shields.io/badge/status-MVP-orange) ![flutter](https://img.shields.io/badge/flutter-3.19+-blue) ![firebase](https://img.shields.io/badge/firebase-10-yellow)

## Como funciona

1. **Vendedor** abre o app (iOS/Android), escolhe um produto e toca em "Compartilhar".
2. Comprador recebe um link `https://viewer.showcas3d.app/v/{id}`.
3. Abre no navegador → vê o produto em 3D → toca em "Ver em AR" → projeta em tamanho real no ambiente.

## Stack

Flutter • Firebase (Auth, Firestore, Storage, Hosting) • model_viewer_plus • Riverpod • go_router

## Setup rápido

```bash
git clone https://github.com/Lourencohn/view3d.git
cd view3d
flutter pub get

# Gera android/ e ios/ nativos (primeira vez)
flutter create . --org app.showcas3d --project-name view3d --platforms=android,ios

# Conecta seu projeto Firebase
dart pub global activate flutterfire_cli
flutterfire configure

# Publica rules + viewer
firebase deploy --only firestore:rules,storage,hosting:viewer

flutter run
```

**Detalhes completos em [`CLAUDE.md`](./CLAUDE.md).** Esse documento é o manual operacional — leia antes de continuar o desenvolvimento.

## Estrutura

```
lib/
  main.dart  router.dart  theme.dart  firebase_options.dart
  models/        # Produto, Usuario, Empresa
  features/
    auth/        # login + auth providers
    catalogo/    # grid + filtros
    produto/     # detalhe (ModelViewer), QR, share sheet
  shared/widgets/
web/viewer/      # página pública estática (Firebase Hosting)
*.rules          # firestore.rules + storage.rules
```

## Licença

Privado — todos os direitos reservados.
