// app.jsx — top-level composition for the TROVATA prototype.

// Default tweak values (persisted by the host between sessions)
const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
  "palette": "trovata",
  "dark": false,
  "catalogLayout": "grid",
  "previewProductId": "plt-est-01"
}/*EDITMODE-END*/;

const PALETTES = {
  trovata: { accent: '#1976d2', deep: '#1565c0', tint: '#e3f2fd', label: 'Trovata' },
  red:     { accent: '#d32f2f', deep: '#b71c1c', tint: '#ffebee', label: 'Vermelho' },
  forest:  { accent: '#2e7d32', deep: '#1b5e20', tint: '#e8f5e9', label: 'Verde' },
  graphite:{ accent: '#0f172a', deep: '#000000', tint: '#e2e8f0', label: 'Mono' },
};

  function applyPalette(name) {
  const p = PALETTES[name] || PALETTES.trovata;
  const r = document.documentElement.style;
  r.setProperty('--accent', p.accent);
  r.setProperty('--accent-deep', p.deep);
  r.setProperty('--accent-tint', p.tint);
}

function applyDark(dark) {
  if (dark) document.documentElement.setAttribute('data-dark', '1');
  else document.documentElement.removeAttribute('data-dark');
}

function App() {
  const [t, setTweak] = useTweaks(TWEAK_DEFAULTS);

  React.useEffect(() => { applyPalette(t.palette); }, [t.palette]);
  React.useEffect(() => { applyDark(t.dark); }, [t.dark]);

  const previewProduct = PRODUCTS.find(p => p.id === t.previewProductId) || PRODUCTS[0];

  return (
    <>
      <div className="stage">
        <header className="stage-header">
          <div>
            <img src="assets/trovata-logo.png" alt="TROVATA Catálogo Digital e Vendas B2B"
                 style={{ height: 56, width: 'auto', display: 'block' }}/>
            <div style={{
              fontSize: 12, color: 'var(--ink-3)', letterSpacing: '0.18em',
              textTransform: 'uppercase', marginTop: 14, fontWeight: 500,
            }}>
              Protótipo · MVP · 3D + AR no navegador · Birigui-SP
            </div>
          </div>

          <div className="brand-sub">
            <b>Vendedor</b> abre o app, escolhe um produto e compartilha o link.
            <br/>O <b>comprador</b> recebe e visualiza em 3D e AR — sem instalar nada.
          </div>
        </header>

        <div className="surfaces">
          {/* ─── Surface 1 — Vendor iPhone app ─── */}
          <div className="surface">
            <div className="surface-cap">App do vendedor · iOS</div>
            <IOSDevice dark={t.dark}>
              <VendorApp
                catalogLayout={t.catalogLayout}
                dark={t.dark}
                onToggleDark={(v) => setTweak('dark', v)}/>
            </IOSDevice>
          </div>

          {/* ─── Surface 2 — Public viewer (what the buyer sees) ─── */}
          <div className="surface">
            <div className="surface-cap">Link público · navegador</div>
            <ChromeWindow
              width={720}
              height={874}
              url={`catalogo.trovata.com.br/v/${previewProduct.id}`}
              tabs={[
                { title: `${previewProduct.nome} · TROVATA`, active: true },
                { title: 'WhatsApp Web' },
                { title: 'Gmail' },
              ]}
              activeIndex={0}>
              <PublicViewer product={previewProduct} dark={t.dark}/>
            </ChromeWindow>
          </div>
        </div>

        <footer style={{
          marginTop: 24, width: '100%', maxWidth: 1320,
          display: 'flex', justifyContent: 'space-between',
          fontSize: 11, color: 'var(--ink-3)',
          letterSpacing: '0.06em', textTransform: 'uppercase',
          fontWeight: 500,
        }}>
          <div>TROVATA · Catálogo Digital e Vendas B2B · v0.1 — Flutter · Firebase · model-viewer</div>
          <div>{USER.nome} · {USER.empresa} · {USER.cidade}</div>
        </footer>
      </div>

      {/* ─── Tweaks ─── */}
      <TweaksPanel title="TROVATA · Tweaks">
        <TweakSection label="Tema"/>
        <TweakColor label="Cor de marca"
                    value={PALETTES[t.palette]?.accent}
                    options={Object.values(PALETTES).map(p => p.accent)}
                    onChange={(hex) => {
                      const k = Object.keys(PALETTES).find(k => PALETTES[k].accent === hex);
                      if (k) setTweak('palette', k);
                    }}/>
        <TweakToggle label="Modo escuro" value={t.dark}
                     onChange={(v) => setTweak('dark', v)}/>

        <TweakSection label="Catálogo (app)"/>
        <TweakRadio label="Layout" value={t.catalogLayout}
                    options={['grid', 'list']}
                    onChange={(v) => setTweak('catalogLayout', v)}/>

        <TweakSection label="Página pública"/>
        <TweakSelect label="Produto exibido"
                     value={t.previewProductId}
                     options={PRODUCTS.map(p => ({ value: p.id, label: p.nome }))}
                     onChange={(v) => setTweak('previewProductId', v)}/>

        <TweakSection label="Atalhos"/>
        <div style={{
          fontSize: 10.5, color: 'rgba(41,38,27,0.5)', lineHeight: 1.5,
          padding: '2px 0',
        }}>
          • Toque <b>Entrar</b> para abrir o app<br/>
          • Use a barra inferior para navegar entre Catálogo, Compartilhados, Insights e Conta<br/>
          • Toque em qualquer produto para abrir <b>Detalhe → 3D real</b><br/>
          • Em <b>Conta</b> há um toggle de modo escuro que sincroniza com este painel
        </div>
      </TweaksPanel>
    </>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App/>);
