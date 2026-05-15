// data.js — Sample product catalog for ShowCase3D demo

const PRODUCTS = [
  {
    id: 'plt-est-01',
    nome: 'Poltrona Estúdio',
    categoria: 'Móveis',
    descricao: 'Estrutura em madeira maciça com estofado em linho natural. Linhas escultóricas e proporção generosa, pensada para áreas de leitura e lounge.',
    glbUrl: 'https://modelviewer.dev/assets/ShopifyModels/Chair.glb',
    sku: 'PLT-EST-01',
    dimensoes: '78 × 84 × 92 cm',
    peso: '14,2 kg',
    materiais: 'Linho, madeira',
    cor: 'Areia',
    preco: 'R$ 2.890,00',
    accent: '#d8c8b0',
  },
  {
    id: 'vso-atl-04',
    nome: 'Vaso Atelier',
    categoria: 'Decoração',
    descricao: 'Vaso geométrico em cerâmica de alta queima. Pintura à mão, cada peça com pequenas variações que tornam o produto único.',
    glbUrl: 'https://modelviewer.dev/assets/ShopifyModels/GeoPlanter.glb',
    sku: 'VSO-ATL-04',
    dimensoes: '22 × 22 × 28 cm',
    peso: '2,1 kg',
    materiais: 'Cerâmica',
    cor: 'Terracota',
    preco: 'R$ 389,00',
    accent: '#e8d4b8',
  },
  {
    id: 'elt-vrt-12',
    nome: 'Liquidificador Vortex',
    categoria: 'Eletro',
    descricao: 'Motor de 1500W com jarra em vidro borossilicato e seis lâminas em aço inox. Acabamento premium escovado.',
    glbUrl: 'https://modelviewer.dev/assets/ShopifyModels/Mixer.glb',
    sku: 'ELT-VRT-12',
    dimensoes: '21 × 24 × 41 cm',
    peso: '4,8 kg',
    materiais: 'Aço, vidro',
    cor: 'Aço escovado',
    preco: 'R$ 1.290,00',
    accent: '#cdd5d8',
  },
  {
    id: 'col-trn-07',
    nome: 'Maquete Trem 1:35',
    categoria: 'Colecionável',
    descricao: 'Réplica em escala 1:35 da locomotiva clássica europeia. Acabamento em metal fundido com detalhes pintados à mão.',
    glbUrl: 'https://modelviewer.dev/assets/ShopifyModels/ToyTrain.glb',
    sku: 'COL-TRN-07',
    dimensoes: '38 × 9 × 14 cm',
    peso: '1,4 kg',
    materiais: 'Metal fundido',
    cor: 'Verde inglês',
    preco: 'R$ 769,00',
    accent: '#c0c8b8',
  },
  {
    id: 'plt-est-02',
    nome: 'Poltrona Estúdio · Carbono',
    categoria: 'Móveis',
    descricao: 'Mesma silhueta da Estúdio em estofado grafite, base em aço preto fosco.',
    glbUrl: 'https://modelviewer.dev/assets/ShopifyModels/Chair.glb',
    sku: 'PLT-EST-02',
    dimensoes: '78 × 84 × 92 cm',
    peso: '14,2 kg',
    materiais: 'Linho, aço',
    cor: 'Grafite',
    preco: 'R$ 3.120,00',
    accent: '#2a2622',
  },
  {
    id: 'vso-atl-05',
    nome: 'Vaso Atelier · Off',
    categoria: 'Decoração',
    descricao: 'Variação em off-white para ambientes mais minimalistas.',
    glbUrl: 'https://modelviewer.dev/assets/ShopifyModels/GeoPlanter.glb',
    sku: 'VSO-ATL-05',
    dimensoes: '22 × 22 × 28 cm',
    peso: '2,1 kg',
    materiais: 'Cerâmica',
    cor: 'Off-white',
    preco: 'R$ 389,00',
    accent: '#f0ece4',
  },
];

const CATEGORIAS = ['Todos', 'Móveis', 'Decoração', 'Eletro', 'Colecionável'];

const VIEWER_BASE = 'https://catalogo.trovata.com.br/v/';

// Mock user — vendedor Trovata
const USER = {
  nome: 'Marina Vasques',
  email: 'marina.vasques@trovata.com.br',
  empresa: 'Trovata Catálogo Digital',
  empresaId: 'trovata-birigui',
  papel: 'vendedor',
  iniciais: 'MV',
  cidade: 'Birigui, SP',
};

Object.assign(window, { PRODUCTS, CATEGORIAS, VIEWER_BASE, USER });

// ─────────────────────────────────────────────
// Shares — histórico de compartilhamentos do vendedor
// ─────────────────────────────────────────────
const CANAIS = {
  whatsapp: { label: 'WhatsApp', color: '#25D366' },
  email:    { label: 'E-mail',   color: '#1976D2' },
  qr:       { label: 'QR Code',  color: '#D32F2F' },
  link:     { label: 'Link',     color: '#0F172A' },
};

