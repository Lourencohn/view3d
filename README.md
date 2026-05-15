# TROVATA — Catálogo Digital e Vendas B2B

> Vitrine 3D + AR da **Trovata** (Birigui-SP). Vendedores compartilham modelos interativos com compradores em qualquer dispositivo, **sem instalar app**.

![status](https://img.shields.io/badge/status-MVP-1976D2) ![flutter](https://img.shields.io/badge/flutter-3.19+-1976D2) ![firebase](https://img.shields.io/badge/firebase-10-D32F2F)

## Como funciona

1. **Vendedor** abre o app (iOS/Android), navega o catálogo Trovata, escolhe um produto e toca em **Compartilhar**.
2. Comprador recebe um link `https://catalogo.trovata.com.br/v/{id}`.
3. Abre no navegador → vê o produto em 3D → toca em **Ver em AR** → projeta em tamanho real no ambiente.

## Stack

Flutter • Firebase (Auth, Firestore, Storage, Hosting) • model_viewer_plus • Riverpod • go_router

## Telas

- **Login** com o logo Trovata
- **Catálogo digital** — grid de produtos com filtros por categoria
- **Detalhe do produto** — viewer 3D real (`<model-viewer>`) + botão AR + compartilhamento
- **QR Code** — gera QR do link público, copia automaticamente para o clipboard
- **Compartilhados** — histórico agrupado por dia, com contagem de views e sessões AR por envio
- **Insights** — métricas dos últimos 7 dias com sparkbar, top produtos e distribuição por canal
- **Conta** — perfil, preferências, sair
- **Página pública do viewer** (web) — `web/viewer/index.html`, mobile-first, sem login

## Setup rápido

```bash
git clone https://github.com/Lourencohn/view3d.git
cd view3d
flutter pub get

# Gera android/ e ios/ nativos (primeira vez)
flutter create . --org br.com.trovata --project-name view3d --platforms=android,ios

# Conecta seu projeto Firebase (gera o firebase_options.dart real)
dart pub global activate flutterfire_cli
flutterfire configure

# Publica rules + viewer
firebase deploy --only firestore:rules,storage,hosting:viewer

flutter run
```

**Detalhes completos em [`CLAUDE.md`](./CLAUDE.md).**

## Identidade visual

- **Azul Trovata** `#1976D2` — primário, CTAs, links
- **Vermelho Trovata** `#D32F2F` — acento de marca, alertas
- **Verde Trovata** `#2E7D32` — sucesso, status positivo
- **Neutros frios** — `#0F172A` ink, `#FBFCFE` background
- **Tipografia** — _Instrument Serif_ (títulos), _Geist_ / system-ui (UI), monospace (SKUs)

Logo em `assets/images/trovata-logo.png` e `web/viewer/trovata-logo.png`.

## Licença

Privado — Trovata Birigui-SP — todos os direitos reservados.
