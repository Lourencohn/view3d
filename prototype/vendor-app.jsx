// vendor-app.jsx — The Flutter app shown inside the iPhone frame.
// Internal state machine: login → catalogo → detalhe → (share | qr)

// ─────────────────────────────────────────────
// ModelViewerEmbed — small wrapper around <model-viewer>
// ─────────────────────────────────────────────
function ModelViewerEmbed({ src, ar = true, alt, poster, exposure = 1, scale }) {
  const ref = React.useRef(null);
  const [progress, setProgress] = React.useState(0);
  const [done, setDone] = React.useState(false);

  React.useEffect(() => {
    const el = ref.current;
    if (!el) return;
    setProgress(0); setDone(false);
    const onProgress = (e) => {
      const p = (e.detail.totalProgress ?? 0) * 100;
      setProgress(p);
      if (p >= 99.9) setDone(true);
    };
    const onLoad = () => { setDone(true); setProgress(100); };
    el.addEventListener('progress', onProgress);
    el.addEventListener('load', onLoad);
    return () => {
      el.removeEventListener('progress', onProgress);
      el.removeEventListener('load', onLoad);
    };
  }, [src]);

  return (
    <>
      <model-viewer
        ref={ref}
        src={src}
        alt={alt || 'modelo 3d'}
        camera-controls=""
        auto-rotate=""
        rotation-per-second="14deg"
        interaction-prompt="none"
        shadow-intensity="1.1"
        shadow-softness="0.7"
        exposure={exposure}
        ar={ar ? '' : null}
        ar-modes="webxr scene-viewer quick-look"
        loading="eager"
        reveal="auto"
        style={{ width: '100%', height: '100%', '--poster-color': 'transparent' }}
      />
      {!done && (
        <div className="loading-wrap">
          <div className="spinner"/>
          <span>Carregando modelo</span>
        </div>
      )}
      <div className={`progress-shell ${done ? 'done' : ''}`}>
        <div className="bar" style={{ width: `${progress}%` }}/>
      </div>
    </>
  );
}

// ─────────────────────────────────────────────
// Tabbar
// ─────────────────────────────────────────────
function TabBar({ active = 'catalog', onGo }) {
  const items = [
    { id: 'catalog', label: 'Catálogo', icon: <IconHome size={22}/> },
    { id: 'shared',  label: 'Compartilhados', icon: <IconShare size={22}/> },
    { id: 'insights',label: 'Insights', icon: <IconChart size={22}/> },
    { id: 'me',      label: 'Conta', icon: <IconUser size={22}/> },
  ];
  return (
    <div className="tabbar">
      {items.map(it => (
        <button key={it.id}
                className="tab-item"
                data-on={active === it.id ? '1' : '0'}
                onClick={() => onGo && onGo(it.id)}>
          {it.icon}
          <span>{it.label}</span>
        </button>
      ))}
    </div>
  );
}

// ─────────────────────────────────────────────
// Login
// ─────────────────────────────────────────────
function LoginScreen({ onLogin }) {
  const [email, setEmail] = React.useState(USER.email);
  const [pwd, setPwd] = React.useState('••••••••••');
  return (
    <div className="login">
      <div className="login-hero">
        <img src="trovata-logo.png" alt="TROVATA"
             style={{
               width: 280, maxWidth: '90%',
               height: 'auto', display: 'block',
             }}/>
        <div className="login-tag" style={{ marginTop: 24 }}>
          <b>Catálogo digital e vendas B2B.</b><br/>
          Compartilhe modelos 3D interativos com qualquer comprador, em qualquer lugar — sem instalar app.
        </div>
      </div>

      <form className="login-form" onSubmit={(e) => { e.preventDefault(); onLogin(); }}>
        <div className="field">
          <label className="field-label">E-mail corporativo</label>
          <input className="input" type="email" value={email}
                 onChange={(e) => setEmail(e.target.value)}
                 autoComplete="email"/>
        </div>
        <div className="field">
          <label className="field-label">Senha</label>
          <input className="input" type="password" value={pwd}
                 onChange={(e) => setPwd(e.target.value)}
                 autoComplete="current-password"/>
        </div>

        <button type="submit" className="btn btn-primary btn-block btn-lg">
          Entrar
          <IconChevron size={16}/>
        </button>

        <div className="login-meta">
          Esqueci a senha · <a href="#">Acessar via SSO</a>
        </div>
      </form>
    </div>
  );
}

