# CLAUDE.md — TROVATA Catálogo Digital

> **Para o Claude Code:** este é o manual operacional do app TROVATA (Catálogo Digital e Vendas B2B, Birigui-SP). Leia este arquivo inteiro antes de começar a editar. Atualize-o quando alterar arquitetura, fluxos ou dependências.

---

## 1. O que é o produto

App B2B da **TROVATA** (Birigui-SP) em três superfícies:

| Quem        | Onde                       | O que faz                                                |
|-------------|----------------------------|----------------------------------------------------------|
| Vendedor    | App Flutter (iOS + Android)| Visualiza modelos 3D do catálogo Trovata e compartilha links com compradores |
| Comprador   | Navegador (mobile/desktop) | Abre o link, gira o modelo, projeta em AR — **sem instalar nada** |
| Admin       | _Fora do MVP atual_        | Upload de modelos GLB; hoje feito via Supabase Table/Storage Editor (ver §5) |

Diferencial: **AR no navegador** via `<model-viewer>` (WebXR no Android, Quick Look no iOS) — comprador pinga o link, abre no celular, vê em tamanho real no ambiente.

## 2. Stack

- **Flutter 3.19+** — vendedor app (iOS + Android)
- **Supabase** (Postgres gerenciado, free tier real)
  - Auth (e-mail/senha)
  - Postgres (metadados de produtos/empresas/perfis com RLS multi-tenant)
  - Storage (arquivos `.glb` em bucket público)
- **model_viewer_plus** — render 3D + AR dentro do app Flutter
- **Riverpod** (sem code-gen no MVP — providers manuais; pode migrar pra `riverpod_annotation` depois)
- **go_router** — navegação
- **share_plus**, **qr_flutter**, **cached_network_image**

Viewer público (`web/viewer/`) é HTML/CSS/JS estático que consome a REST do Supabase via `@supabase/supabase-js` (CDN). Pode ser hospedado em qualquer static host (Cloudflare Pages, Vercel, GitHub Pages) ou servido localmente com `python3 -m http.server`.

## 3. Estrutura

```
view3d/
├── pubspec.yaml
├── analysis_options.yaml
├── supabase/
│   └── schema.sql               # tabelas + RLS + bucket + 4 produtos seed
├── lib/
│   ├── main.dart                # bootstrap (Supabase.initialize + ProviderScope)
│   ├── supabase_config.dart     # PLACEHOLDER — cole URL + anon key
│   ├── router.dart              # go_router com ShellRoute + redirect baseado em auth
│   ├── theme.dart               # tokens visuais (Material 3 + serif Instrument).
│   │                             # `AppTheme.ink/bg*/line*` são GETTERS que respondem
│   │                             # ao tema atual; brand colors continuam `const`.
│   ├── providers/
│   │   └── theme_mode_provider.dart # StateNotifier de ThemeMode + persistência em
│   │                                 # SharedPreferences. Sincroniza `AppTheme.setDark`.
│   ├── models/
│   │   ├── produto.dart           # fromJson/toJson (snake_case)
│   │   ├── usuario.dart           # junção auth.users + public.profiles
│   │   ├── empresa.dart
│   │   └── compartilhamento.dart  # Compartilhamento + InsightsSnapshot + TopProduto
│   ├── features/
│   │   ├── auth/
│   │   │   ├── auth_provider.dart   # supabaseClientProvider/sessionProvider/usuarioProvider/authStateProvider/controller
│   │   │   └── login_screen.dart
│   │   ├── home/
│   │   │   └── home_shell.dart      # ShellRoute container — bottom nav 4 abas
│   │   ├── catalogo/
│   │   │   ├── catalogo_provider.dart # produtosProvider via supabase.stream + filtro
│   │   │   └── catalogo_screen.dart
│   │   ├── compartilhados/
│   │   │   ├── compartilhados_provider.dart   # MOCK — TODO: select da tabela compartilhamentos
│   │   │   └── compartilhados_screen.dart
│   │   ├── insights/
│   │   │   ├── insights_provider.dart         # MOCK snapshot — TODO: view/RPC no Postgres
│   │   │   └── insights_screen.dart
│   │   ├── conta/
│   │   │   └── conta_screen.dart    # perfil + preferências + sair
│   │   └── produto/
│   │       ├── detalhe_screen.dart  # ModelViewer + ações
│   │       ├── qr_screen.dart       # QR + copia link automático
│   │       └── share_sheet.dart     # bottom sheet de compartilhamento
│   └── shared/
│       └── widgets/
│           ├── loading_widget.dart
│           └── app_error_widget.dart
├── web/
│   └── viewer/                  # página pública estática (Supabase JS via CDN)
│       ├── index.html
│       ├── viewer.css
│       └── viewer.js            # lê produtos via supabase-js, popula <model-viewer>
└── scripts/
    └── seed.mjs                 # opcional — adiciona produtos extras via REST + service_role
```

