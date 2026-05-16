// viewer.js — página pública do produto.
//
// Roteamento aceito:
//   ?id=plt-est-01                ← funciona com qualquer servidor estático
//   /v/plt-est-01                 ← se o host tiver rewrite (Cloudflare Pages / Nginx)
//
// Dependências: model-viewer (CDN, carregado no index.html) + supabase-js (CDN).

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

// ─── Supabase config ────────────────────────────────────────────
// Cole AS MESMAS chaves que estão em lib/supabase_config.dart.
// A anon key é pública por design — pode commitar.
const SUPABASE_URL = 'https://vvzwsaglaffsgpmijoyk.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_smmfhsJZQJMEpaLifqN7kg_2rCfyueS';

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// ─── DOM helpers ────────────────────────────────────────────────
const $ = (sel) => document.querySelector(sel);
const viewer = $('#viewer');
const loading = $('#loading');
const arBtn = $('#arBtn');
const arBtn2 = $('#arBtn2');
const arBtnLabel = $('#arBtnLabel');

function renderProduct(p) {
  document.title = `${p.nome} · TROVATA`;
  $('#og-title').setAttribute('content', p.nome);
  $('#og-desc').setAttribute('content', p.descricao || 'Veja em 3D e AR.');

  $('#nome').textContent = p.nome;
  $('#descricao').textContent = p.descricao || '';
  $('#eyebrow').textContent =
    [p.categoria, p.cor].filter(Boolean).join(' · ').toUpperCase();
  $('#skuChip').textContent = p.sku || p.id;
  $('#footUrl').textContent =
    window.location.href.replace(/^https?:\/\//, '');

  viewer.src = p.glb_url;
  viewer.alt = p.nome;

  const specs = [
    ['SKU', p.sku, { mono: true }],
    ['Dimensões', p.dimensoes],
    ['Peso', p.peso],
    ['Material', p.materiais],
    ['Preço sugerido', p.preco, { accent: true, full: true }],
  ].filter(([, v]) => v);

  $('#specs').innerHTML = specs.map(([k, v, opt = {}]) => `
    <div class="${opt.full ? 'spec-full' : ''}">
      <div class="spec-k">${k}</div>
      <div class="spec-v ${opt.accent ? 'accent' : ''} ${opt.mono ? 'mono' : ''}">${v}</div>
    </div>
  `).join('');
}

function renderError(title, msg) {
  document.body.innerHTML = `
    <header class="topbar">
      <img src="trovata-logo.png" class="brand" alt="TROVATA">
    </header>
    <div class="state-msg">
      <h2>${title}</h2>
      <p>${msg}</p>
    </div>
  `;
}

// ─── Boot ───────────────────────────────────────────────────────
(async () => {
  const params = new URLSearchParams(window.location.search);
  const fromPath = window.location.pathname
    .replace(/\/+$/, '').split('/').pop();
  const produtoId =
    params.get('id') ||
    (fromPath && fromPath !== 'v' && fromPath !== 'viewer' && fromPath !== ''
      ? fromPath
      : null);

  if (!produtoId) {
    renderError('Link inválido', 'A URL não inclui um produto.');
    return;
  }

  try {
    const { data, error } = await supabase
      .from('produtos')
      .select('*')
      .eq('id', produtoId)
      .maybeSingle();
    if (error) throw error;
    if (!data) {
      renderError('Produto não encontrado',
        'Este link pode ter expirado ou o produto foi removido.');
      return;
    }
    if (data.ativo === false) {
      renderError('Produto indisponível',
        'Este produto não está mais publicado.');
      return;
    }
    renderProduct(data);
  } catch (e) {
    console.error(e);
    renderError('Erro ao carregar',
      'Não foi possível conectar ao servidor. Tente novamente em alguns instantes.');
  }
})();

// ─── 3D loading state ──────────────────────────────────────────
viewer.addEventListener('progress', (e) => {
  if ((e.detail.totalProgress ?? 0) >= 1) {
    loading.classList.add('hidden');
  }
});
viewer.addEventListener('load', () => {
  loading.classList.add('hidden');

  if (viewer.canActivateAR) {
    arBtn.hidden = false;
    const ua = navigator.userAgent;
    if (/iPhone|iPad|iPod/.test(ua)) {
      arBtnLabel.textContent = 'Ver no meu espaço (AR)';
    } else if (/Android/.test(ua)) {
      arBtnLabel.textContent = 'Ver no meu ambiente';
    }
  }
});

function activateAR() {
  if (viewer.canActivateAR) viewer.activateAR();
  else alert('AR não é suportado neste dispositivo. '
    + 'Abra este link em um celular Android ou iPhone recente.');
}
arBtn.addEventListener('click', activateAR);
arBtn2.addEventListener('click', activateAR);

$('#quoteBtn')?.addEventListener('click', () => {
  const subject = encodeURIComponent(`Orçamento: ${$('#nome').textContent}`);
  const body = encodeURIComponent(
    `Olá, gostaria de orçamento para o produto deste link:\n${window.location.href}`,
  );
  window.location.href = `mailto:?subject=${subject}&body=${body}`;
});
