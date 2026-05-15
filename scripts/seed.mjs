// scripts/seed.mjs
//
// Popula o Firestore com empresa, usuário admin e 4 produtos de exemplo.
// Usa Firebase Admin SDK com service account (bypass das auth rules).
//
// Antes de rodar:
//   1. Firebase Console → ⚙ Project Settings → Service Accounts
//      → "Generate new private key" → salva o JSON como:
//      scripts/firebase-admin-key.json
//   2. Cria o usuário admin no Authentication (email/senha) e cola o UID em
//      ADMIN_UID abaixo.
//   3. npm install firebase-admin
//   4. node scripts/seed.mjs

import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import { readFileSync } from 'node:fs';

const serviceAccount = JSON.parse(
  readFileSync(new URL('./firebase-admin-key.json', import.meta.url), 'utf8'),
);

initializeApp({ credential: cert(serviceAccount) });
const db = getFirestore();

const ADMIN_EMAIL = 'admin@maraca-design.com.br';
const ADMIN_UID = 'uvofLyEUbYZFk2V48ZP7BfSIZiE3'; // UID do auth.users
const EMPRESA_ID = 'maraca-001';

const now = FieldValue.serverTimestamp();
const batch = db.batch();

batch.set(db.collection('empresas').doc(EMPRESA_ID), {
  nome: 'Maraca Design Comercial',
  cnpj: '00.000.000/0001-00',
  ativo: true,
  criadoEm: now,
});

batch.set(db.collection('usuarios').doc(ADMIN_UID), {
  nome: 'Marina Vasques',
  email: ADMIN_EMAIL,
  empresaId: EMPRESA_ID,
  papel: 'admin',
  criadoEm: now,
});

const produtos = [
  {
    id: 'plt-est-01',
    nome: 'Poltrona Estúdio',
    categoria: 'Móveis',
    descricao:
      'Estrutura em madeira maciça com estofado em linho natural. Linhas escultóricas e proporção generosa.',
    glbUrl: 'https://modelviewer.dev/assets/ShopifyModels/Chair.glb',
    sku: 'PLT-EST-01',
    cor: 'Areia',
    dimensoes: '78 × 84 × 92 cm',
    peso: '14,2 kg',
    materiais: 'Linho, madeira',
    preco: 'R$ 2.890,00',
  },
  {
    id: 'vso-atl-04',
    nome: 'Vaso Atelier',
    categoria: 'Decoração',
    descricao:
      'Vaso geométrico em cerâmica de alta queima. Pintura à mão, peças com variações únicas.',
    glbUrl: 'https://modelviewer.dev/assets/ShopifyModels/GeoPlanter.glb',
    sku: 'VSO-ATL-04',
    cor: 'Terracota',
    dimensoes: '22 × 22 × 28 cm',
    peso: '2,1 kg',
    materiais: 'Cerâmica',
    preco: 'R$ 389,00',
  },
  {
    id: 'elt-vrt-12',
    nome: 'Liquidificador Vortex',
    categoria: 'Eletro',
    descricao:
      'Motor de 1500W com jarra em vidro borossilicato e seis lâminas em aço inox.',
    glbUrl: 'https://modelviewer.dev/assets/ShopifyModels/Mixer.glb',
    sku: 'ELT-VRT-12',
    cor: 'Aço escovado',
    dimensoes: '21 × 24 × 41 cm',
    peso: '4,8 kg',
    materiais: 'Aço, vidro',
    preco: 'R$ 1.290,00',
  },
  {
    id: 'col-trn-07',
    nome: 'Maquete Trem 1:35',
    categoria: 'Outros',
    descricao: 'Réplica em escala 1:35 da locomotiva clássica europeia.',
    glbUrl: 'https://modelviewer.dev/assets/ShopifyModels/ToyTrain.glb',
    sku: 'COL-TRN-07',
    cor: 'Verde inglês',
    dimensoes: '38 × 9 × 14 cm',
    peso: '1,4 kg',
    materiais: 'Metal fundido',
    preco: 'R$ 769,00',
  },
];

for (const p of produtos) {
  const { id, ...rest } = p;
  batch.set(db.collection('produtos').doc(id), {
    ...rest,
    empresaId: EMPRESA_ID,
    viewerUrl: `https://viewer.showcas3d.app/v/${id}`,
    ativo: true,
    criadoEm: now,
  });
}

await batch.commit();
console.log(`✓ seed concluído: 1 empresa, 1 admin, ${produtos.length} produtos`);
process.exit(0);