## 4. Setup inicial — passo a passo

### 4.1. Pré-requisitos
- Flutter 3.19+ (`flutter --version`)
- Node 18+ (apenas para `scripts/seed.mjs` opcional)
- Conta gratuita no [supabase.com](https://supabase.com)

### 4.2. Clonar e baixar deps
```bash
git clone https://github.com/Lourencohn/view3d.git
cd view3d
flutter pub get
```

### 4.3. Gerar a estrutura nativa (primeira vez)
O `.zip` desta entrega **não inclui as pastas `android/` e `ios/`** — gere com:

```bash
flutter create . \
  --org br.com.trovata \
  --project-name view3d \
  --platforms=android,ios \
  --description "TROVATA — Catálogo Digital e Vendas B2B"
```

Já há ajustes aplicados em `android/app/src/main/AndroidManifest.xml` (INTERNET + CAMERA + queries) e `ios/Runner/Info.plist` (Camera/Photo descriptions + LSApplicationQueriesSchemes). Se rodar `flutter create` numa árvore limpa, reaplique os mesmos diffs (ver histórico do git).

### 4.4. Configurar Supabase
1. Crie um projeto em [supabase.com](https://supabase.com) (free tier).
2. **SQL Editor → New query** → cole `supabase/schema.sql` inteiro → **Run**.
   - Cria as tabelas, RLS, bucket Storage `produtos`, trigger de profile e 4 produtos de exemplo.
3. **Settings → API** → copie para `lib/supabase_config.dart`:
   - `Project URL` → `SupabaseConfig.url`
   - `anon public` (NÃO a `service_role`) → `SupabaseConfig.anonKey`
4. Cole as MESMAS duas strings em `web/viewer/viewer.js` (constantes `SUPABASE_URL` e `SUPABASE_ANON_KEY`).
5. **Authentication → Settings** → desligue *"Confirm email"* (acelera dev).
6. **Authentication → Users → Add user** → crie um vendedor (`vendedor@trovata.com.br` + senha).
   - O trigger `on_auth_user_created` cria automaticamente o `profiles` com `empresa_id='trovata-birigui'` e `papel='vendedor'`.
   - Se quiser promover a admin: SQL Editor → `update public.profiles set papel='admin' where email='vendedor@trovata.com.br';`

### 4.5. Rodar
```bash
flutter run        # device conectado
flutter run -d ios
flutter run -d android
```

### 4.6. Rodar o viewer público localmente
```bash
cd web
python3 -m http.server 8000
# Abra: http://localhost:8000/viewer/?id=plt-est-01
```

Para produção: jogue `web/viewer/` em Cloudflare Pages, Vercel ou GitHub Pages (qualquer static host).

## 5. Como popular o catálogo (sem painel admin)

O MVP **não** tem painel administrativo. Três caminhos:

### Caminho A — Supabase Table Editor (web, manual)
1. **Storage** → bucket `produtos` → **Upload file** → suba seu `.glb` → copie a URL pública.
2. **Table Editor** → tabela `produtos` → **Insert row** com:
   - `id`: slug único (ex `plt-est-03`)
   - `nome`, `descricao`, `categoria`
   - `empresa_id`: `trovata-birigui` (ou outra que você criou em `empresas`)
   - `glb_url`: URL do passo 1
   - `viewer_url`: `http://localhost:8000/viewer/?id=<id>` (dev) ou a URL real em produção
   - `ativo`: `true`
   - opcionais: `sku`, `cor`, `dimensoes`, `peso`, `materiais`, `preco`, `thumb_url`

### Caminho B — re-rodar `supabase/schema.sql`
Os `INSERT ... ON CONFLICT DO NOTHING` no fim do arquivo são idempotentes. Edite a lista de produtos e rode no SQL Editor de novo.

### Caminho C — `scripts/seed.mjs` (bulk via REST)
```bash
export SUPABASE_URL='https://xxxx.supabase.co'
export SUPABASE_SERVICE_KEY='eyJ...'    # Settings → API → service_role (NUNCA commitar)
node scripts/seed.mjs
```

### Caminho D — implementar painel admin (próximo milestone)
- Rota `/admin` (Flutter Web, protegida por `papel == 'admin'`)
- Upload via `supabase.storage.from('produtos').uploadBinary(...)` com progresso
- Já há `papel` no `Usuario` e RLS pronta para distinguir admin de vendedor

## 6. Modelo de dados

> **Convenção:** colunas em `snake_case` no Postgres, campos em `camelCase` no Dart. O mapeamento vive em `fromJson`/`toJson` de cada model.

### `public.profiles` (chave: id linkada a `auth.users.id`)
| coluna      | tipo          | obs                                   |
|-------------|---------------|---------------------------------------|
| id          | uuid PK FK    | `references auth.users(id)`           |
| nome        | text          |                                       |
| email       | text          |                                       |
| empresa_id  | text NOT NULL | **chave do tenant**                   |
| papel       | text NOT NULL | `'admin'` \| `'vendedor'`             |
| criado_em   | timestamptz   | default now()                         |

### `public.empresas`
| coluna     | tipo          |
|------------|---------------|
| id         | text PK       |
| nome       | text NOT NULL |
| cnpj       | text          |
| ativo      | bool          |
| criado_em  | timestamptz   |

### `public.produtos`
| coluna     | tipo          | obs                                              |
|------------|---------------|--------------------------------------------------|
| id         | text PK       | slug (ex `plt-est-01`)                           |
| nome       | text NOT NULL |                                                  |
| descricao  | text          |                                                  |
| categoria  | text          | uma de `kCategorias` (`lib/models/produto.dart`) |
| empresa_id | text NOT NULL | **multi-tenant — RLS força filtro**              |
| glb_url    | text NOT NULL | URL pública do .glb                              |
| viewer_url | text          | `https://catalogo.trovata.com.br/?id={id}`       |
| thumb_url  | text          | opcional — usado no card do catálogo             |
| ativo      | bool          | catálogo só lista `ativo = true`                 |
| criado_em  | timestamptz   |                                                  |
| sku, cor, dimensoes, peso, materiais, preco | text | metadados de UI |

### `public.compartilhamentos` (existe, mas a tela ainda usa mock)
| coluna        | tipo          |
|---------------|---------------|
| id            | uuid PK       |
| produto_id    | text FK       |
| empresa_id    | text          |
| uid           | uuid FK       |
| canal         | text          |
| comprador     | text          |
| contato       | text          |
| data_hora     | timestamptz   |
| views         | int           |
| ar_sessions   | int           |
| ultimo_acesso | timestamptz   |

### RLS resumida
- `profiles`: usuário só lê/atualiza o próprio (`auth.uid() = id`)
- `empresas`: usuário lê só a empresa do próprio perfil
- `produtos`: **read público** (viewer sem login funciona); write só por admin da mesma empresa
- `compartilhamentos`: vendedor lê/insere apenas os próprios

## 7. Comportamentos obrigatórios

- [x] Toda query de produtos filtra por `empresa_id` (RLS + filtro explícito)
- [x] `ModelViewer` exibe loading enquanto o GLB carrega
- [x] Erros de auth exibem mensagem clara em português (`AuthFailure.fromMessage`)
- [x] Página pública do viewer funciona sem login (RLS read público em `produtos`)
- [x] AR ativa modo correto por plataforma (`webxr` Android / `quick-look` iOS)
- [x] QR copia o link para o clipboard automaticamente com feedback visual
- [x] Modo escuro toggle em `Conta` → `themeModeProvider` persiste em SharedPreferences
- [x] Cards do Catálogo renderizam o GLB inline (auto-rotate, sem interação)
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

`HomeShell` (em `features/home/home_shell.dart`) é um `ShellRoute` do go_router que renderiza a bottom nav persistente. O redirect global (`appRouterProvider`) observa o `authStateProvider` e refresha quando o estado muda.

## 9. Convenções de código

- **Português no domínio.** Nomes de classes Dart e UI em pt-BR (`Produto`, `empresaId`, `ativo`). Colunas Postgres em snake_case (`empresa_id`, `criado_em`). Documentação técnica em inglês onde fizer sentido (`AuthFailure`, `supabaseClientProvider`).
- **Riverpod manual no MVP.** Sem `riverpod_annotation` / build_runner.
- **`AppAuthState`** (sealed) é o estado consolidado de auth — NÃO confundir com `AuthState` do `supabase_flutter` (evento de auth change).
- **Cores via `AppTheme`.** Não use `Color(0xFF...)` solto.
- **Tipografia.** Títulos grandes usam `AppTheme.fontDisplay` (serif).
- **`flutter analyze` precisa passar.** Lints estritos em `analysis_options.yaml`.
- **Código sem comentários.** Nada de `///` (dartdoc), `/* */` (blocos) ou `//` de linha — incluindo "headers" curtos como `// Header`, `// Stats grid`, divisórias `// ─────`, `// TODO`, e descrições de seção. Nomes claros e código óbvio substituem o comentário. Exceções aceitas SOMENTE quando o motivo não é deduzível do código (constraint oculta, workaround específico de bug, invariante sutil) — neste caso, uma única linha curta. Para tudo o mais, prefira o nome certo, uma função extraída, ou nada.

## 10. AR — checklist por plataforma

| Plataforma | Mode usado                | Suporte                          |
|------------|---------------------------|----------------------------------|
| Android    | `scene-viewer`            | ARCore obrigatório no dispositivo |
| iOS        | `quick-look`              | Safari nativo, iOS 12+           |
| Web        | `webxr` (Android Chrome)  | Fallback: 3D rotacionável       |
| Desktop    | _AR desabilitado_         | 3D viewer funciona normalmente   |

## 11. Roadmap (próximas tarefas)

1. **Compartilhamentos reais** — trocar mock em `compartilhados_provider.dart` por `select` da tabela `compartilhamentos`. Disparar `insert` em `ShareSheet`/`QrScreen` quando vendedor compartilhar.
2. **Insights via Postgres** — view materializada ou função RPC que agrega `compartilhamentos` por empresa e janela de 7 dias. Substituir mock em `insights_provider.dart`.
3. **Analytics do viewer público** — `web/viewer/viewer.js` insere em `viewer_events` (RLS append-only via anon role).
4. **Painel admin (web)** — rota `/admin`, upload GLB com progresso (`uploadBinary` + listener), gestão de produtos.
5. ~~**Modo escuro persistido** — `themeModeProvider` (SharedPreferences) + wire no toggle do `ContaScreen`.~~ ✅ Feito (2026-05).
6. **Deep links** universais — `applinks` (iOS) + `App Links` (Android) pra abrir `/produto/:id` direto.
7. **Variantes** — produto com múltiplos GLB (cor/material).
8. **Hospedar viewer** em domínio próprio (`catalogo.trovata.com.br`) via Cloudflare Pages.

## 12. Tabelas Postgres — futuras

```
viewer_events (append-only, base para agregação)
  - id            uuid PK
  - produto_id    text
  - empresa_id    text
  - tipo          text  ('view' | 'ar' | 'click')
  - user_agent    text
  - referer       text
  - criado_em     timestamptz

insights_snapshot (materialized view atualizada via cron pg)
  - empresa_id    text PK
  - gerado_em     timestamptz
  - views_7d      int
  - views_7d_delta double precision
  - unique_buyers int
  - ...
```

## 13. Comandos úteis

```bash
# Flutter
flutter analyze
flutter test
flutter pub upgrade
flutter clean && flutter pub get
flutter run -d ios | android

# Viewer público local
cd web && python3 -m http.server 8000
# → http://localhost:8000/viewer/?id=<produto_id>

# Seed extra (precisa service_role no env)
node scripts/seed.mjs
```

## 14. Identidade visual

Sistema baseado na **marca TROVATA** (Birigui-SP). Veja `prototype/TROVATA Prototype.html` na raiz pra ter referência visual antes de mexer no código.

- **Azul TROVATA:** `#1976D2` accent · `#1565C0` deep · `#E3F2FD` tint — primário, CTAs, links, foco
- **Vermelho TROVATA:** `#D32F2F` accent · `#B71C1C` deep · `#FFEBEE` tint — marca secundária, alertas (uso parcimonioso)
- **Verde TROVATA:** `#2E7D32` · `#E8F5E9` tint — sucesso, deltas positivos
- **Neutros frios:** `#0F172A` ink, `#334155` ink-2, `#64748B` ink-3, `#94A3B8` ink-4
- **Backgrounds:** `#FBFCFE` app, `#FFFFFF` cards, `#F1F5F9` muted, `#E8EEF5` stage
- **Linhas:** `#E2E8F0` line, `#CBD5E1` line-strong
- **Tipografia:** _Instrument Serif_ (italic para títulos grandes), _Geist_ / system-ui (UI), _Geist Mono_ / monospace para SKUs/URLs
- **Cantos:** botões pílula (999px), cards 14–18px, sheets 28px
- **Logo:** `assets/images/trovata-logo.png` (260×65px). No app: `Image.asset` com `width: 260`. Na web: `<img src="trovata-logo.png">` com `height: 36px`.
- **Tom:** corporate B2B com toque editorial — bastante respiro, 3D em destaque, números monoespaçados, serifa nos heroes.

---

**Convenção desta doc.** Quando adicionar feature nova, atualize §3 (estrutura), §6 (dados se mudar) e §11 (roadmap). PRs sem CLAUDE.md atualizado são rebatidos.
