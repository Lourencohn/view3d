// viewer.js — bootstrap da página pública.
//
// Roteamento: /v/{produtoId}
//   1. extrai o produtoId da URL
//   2. lê o doc produtos/{produtoId} no Firestore (regra de read pública)
//   3. preenche o <model-viewer src=...> e os metadados
//
// Dependências: model-viewer (carregado via CDN em index.html) e Firebase JS.

import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js';
import {
  getFirestore, doc, getDoc,
} from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore.js';

// ─── Firebase config ────────────────────────────────────────────
// IMPORTANTE: substitua pelas chaves reais do seu projeto (Console Firebase
// → Project Settings → SDK setup and configuration → CDN).
// Estes valores estão DUPLICADOS em lib/firebase_options.dart só para
// referência visual — o que vale aqui é este config.
const firebaseConfig = {
  apiKey: 'PLACEHOLDER_WEB_API_KEY',
  authDomain: 'trovata-placeholder.firebaseapp.com',
  projectId: 'trovata-placeholder',
  storageBucket: 'trovata-placeholder.appspot.com',
  messagingSenderId: 'PLACEHOLDER_SENDER_ID',
  appId: 'PLACEHOLDER_WEB_APP_ID',
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

// ─── DOM helpers ────────────────────────────────────────────────
const $ = (sel) => document.querySelector(sel);
const viewer = $('#viewer');
const loading = $('#loading');
const arBtn = $('#arBtn');
const arBtn2 = $('#arBtn2');
const arBtnLabel = $('#arBtnLabel');

function fmt(text) { return text ? text : ''; }

function renderProduct(p) {
  // Title
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

  // model
  viewer.src = p.glbUrl;
  viewer.alt = p.nome;

  // specs
  const specs = [
    ['SKU', p.sku, { mono: true }],
    ['Dimensões', p.dimensoes],
    ['Peso', p.peso],
    ['Material', p.materiais],
    ['Preço sugerido', p.preco, { accent: true, full: true }],
  ].filter(([_, v]) => v);

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
  // /v/abc123  →  abc123
  const path = window.location.pathname.replace(/\/+$/, '');
  const produtoId = path.split('/').pop();

  if (!produtoId || produtoId === 'v' || produtoId === '') {
    renderError('Link inválido', 'A URL não inclui um produto.');
    return;
  }

  try {
    const snap = await getDoc(doc(db, 'produtos', produtoId));
    if (!snap.exists()) {
      renderError('Produto não encontrado',
        'Este link pode ter expirado ou o produto foi removido.');
      return;
    }
    const data = snap.data();
    if (data.ativo === false) {
      renderError('Produto indisponível',
        'Este produto não está mais publicado.');
      return;
    }
    renderProduct({ id: produtoId, ...data });
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

  // Mostra o botão de AR apenas se o dispositivo suporta
  if (viewer.canActivateAR) {
    arBtn.hidden = false;
    // Texto contextual
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
  // Hook para integração futura — por enquanto abre mailto.
  const subject = encodeURIComponent(`Orçamento: ${$('#nome').textContent}`);
  const body = encodeURIComponent(
    `Olá, gostaria de orçamento para o produto deste link:\n${window.location.href}`,
  );
  window.location.href = `mailto:?subject=${subject}&body=${body}`;
});
