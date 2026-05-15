# CLAUDE.md — View3D / ShowCase3D

> **Para o Claude Code:** este é o manual operacional do projeto. Leia este arquivo inteiro antes de começar a editar. Atualize-o quando alterar arquitetura, fluxos ou dependências.

---

## 1. O que é o produto

App B2B em três superfícies:

| Quem        | Onde                       | O que faz                                                |
|-------------|----------------------------|----------------------------------------------------------|
| Vendedor    | App Flutter (iOS + Android)| Visualiza modelos 3D do catálogo da própria empresa e compartilha links com compradores |
| Comprador   | Navegador (mobile/desktop) | Abre o link, gira o modelo, projeta em AR — **sem instalar nada** |
| Admin       | _Fora do MVP atual_        | Upload de modelos GLB; hoje feito via Console do Firebase (ver §5) |

Diferencial: **AR no navegador** via `<model-viewer>` (WebXR no Android, Quick Look no iOS) — comprador pinga o link, abre no celular, vê em tamanho real no ambiente.

## 2. Stack

- **Flutter 3.19+** — vendedor app (iOS + Android; web só para o admin futuro)
- **Firebase**
  - Auth (e-mail/senha, multi-tenant por empresa)
  - Firestore (metadados dos produtos)
  - Storage (arquivos `.glb` com URL pública)
  - Hosting (página estática do viewer)
- **model_viewer_plus** — render 3D + AR dentro do app Flutter
- **Riverpod** (sem code-gen no MVP — providers manuais; pode migrar pra `riverpod_annotation` depois)
- **go_router** — navegação
- **share_plus**, **qr_flutter**, **cached_network_image**

## 3. Estrutura

```
view3d/
├── pubspec.yaml
├── analysis_options.yaml
├── firebase.json                # Hosting target "viewer" + rules
├── firestore.rules
├── firestore.indexes.json
├── storage.rules
├── lib/
│   ├── main.dart                # bootstrap (Firebase.initializeApp + ProviderScope)
│   ├── firebase_options.dart    # PLACEHOLDER — substituir via `flutterfire configure`
│   ├── router.dart              # go_router + redirect baseado em auth
│   ├── theme.dart               # tokens visuais (Material 3 + serif Instrument)
│   ├── models/
│   │   ├── produto.dart
│   │   ├── usuario.dart
│   │   └── empresa.dart
│   ├── features/
│   │   ├── auth/
│   │   │   ├── auth_provider.dart    # firebaseAuth/firestore/usuario/authState/controller
│   │   │   └── login_screen.dart
│   │   ├── catalogo/
│   │   │   ├── catalogo_provider.dart # produtosProvider + filtro
│   │   │   └── catalogo_screen.dart
│   │   └── produto/
│   │       ├── detalhe_screen.dart   # ModelViewer + ações
│   │       ├── qr_screen.dart        # QR + copia link automático
│   │       └── share_sheet.dart      # bottom sheet de compartilhamento
│   └── shared/
│       └── widgets/
│           ├── loading_widget.dart
│           └── app_error_widget.dart
├── web/
│   └── viewer/                  # página pública (estática, hospedada no Firebase Hosting)
│       ├── index.html
│       ├── viewer.css
│       └── viewer.js            # lê produtos/{id} do Firestore e popula <model-viewer>
└── scripts/
    └── seed.dart                # opcional — popula Firestore com produtos de exemplo
```

## 4. Setup inicial — passo a passo

### 4.1. Pré-requisitos
- Flutter 3.19+ (`flutter --version`)
- Node 18+ (`firebase deploy` usa npm)
- `firebase-tools`: `npm i -g firebase-tools`
- `flutterfire_cli`: `dart pub global activate flutterfire_cli`

### 4.2. Clonar e baixar deps
```bash
git clone https://github.com/Lourencohn/view3d.git
cd view3d
flutter pub get
```

### 4.3. Gerar a estrutura nativa (primeira vez)
O `.zip` desta entrega **não inclui as pastas `android/` e `ios/`** porque elas são geradas pela CLI do Flutter com o teu Bundle ID e Application ID. Rode:

```bash
# Substitua "app.showcas3d.view3d" pelo bundle ID definitivo
flutter create . \
  --org app.showcas3d \
  --project-name view3d \
  --platforms=android,ios \
  --description "View3D — Vitrine B2B 3D + AR"
```

Isso preenche `android/` e `ios/` sem mexer no `lib/`.

