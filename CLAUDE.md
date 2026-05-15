# CLAUDE.md — TROVATA Catálogo Digital

> **Para o Claude Code:** este é o manual operacional do app TROVATA (Catálogo Digital e Vendas B2B, Birigui-SP). Leia este arquivo inteiro antes de começar a editar. Atualize-o quando alterar arquitetura, fluxos ou dependências.

---

## 1. O que é o produto

App B2B da **TROVATA** (Birigui-SP) em três superfícies:

| Quem        | Onde                       | O que faz                                                |
|-------------|----------------------------|----------------------------------------------------------|
| Vendedor    | App Flutter (iOS + Android)| Visualiza modelos 3D do catálogo Trovata e compartilha links com compradores |
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
│   ├── router.dart              # go_router com ShellRoute + redirect baseado em auth
│   ├── theme.dart               # tokens visuais (Material 3 + serif Instrument)
│   ├── models/
│   │   ├── produto.dart
│   │   ├── usuario.dart
│   │   ├── empresa.dart
│   │   └── compartilhamento.dart  # Share + InsightsSnapshot + TopProduto
│   ├── features/
│   │   ├── auth/
│   │   │   ├── auth_provider.dart    # firebaseAuth/firestore/usuario/authState/controller
│   │   │   └── login_screen.dart
│   │   ├── home/
│   │   │   └── home_shell.dart       # ShellRoute container — bottom nav 4 abas
│   │   ├── catalogo/
│   │   │   ├── catalogo_provider.dart # produtosProvider + filtro
│   │   │   └── catalogo_screen.dart
│   │   ├── compartilhados/
│   │   │   ├── compartilhados_provider.dart   # MOCK por enquanto — TODO Firestore
│   │   │   └── compartilhados_screen.dart     # lista agrupada por dia + filtros
│   │   ├── insights/
│   │   │   ├── insights_provider.dart         # MOCK snapshot — TODO Cloud Function
│   │   │   └── insights_screen.dart           # hero + stat tiles + top produtos + canais
│   │   ├── conta/
│   │   │   └── conta_screen.dart              # perfil + preferências + sair
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
# Substitua o org pelo bundle ID definitivo (br.com.trovata.view3d)
flutter create . \
  --org br.com.trovata \
  --project-name view3d \
  --platforms=android,ios \
  --description "TROVATA — Catálogo Digital e Vendas B2B"
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
Configure o domínio custom (`catalogo.trovata.com.br`) no console — ou use o `*.web.app` padrão e atualize `viewerUrl` na criação de produtos (§5).

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
  "empresaId": "trovata-birigui",
  "glbUrl": "https://firebasestorage.googleapis.com/...",
  "viewerUrl": "https://catalogo.trovata.com.br/v/plt-est-01",
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
| viewerUrl | string    | `https://catalogo.trovata.com.br/v/{produtoId}`  |
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

| rota                          | tela                  | shell    | guard           |
|-------------------------------|-----------------------|----------|-----------------|
| `/`                           | Splash/loading        | —        | sempre          |
| `/login`                      | LoginScreen           | —        | só deslogado    |
| `/catalogo`                   | CatalogoScreen        | HomeShell| só logado       |
| `/compartilhados`             | CompartilhadosScreen  | HomeShell| só logado       |
| `/insights`                   | InsightsScreen        | HomeShell| só logado       |
| `/conta`                      | ContaScreen           | HomeShell| só logado       |
| `/produto/:id`                | DetalheScreen         | —        | só logado       |
| `/produto/:id/qr`             | QrScreen              | —        | só logado       |

`HomeShell` (em `features/home/home_shell.dart`) é um `ShellRoute` do go_router que renderiza a bottom nav persistente — a aba ativa é derivada da URL via `GoRouterState.of(context).matchedLocation`, ou seja, deep link em qualquer aba funciona. Telas `produto/...` ficam fora do shell para liberar a tela inteira.

