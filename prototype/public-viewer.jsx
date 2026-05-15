// public-viewer.jsx — The public page that buyers see when they open the link.
// Hosted at catalogo.trovata.com.br/v/{produtoId}. No login, works on mobile + desktop.

function PublicViewer({ product, dark = false }) {
  if (!product) return null;
  const viewerUrl = `${VIEWER_BASE}${product.id}`;

  return (
    <div className="pv-root" data-dark={dark ? '1' : '0'}>
      <div className="pv-topbar">
        <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
          <img src="trovata-logo.png" alt="TROVATA"
               style={{ height: 32, width: 'auto', display: 'block' }}/>
          <div style={{
            fontSize: 10, padding: '4px 8px', borderRadius: 999,
            background: 'var(--bg-muted)', color: 'var(--ink-2)',
            textTransform: 'uppercase', letterSpacing: '0.12em', fontWeight: 500,
          }}>
            Vitrine pública
          </div>
        </div>
        <div className="pv-from">
          enviado por <b>{USER.nome.split(' ')[0]}</b> · {USER.empresa}
        </div>
      </div>

      <div className="pv-stage">
        <div className="viewer-chip left" style={{ top: 18, left: 18 }}>
          <IconRotate size={11} style={{ marginRight: 4, verticalAlign: -1, display: 'inline' }}/>
          Arraste para girar
        </div>
        <div className="viewer-chip right" style={{ top: 18, right: 18 }}>
          {product.sku}
        </div>
        <ModelViewerEmbed src={product.glbUrl} ar alt={product.nome}/>
        <button className="ar-fab">
          <IconAR size={18}/>
          Ver no meu ambiente
        </button>
      </div>

      <div className="pv-info">
        <div className="left">
          <div className="eyebrow">{product.categoria} · {product.cor}</div>
          <h1>{product.nome}</h1>
          <div className="desc">{product.descricao}</div>

          <div style={{
            display: 'flex', alignItems: 'center', gap: 10,
            marginTop: 22, padding: '14px 16px',
            background: 'var(--bg-muted)', borderRadius: 14,
          }}>
            <IconAR size={18} style={{ color: 'var(--accent)' }}/>
            <div style={{ flex: 1, fontSize: 13, color: 'var(--ink-2)', lineHeight: 1.45 }}>
              <b style={{ color: 'var(--ink)', fontWeight: 500 }}>Disponível em AR.</b>
              {' '}Toque em "Ver no meu ambiente" no celular para projetar em tamanho real.
            </div>
          </div>
        </div>

        <div className="right">
          <div className="specs">
            <div>
              <div className="k">SKU</div>
              <div className="v" style={{ fontFamily: 'var(--font-mono)' }}>{product.sku}</div>
            </div>
            <div>
              <div className="k">Dimensões</div>
              <div className="v">{product.dimensoes}</div>
            </div>
            <div>
              <div className="k">Peso</div>
              <div className="v">{product.peso}</div>
            </div>
            <div>
              <div className="k">Material</div>
              <div className="v">{product.materiais}</div>
            </div>
            <div style={{ gridColumn: '1 / -1' }}>
              <div className="k">Preço sugerido</div>
              <div className="v" style={{ color: 'var(--accent)', fontSize: 22 }}>{product.preco}</div>
            </div>
          </div>
        </div>
      </div>

      <div className="pv-cta">
        <button className="btn btn-ghost btn-lg">
          <IconMail size={16}/>
          Solicitar orçamento
        </button>
        <button className="btn btn-accent btn-lg">
          <IconAR size={16}/>
          Abrir em AR
        </button>
      </div>

      <div className="pv-footer">
        <div>{viewerUrl}</div>
        <div>powered by <a href="#">TROVATA</a></div>
      </div>
    </div>
  );
}

Object.assign(window, { PublicViewer });