### 4.4. Configurar Firebase
1. Crie um projeto no [console.firebase.google.com](https://console.firebase.google.com).
2. Ative **Authentication → Sign-in method → Email/Password**.
3. Ative **Firestore Database** (modo de produção).
4. Ative **Storage**.
5. Rode `flutterfire configure` na raiz do projeto. Ele detecta as plataformas e regenera `lib/firebase_options.dart` com as chaves reais. (O arquivo já existe como placeholder.)
6. Publique as rules:
   ```bash
   firebase use --add        # vincula a pasta ao projeto
   firebase deploy --only firestore:rules,storage,firestore:indexes
   ```

### 4.5. Ajustes nativos (Android + iOS)
**Android** — edite `android/app/src/main/AndroidManifest.xml`, adicione dentro de `<manifest>`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>

<!-- Scene Viewer (AR no Android) -->
<queries>
  <intent>
    <action android:name="android.intent.action.VIEW"/>
    <data android:scheme="https" android:host="arvr.google.com"/>
  </intent>
</queries>
```

**iOS** — edite `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Câmera usada para mostrar o produto em realidade aumentada.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Para salvar fotos do produto em AR.</string>

<!-- Quick Look (AR no iOS) -->
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>itms-apps</string>
</array>
```

Bump `ios/Podfile` para `platform :ios, '13.0'` (mínimo do `model_viewer_plus`).

### 4.6. Subir o viewer público (Firebase Hosting)
```bash
firebase deploy --only hosting:viewer
```
Configure um domínio custom (`viewer.showcas3d.app`) no console — ou use o `*.web.app` padrão e atualize `viewerUrl` na criação de produtos (§5).

### 4.7. Rodar
```bash
flutter run        # device conectado
flutter run -d ios
flutter run -d android
```

## 5. Como popular o catálogo (sem painel admin)

O MVP **não** tem painel administrativo. Para subir produtos, três caminhos:

### Caminho A — Console do Firebase (manual, rápido para 1-5 produtos)
1. Suba o `.glb` em **Storage** → `empresas/{empresaId}/produtos/{id}.glb` → copie a URL de download.
2. Crie um doc em **Firestore** na coleção `produtos/{id}` com este shape:

```json
{
  "nome": "Poltrona Estúdio",
  "descricao": "Estrutura em madeira maciça...",
  "categoria": "Móveis",
  "empresaId": "maraca-001",
  "glbUrl": "https://firebasestorage.googleapis.com/...",
  "viewerUrl": "https://viewer.showcas3d.app/v/plt-est-01",
  "ativo": true,
  "criadoEm": "<server timestamp>",
  "sku": "PLT-EST-01",
  "cor": "Areia",
  "dimensoes": "78 × 84 × 92 cm",
  "peso": "14,2 kg",
  "materiais": "Linho, madeira",
  "preco": "R$ 2.890,00"
}
```

### Caminho B — script de seed (`scripts/seed.dart`)
Há um seed pronto em `scripts/seed.dart` que cria empresa, usuário admin e 4 produtos de exemplo. Use modelos GLB públicos do `modelviewer.dev` enquanto não tiver os definitivos.

```bash
# Precisa estar logado: flutterfire configure já fez o login
dart run scripts/seed.dart
```

### Caminho C — implementar o painel admin (próximo milestone)
Stub planejado:
- Rota `/admin` (Flutter Web, mesmo binário, protegida por `papel == admin`)
- Tela de lista + formulário com `file_picker` + upload com progresso
- Já há `papel` no `Usuario` e regras prontas para distinguir admin de vendedor

## 6. Modelo de dados

### `usuarios/{uid}`
| campo      | tipo      | obs                                    |
|------------|-----------|----------------------------------------|
| nome       | string    |                                        |
| email      | string    |                                        |
| empresaId  | string    | **chave do tenant**                    |
| papel      | string    | `"admin"` \| `"vendedor"`              |
| criadoEm   | timestamp |                                        |

### `empresas/{empresaId}`
| campo    | tipo      |
|----------|-----------|
| nome     | string    |
| cnpj     | string    |
| ativo    | bool      |
| criadoEm | timestamp |

### `produtos/{produtoId}`
| campo     | tipo      | obs                                              |
|-----------|-----------|--------------------------------------------------|
| nome      | string    | obrigatório                                      |
| descricao | string    |                                                  |
| categoria | string    | de `kCategorias` em `models/produto.dart`        |
| empresaId | string    | **multi-tenant — toda query filtra por isso**    |
| glbUrl    | string    | URL pública do .glb no Storage                   |
| viewerUrl | string    | `https://viewer.showcas3d.app/v/{produtoId}`     |
| thumbUrl  | string?   | opcional — usado no card do catálogo             |
| ativo     | bool      | catálogo só lista `ativo == true`                |
| criadoEm  | timestamp |                                                  |
| sku, cor, dimensoes, peso, materiais, preco | string? | metadados de UI |

## 7. Comportamentos obrigatórios (da spec original)

- [x] Toda query de produtos filtra por `empresaId` — _impossível ler produto de outra empresa_
- [x] `ModelViewer` exibe loading enquanto o GLB carrega
- [x] Erros de auth exibem mensagem clara em português
- [x] Página pública do viewer funciona sem login
- [x] AR ativa modo correto por plataforma (`webxr` Android / `quick-look` iOS)
- [x] QR copia o link para o clipboard automaticamente com feedback visual
- [ ] Upload de GLB com barra de progresso percentual _(parte do painel admin — pendente)_

## 8. Rotas (go_router)

| rota                          | tela              | guard                    |
|-------------------------------|-------------------|--------------------------|
| `/`                           | Splash/loading    | sempre                   |
| `/login`                      | LoginScreen       | só se deslogado          |
| `/catalogo`                   | CatalogoScreen    | só logado                |
| `/produto/:id`                | DetalheScreen     | só logado                |
| `/produto/:id/qr`             | QrScreen          | só logado                |

O redirect está em `lib/router.dart`. Quando o `authStateProvider` muda, o router refresha sozinho.

## 9. Convenções de código

- **Português no domínio.** Nomes de modelos, campos e UI ficam em pt-BR (`Produto`, `empresaId`, `ativo`). Documentação técnica e nomes internos em inglês onde fizer sentido (`AuthFailure`, `firebaseUserProvider`).
- **Riverpod manual no MVP.** Sem `riverpod_annotation` / build_runner para reduzir fricção. Se for fazer code-gen, gere TUDO de uma vez e remova os providers manuais.
- **Cores via `AppTheme`.** Não use `Color(0xFF...)` solto — adicione token novo se precisar.
- **Tipografia.** Títulos grandes usam `fontFamily: AppTheme.fontDisplay` (serif). Restante usa o default sans do sistema. Para subir nível, adicione `google_fonts` e troque por _Instrument Serif_ + _Geist_ — já está mapeado no design.
- **`flutter analyze` precisa passar.** Lints estritos em `analysis_options.yaml`.

## 10. AR — checklist por plataforma

| Plataforma | Mode usado                | Suporte                          |
|------------|---------------------------|----------------------------------|
| Android    | `scene-viewer`            | ARCore obrigatório no dispositivo |
| iOS        | `quick-look`              | Safari nativo, iOS 12+           |
| Web        | `webxr` (Android Chrome)  | Fallback: 3D rotacionável       |
| Desktop    | _AR desabilitado_         | 3D viewer funciona normalmente   |

`model_viewer_plus` resolve essas trocas automaticamente quando `arModes` está com os três valores.

## 11. Roadmap (próximas tarefas)

1. **Painel admin (web)** — rota `/admin`, upload GLB com progresso, gestão de produtos
2. **Analytics de visualização** — coleção `viewers/{id}/sessions` agregando aberturas do link público
3. **Anotações do comprador** no viewer (toques no modelo que viram comentários)
4. **Variantes** — produto com múltiplos GLB (cor/material), sem duplicar registro
5. **Onboarding do vendedor** primeira-vez com tooltip do "Compartilhar"
6. **Hospedar GLBs em CDN** com cache agressivo (Cloud CDN ou Firebase já basta no início)

## 12. Comandos úteis

```bash
flutter analyze            # lints
flutter test               # unit tests (a escrever)
flutter pub upgrade
flutter clean && flutter pub get

# Firebase
firebase deploy --only firestore:rules
firebase deploy --only storage
firebase deploy --only hosting:viewer
firebase emulators:start   # auth + firestore + storage local

# Reset auth local (útil em dev)
flutter run --dart-define=FIREBASE_AUTH_EMULATOR_HOST=localhost:9099
```

## 13. Identidade visual

Sistema definido durante o protótipo HTML — referencie o arquivo `View3D Prototype.html` (na raiz da entrega) para ver o app rodando antes de mexer no código.

- **Acentos:** coral `#E8513A`, deep `#C93F2A`, tint `#FCEBE7`
- **Neutros:** ink `#1A1815` → ink4 `#B8B3A8`, bg `#FAF9F6`
- **Tipografia:** _Instrument Serif_ (serifa italic para títulos grandes), _Geist_ ou system-ui para UI, _Geist Mono_ para SKUs/URLs
- **Cantos:** botões pílula (999px), cards 14–18px, sheets 28px
- **Tom:** editorial premium B2B — bastante respiro, fotos/3D em destaque, números monoespaçados

---

**Convenção desta doc.** Quando adicionar feature nova, atualize §3 (estrutura), §6 (dados se mudar) e §11 (roadmap). PRs sem CLAUDE.md atualizado são rebatidos.