O redirect global (`appRouterProvider`) observa o `authStateProvider` e refresha quando o estado muda.

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

1. **Compartilhamentos reais no Firestore** — trocar mock em `compartilhados_provider.dart` por stream da coleção `compartilhamentos/{id}`. Criar evento "share" no `ShareSheet`/`QrScreen` que grava o doc.
2. **Cloud Function de Insights** — agregar diariamente em `insights/{empresaId}` (Cloud Scheduler + Firestore Trigger). Substituir mock em `insights_provider.dart`.
3. **Analytics do viewer público** — rastrear `views` e `arSessions` no `web/viewer/viewer.js` (write em `viewer_events/{id}`), agregar pela Function.
4. **Painel admin (web)** — rota `/admin`, upload GLB com progresso, gestão de produtos. Já há `papel` no `Usuario` e regras prontas.
5. **Modo escuro persistido** — `themeModeProvider` (SharedPreferences) + wire no toggle do `ContaScreen`.
6. **Anotações do comprador** no viewer (toques no modelo que viram comentários).
7. **Variantes** — produto com múltiplos GLB (cor/material), sem duplicar registro.
8. **Onboarding** primeira-vez com tooltip do "Compartilhar".

## 12. Coleções Firestore — futuras

Quando implementar §11.1–§11.3:

```
compartilhamentos/{id}
  - produtoId: string
  - empresaId: string
  - uid: string         // vendedor
  - canal: string       // whatsapp | email | qr | link | sistema
  - comprador: string?  // nome
  - contato: string?    // telefone, email, etc
  - dataHora: timestamp
  - views: int          // contagem agregada
  - arSessions: int
  - ultimoAcesso: timestamp?

insights/{empresaId}
  - geradoEm: timestamp
  - views7d: int
  - views7dDelta: double
  - uniqueBuyers: int
  - ...                 // ver InsightsSnapshot em models/compartilhamento.dart

viewer_events/{id}      // append-only — base para agregação
  - produtoId: string
  - empresaId: string
  - tipo: 'view' | 'ar' | 'click'
  - timestamp: timestamp
  - userAgent: string
  - referer: string?
```

## 13. Comandos úteis

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

## 14. Identidade visual

Sistema baseado na **marca TROVATA** (Birigui-SP). Referencie o `TROVATA Prototype.html` na raiz da entrega para ver o app rodando antes de mexer no código.

- **Azul TROVATA:** `#1976D2` accent · `#1565C0` deep · `#E3F2FD` tint — primário, CTAs, links, foco
- **Vermelho TROVATA:** `#D32F2F` accent · `#B71C1C` deep · `#FFEBEE` tint — marca secundária, alertas (uso parcimonioso)
- **Verde TROVATA:** `#2E7D32` · `#E8F5E9` tint — sucesso, deltas positivos
- **Neutros frios:** `#0F172A` ink, `#334155` ink-2, `#64748B` ink-3, `#94A3B8` ink-4
- **Backgrounds:** `#FBFCFE` app, `#FFFFFF` cards, `#F1F5F9` muted, `#E8EEF5` stage
- **Linhas:** `#E2E8F0` line, `#CBD5E1` line-strong
- **Tipografia:** _Instrument Serif_ (italic para títulos grandes), _Geist_ / system-ui (UI), _Geist Mono_ / monospace para SKUs/URLs
- **Cantos:** botões pílula (999px), cards 14–18px, sheets 28px
- **Logo:** `assets/images/trovata-logo.png` (260×65px, PNG transparente) — no app usar `Image.asset` com `width: 260`. Na web (`web/viewer/`) usar `<img src="trovata-logo.png">` com `height: 36px`.
- **Tom:** corporate B2B com toque editorial — bastante respiro, 3D em destaque, números monoespaçados, serifa nos heroes.

---

**Convenção desta doc.** Quando adicionar feature nova, atualize §3 (estrutura), §6 (dados se mudar) e §11 (roadmap). PRs sem CLAUDE.md atualizado são rebatidos.