// ─────────────────────────────────────────────
// Catálogo
// ─────────────────────────────────────────────
function ProductThumb({ p }) {
  // simple stylized thumb — soft radial bg with the product silhouette text
  return (
    <div className="cat-thumb" style={{
      background: `radial-gradient(circle at 50% 45%, #ffffff 0%, ${p.accent}22 70%, ${p.accent}66 100%)`,
    }}>
      <div style={{
        fontFamily: 'var(--font-display)',
        fontStyle: 'italic',
        fontSize: 40,
        lineHeight: 1,
        color: 'rgba(26,24,21,0.22)',
        letterSpacing: '-0.02em',
        textAlign: 'center',
      }}>
        {p.nome.split(' ').slice(0, 2).join(' ')}
      </div>
      <div className="pill-3d">3D · AR</div>
    </div>
  );
}

function CatalogoScreen({ layout = 'grid', onOpen, onGo }) {
  const [cat, setCat] = React.useState('Todos');
  const filtered = cat === 'Todos' ? PRODUCTS : PRODUCTS.filter(p => p.categoria === cat);

  return (
    <div className="app-scroll">
      <div className="topbar-pad"/>
      <div className="cat-header">
        <div className="cat-eyebrow">TROVATA · {USER.cidade}</div>
        <h1 className="cat-title">Catálogo <em>digital</em></h1>
        <div style={{ fontSize: 13, color: 'var(--ink-3)', marginTop: 4 }}>
          {PRODUCTS.length} produtos · atualizado há 2h
        </div>
      </div>

      <div className="cat-filters">
        {CATEGORIAS.map(c => (
          <button key={c} className="cat-chip" data-on={c === cat ? '1' : '0'}
                  onClick={() => setCat(c)}>
            {c}
          </button>
        ))}
      </div>

      {layout === 'grid' ? (
        <div className="cat-grid">
          {filtered.map(p => (
            <div key={p.id} className="cat-card" onClick={() => onOpen(p)}>
              <ProductThumb p={p}/>
              <div className="cat-meta">
                <div className="cat-name">{p.nome}</div>
                <div className="cat-cat">{p.categoria}</div>
                <div className="cat-sku">{p.sku}</div>
              </div>
            </div>
          ))}
        </div>
      ) : (
        <div className="cat-list">
          {filtered.map(p => (
            <div key={p.id} className="cat-row" onClick={() => onOpen(p)}>
              <div className="thumb-sm" style={{
                background: `radial-gradient(circle at 50% 50%, #fff 0%, ${p.accent}55 100%)`,
              }}>
                <div style={{
                  fontFamily: 'var(--font-display)',
                  fontStyle: 'italic',
                  fontSize: 22,
                  color: 'rgba(26,24,21,0.4)',
                }}>{p.nome[0]}</div>
              </div>
              <div className="meta">
                <div className="name">{p.nome}</div>
                <div className="sub">
                  <span>{p.categoria}</span>
                  <span className="dot"/>
                  <span style={{ fontFamily: 'var(--font-mono)', fontSize: 11 }}>{p.sku}</span>
                </div>
              </div>
              <IconChevron size={16} style={{ color: 'var(--ink-4)' }}/>
            </div>
          ))}
        </div>
      )}

      <TabBar active="catalog" onGo={onGo}/>
    </div>
  );
}