// Datas relativas — calculadas no boot para sempre parecerem "agora"
const _now = Date.now();
const _mins = (n) => new Date(_now - n * 60_000);
const _hours = (n) => new Date(_now - n * 3_600_000);
const _days = (n) => new Date(_now - n * 86_400_000);

const SHARES = [
  { id: 's1', produtoId: 'plt-est-01', canal: 'whatsapp',
    comprador: 'Luísa · Studio Vermelho',  contato: '+55 11 9 8870-4421',
    dataHora: _mins(18),   views: 7, arSessions: 2, ultimoAcesso: _mins(4) },
  { id: 's2', produtoId: 'vso-atl-04', canal: 'whatsapp',
    comprador: 'Café Tigela',              contato: '+55 21 9 9224-1108',
    dataHora: _hours(3),   views: 12, arSessions: 0, ultimoAcesso: _hours(1) },
  { id: 's3', produtoId: 'plt-est-02', canal: 'email',
    comprador: 'Hotel Cardume',            contato: 'compras@cardume.co',
    dataHora: _hours(7),   views: 4, arSessions: 1, ultimoAcesso: _hours(6) },
  { id: 's4', produtoId: 'elt-vrt-12', canal: 'qr',
    comprador: null, contato: 'feira NRF', dataHora: _days(1),
    views: 23, arSessions: 4, ultimoAcesso: _hours(20) },
  { id: 's5', produtoId: 'vso-atl-05', canal: 'whatsapp',
    comprador: 'Pousada Maré',             contato: '+55 71 9 9988-2230',
    dataHora: _days(2),    views: 9, arSessions: 0, ultimoAcesso: _days(1) },
  { id: 's6', produtoId: 'plt-est-01', canal: 'link',
    comprador: 'Restaurante Olho de Boi',  contato: 'olho-de-boi.com.br',
    dataHora: _days(3),    views: 18, arSessions: 3, ultimoAcesso: _days(1) },
  { id: 's7', produtoId: 'col-trn-07', canal: 'email',
    comprador: 'Galeria Sub',              contato: 'oi@galeria.sub',
    dataHora: _days(5),    views: 2, arSessions: 0, ultimoAcesso: _days(5) },
  { id: 's8', produtoId: 'plt-est-01', canal: 'whatsapp',
    comprador: 'Atelier 14',               contato: '+55 11 9 8830-6712',
    dataHora: _days(6),    views: 31, arSessions: 7, ultimoAcesso: _days(2) },
];

// ─────────────────────────────────────────────
// Insights — métricas agregadas (mock)
// ─────────────────────────────────────────────
const INSIGHTS = {
  // últimos 7 dias
  views7d: 142,
  views7dDelta: 0.43,     // +43% vs semana anterior
  uniqueBuyers: 23,
  uniqueBuyersDelta: 0.21,
  arSessions: 31,
  arSessionsDelta: -0.08, // -8%
  avgTimeSec: 47,
  avgTimeDelta: 0.12,

  // série semanal de views (mais antigo → mais recente)
  viewsSeries: [8, 14, 11, 22, 18, 32, 37],

  topProdutos: [
    { id: 'plt-est-01', views: 56, arSessions: 12 },
    { id: 'vso-atl-04', views: 34, arSessions: 4  },
    { id: 'elt-vrt-12', views: 23, arSessions: 4  },
    { id: 'plt-est-02', views: 18, arSessions: 6  },
    { id: 'vso-atl-05', views: 11, arSessions: 5  },
  ],

  canais: {
    whatsapp: 0.62,
    email:    0.24,
    qr:       0.09,
    link:     0.05,
  },
};

function relTime(date) {
  const d = new Date(date);
  const diff = (Date.now() - d.getTime()) / 1000;
  if (diff < 60)    return 'agora';
  if (diff < 3600)  return `há ${Math.floor(diff / 60)} min`;
  if (diff < 86400) return `há ${Math.floor(diff / 3600)} h`;
  const days = Math.floor(diff / 86400);
  if (days === 1)   return 'ontem';
  if (days < 7)     return `há ${days} dias`;
  return d.toLocaleDateString('pt-BR', { day: '2-digit', month: 'short' });
}

function dayBucket(date) {
  const d = new Date(date);
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const target = new Date(d); target.setHours(0, 0, 0, 0);
  const diffDays = Math.round((today - target) / 86_400_000);
  if (diffDays === 0) return 'Hoje';
  if (diffDays === 1) return 'Ontem';
  if (diffDays < 7)   return 'Esta semana';
  if (diffDays < 30)  return 'Este mês';
  return 'Antes';
}

Object.assign(window, { SHARES, CANAIS, INSIGHTS, relTime, dayBucket });
