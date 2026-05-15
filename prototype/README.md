# Protótipo — TROVATA Catálogo Digital

HTML/React standalone que mostra o app inteiro rodando (4 abas + página pública lado a lado). Serve de referência visual antes/durante a implementação Flutter.

## Como abrir

```bash
# qualquer servidor estático funciona — não pode abrir via file://
# porque o <model-viewer> usa módulos ES.

# Opção 1 (Python, já vem no Mac/Linux):
cd prototype
python3 -m http.server 8000
# abre http://localhost:8000/TROVATA%20Prototype.html

# Opção 2 (Node):
npx http-server prototype -p 8000

# Opção 3 (VSCode):
# instale a extensão "Live Server", abra a pasta e clique em "Go Live"
```

## O que tem dentro

| Arquivo                  | Função                                                 |
|--------------------------|--------------------------------------------------------|
| `TROVATA Prototype.html` | entrada — carrega React + Babel + scripts             |
| `styles.css`             | tokens visuais (cores Trovata, tipografia, espaçamento) |
| `data.js`                | mock de produtos, USER, SHARES, INSIGHTS              |
| `icons.jsx`              | biblioteca de ícones SVG                              |
| `vendor-app.jsx`         | telas Login, Catálogo, Detalhe, QR, ShareSheet        |
| `tab-screens.jsx`        | telas Compartilhados, Insights, Conta                 |
| `public-viewer.jsx`      | a página pública (o que o comprador vê)               |
| `app.jsx`                | composição top-level + Tweaks                         |
| `ios-frame.jsx` etc.     | starter components (iPhone, navegador, etc.)          |

## Tweaks (canto inferior direito)

- Paleta (azul Trovata / vermelho / verde / mono)
- Modo escuro
- Layout do catálogo (grid / lista)
- Produto exibido na página pública

## Mapa para o Flutter

Cada tela do protótipo tem equivalente em `lib/features/`:

```
LoginScreen           ↔  lib/features/auth/login_screen.dart
CatalogoScreen        ↔  lib/features/catalogo/catalogo_screen.dart
DetalheScreen         ↔  lib/features/produto/detalhe_screen.dart
QRScreen              ↔  lib/features/produto/qr_screen.dart
ShareSheet            ↔  lib/features/produto/share_sheet.dart
CompartilhadosScreen  ↔  lib/features/compartilhados/compartilhados_screen.dart
InsightsScreen        ↔  lib/features/insights/insights_screen.dart
ContaScreen           ↔  lib/features/conta/conta_screen.dart
PublicViewer          ↔  web/viewer/index.html + viewer.css + viewer.js
```