// ─────────────────────────────────────────────
// Detalhe
// ─────────────────────────────────────────────
function DetalheScreen({ product, onBack, onShare, onQR, onAR }) {
  return (
    <div className="app-scroll" style={{ position: 'relative' }}>
      <div className="topbar-pad"/>

      <div className="detail-nav">
        <button className="icon-btn" onClick={onBack} aria-label="Voltar">
          <IconBack size={20}/>
        </button>
        <div className="icon-btn-row">
          <button className="icon-btn" aria-label="Favoritar"><IconHeart size={18}/></button>
          <button className="icon-btn" aria-label="Mais"><IconMore size={18}/></button>
        </div>
      </div>

      <div className="viewer-stage" style={{ height: 420 }}>
        <div className="viewer-chip left">
          <IconRotate size={11} style={{ marginRight: 4, verticalAlign: -1, display: 'inline' }}/>
          Toque e arraste
        </div>
        <div className="viewer-chip right">{product.sku}</div>
        <ModelViewerEmbed src={product.glbUrl} ar alt={product.nome}/>
        <button className="ar-fab" onClick={onAR}>
          <IconAR size={18}/>
          Ver em AR
        </button>
      </div>

      <div className="detail-info">
        <div className="detail-cat">{product.categoria} · {product.cor}</div>
        <h1 className="detail-title">{product.nome}</h1>
        <div className="detail-desc">{product.descricao}</div>

        <div className="detail-specs">
          <div><span className="k">Dimensões</span><span className="v">{product.dimensoes}</span></div>
          <div><span className="k">Peso</span><span className="v">{product.peso}</span></div>
          <div><span className="k">Material</span><span className="v">{product.materiais}</span></div>
          <div><span className="k">Preço atacado</span><span className="v" style={{ color: 'var(--accent)' }}>{product.preco}</span></div>
        </div>

        <div style={{
          display: 'flex', alignItems: 'center', gap: 10,
          padding: '12px 14px', background: 'var(--bg-muted)',
          borderRadius: 12, marginTop: 4,
        }}>
          <IconEye size={16} style={{ color: 'var(--ink-3)' }}/>
          <div style={{ flex: 1, fontSize: 12, color: 'var(--ink-2)' }}>
            <b style={{ color: 'var(--ink)', fontWeight: 500 }}>23 compradores</b> visualizaram este link nas últimas 24h
          </div>
        </div>

        {/* leave space for sticky actions */}
        <div style={{ height: 80 }}/>
      </div>

      <div className="detail-actions">
        <button className="btn btn-ghost" onClick={onQR}>
          <IconQR size={18}/>
          QR Code
        </button>
        <button className="btn btn-accent" onClick={onShare}>
          <IconShare size={18}/>
          Compartilhar
        </button>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────
// QR Code screen
// ─────────────────────────────────────────────
function QRScreen({ product, onBack, onShare, showToast }) {
  const viewerUrl = `${VIEWER_BASE}${product.id}`;
  const short = `catalogo.trovata.com.br/v/${product.id}`;

  return (
    <div className="app-scroll" style={{ position: 'relative' }}>
      <div className="topbar-pad"/>

      <div className="detail-nav">
        <button className="icon-btn" onClick={onBack} aria-label="Voltar">
          <IconBack size={20}/>
        </button>
        <div className="icon-btn-row">
          <button className="icon-btn" onClick={() => {
            navigator.clipboard && navigator.clipboard.writeText(viewerUrl).catch(()=>{});
            showToast('Link copiado');
          }} aria-label="Copiar"><IconCopy size={18}/></button>
        </div>
      </div>

      <div className="qr-screen">
        <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
          <div className="qr-tag">QR · Aponte a câmera</div>
          <div style={{
            fontFamily: 'var(--font-display)', fontSize: 30, lineHeight: 1,
            color: 'var(--ink)', letterSpacing: '-0.015em',
          }}>
            {product.nome}
          </div>
        </div>

        <div className="qr-card">
          <div style={{
            display: 'flex', justifyContent: 'space-between', width: '100%',
            alignItems: 'center',
          }}>
            <img src="trovata-logo.png" alt="TROVATA"
                 style={{ height: 22, width: 'auto', display: 'block' }}/>
            <div style={{
              fontFamily: 'var(--font-mono)', fontSize: 10,
              color: 'var(--ink-3)',
            }}>{product.sku}</div>
          </div>

          <div className="qr-img">
            <QRCode value={viewerUrl} size={216}/>
          </div>

          <div className="qr-foot">
            <div style={{ fontSize: 13, color: 'var(--ink-2)', fontWeight: 500 }}>
              {product.categoria} · {product.cor}
            </div>
            <div className="url">{short}</div>
          </div>
        </div>

        <button className="btn btn-accent btn-block btn-lg" onClick={onShare}>
          <IconShare size={18}/>
          Compartilhar link
        </button>

        <div style={{
          fontSize: 12, color: 'var(--ink-3)', textAlign: 'center',
          lineHeight: 1.5, padding: '0 20px',
        }}>
          Funciona em iOS, Android e desktop. Sem instalar app.
        </div>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────
// Share sheet (bottom sheet)
// ─────────────────────────────────────────────
function ShareSheet({ product, onClose, onCopied }) {
  const viewerUrl = `${VIEWER_BASE}${product.id}`;
  const short = viewerUrl.replace(/^https?:\/\//, '');

  const copy = () => {
    navigator.clipboard && navigator.clipboard.writeText(viewerUrl).catch(()=>{});
    onCopied && onCopied();
    setTimeout(onClose, 300);
  };

  return (
    <>
      <div className="sheet-scrim" onClick={onClose}/>
      <div className="sheet">
        <div className="sheet-handle"/>
        <div style={{
          display: 'flex', alignItems: 'center', gap: 12, padding: '4px 8px 14px',
        }}>
          <div style={{
            width: 44, height: 44, borderRadius: 12,
            background: `radial-gradient(circle at 50% 50%, #fff, ${product.accent}55)`,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontFamily: 'var(--font-display)', fontSize: 22,
            color: 'rgba(26,24,21,0.45)', fontStyle: 'italic',
          }}>{product.nome[0]}</div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 15, fontWeight: 500, letterSpacing: '-0.01em' }}>
              Compartilhar {product.nome}
            </div>
            <div style={{ fontSize: 12, color: 'var(--ink-3)' }}>
              Comprador acessa pelo navegador, sem app
            </div>
          </div>
        </div>

        <div className="link-row">
          <IconLink size={16} style={{ color: 'var(--ink-3)' }}/>
          <div className="link-url">{short}</div>
          <button className="copy-btn" onClick={copy}>Copiar</button>
        </div>

        <div className="share-grid">
          <button className="share-item">
            <div className="share-ico green"><IconMsg size={24}/></div>
            <div className="share-label">WhatsApp</div>
          </button>
          <button className="share-item">
            <div className="share-ico blue"><IconMail size={24}/></div>
            <div className="share-label">E-mail</div>
          </button>
          <button className="share-item">
            <div className="share-ico accent"><IconQR size={24}/></div>
            <div className="share-label">QR Code</div>
          </button>
          <button className="share-item">
            <div className="share-ico dark"><IconMore size={20}/></div>
            <div className="share-label">Mais</div>
          </button>
        </div>
      </div>
    </>
  );
}

// ─────────────────────────────────────────────
// VendorApp — top-level state machine
// ─────────────────────────────────────────────
function VendorApp({ catalogLayout = 'grid', dark = false, onToggleDark }) {
  const [route, setRoute] = React.useState({ name: 'tab', tab: 'login' });
  const [sheet, setSheet] = React.useState(null);
  const [toast, setToast] = React.useState(null);

  const showToast = (msg) => {
    setToast(msg);
    clearTimeout(showToast._t);
    showToast._t = setTimeout(() => setToast(null), 1800);
  };

  const onLogin = () => setRoute({ name: 'tab', tab: 'catalog' });
  const onOpen  = (p) => setRoute({ name: 'detail', product: p });
  const onBack  = () => setRoute(r => {
    if (r.name === 'detail') return { name: 'tab', tab: 'catalog' };
    if (r.name === 'qr')     return { name: 'detail', product: r.product };
    return r;
  });
  const onShare = () => setSheet('share');
  const onQR    = () => setRoute(r => ({ name: 'qr', product: r.product }));
  const onAR    = () => showToast('AR ativado · use seu dispositivo real');
  const onSignOut = () => setRoute({ name: 'tab', tab: 'login' });

  // Tab navigation
  const goTab = (tab) => {
    if (tab === 'me' && route.name === 'tab' && route.tab === 'login') return;
    setRoute({ name: 'tab', tab });
  };

  const tab = route.name === 'tab' ? route.tab : null;

  return (
    <div className="app" data-dark={dark ? '1' : '0'}>
      {tab === 'login' && <LoginScreen onLogin={onLogin}/>}
      {tab === 'catalog' && (
        <CatalogoScreen layout={catalogLayout} onOpen={onOpen} onGo={goTab}/>
      )}
      {tab === 'shared' && (
        <CompartilhadosScreen onOpen={onOpen} onGo={goTab}/>
      )}
      {tab === 'insights' && (
        <InsightsScreen onOpen={onOpen} onGo={goTab}/>
      )}
      {tab === 'me' && (
        <ContaScreen
          onSignOut={onSignOut}
          onGo={goTab}
          dark={dark}
          onToggleDark={onToggleDark}/>
      )}
      {route.name === 'detail' && (
        <DetalheScreen product={route.product}
                       onBack={onBack}
                       onShare={onShare}
                       onQR={onQR}
                       onAR={onAR}/>
      )}
      {route.name === 'qr' && (
        <QRScreen product={route.product}
                  onBack={onBack}
                  onShare={onShare}
                  showToast={showToast}/>
      )}

      {sheet === 'share' && route.product && (
        <ShareSheet product={route.product}
                    onClose={() => setSheet(null)}
                    onCopied={() => showToast('Link copiado para a área de transferência')}/>
      )}

      {toast && (
        <div className="toast">
          <IconCheck size={14} style={{ color: 'var(--success)' }}/>
          {toast}
        </div>
      )}
    </div>
  );
}

Object.assign(window, { VendorApp, TabBar });
