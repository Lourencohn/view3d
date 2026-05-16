#!/usr/bin/env node
// scripts/seed.mjs — adiciona produtos extras no Supabase via REST.
//
// O `supabase/schema.sql` já cria 4 produtos de amostra ao ser executado.
// Este script é só pra adicionar/atualizar mais produtos em lote depois.
//
// USO:
//   export SUPABASE_URL='https://xxxx.supabase.co'
//   export SUPABASE_SERVICE_KEY='eyJ...'   # Settings → API → service_role
//   node scripts/seed.mjs
//
// Por que `service_role`? Porque o RLS bloqueia INSERT pela anon key.
// NUNCA commite essa chave — só use local.

const URL = process.env.SUPABASE_URL;
const KEY = process.env.SUPABASE_SERVICE_KEY;

if (!URL || !KEY) {
  console.error('Defina SUPABASE_URL e SUPABASE_SERVICE_KEY no ambiente.');
  process.exit(1);
}

const EMPRESA_ID = 'trovata-birigui';

const produtos = [
  // adicione aqui — exemplos abaixo (descomente / edite)
  // {
  //   id: 'plt-est-02',
  //   nome: 'Poltrona Curva',
  //   descricao: 'Variante da Poltrona Estúdio com encosto curvo.',
  //   categoria: 'Móveis',
  //   glb_url: 'https://modelviewer.dev/assets/ShopifyModels/Chair.glb',
  //   sku: 'PLT-EST-02',
  //   cor: 'Areia',
  //   dimensoes: '78 × 84 × 96 cm',
  //   peso: '14,8 kg',
  //   materiais: 'Linho, madeira',
  //   preco: 'R$ 3.190,00',
  // },
];

if (produtos.length === 0) {
  console.log('Nada a fazer. Edite scripts/seed.mjs e adicione produtos.');
  process.exit(0);
}

for (const p of produtos) {
  const body = {
    ...p,
    empresa_id: EMPRESA_ID,
    viewer_url: `http://localhost:8000/viewer/?id=${p.id}`,
    ativo: true,
  };
  const res = await fetch(`${URL}/rest/v1/produtos`, {
    method: 'POST',
    headers: {
      apikey: KEY,
      Authorization: `Bearer ${KEY}`,
      'Content-Type': 'application/json',
      Prefer: 'resolution=merge-duplicates',
    },
    body: JSON.stringify(body),
  });
  if (!res.ok) {
    console.error(`✗ ${p.id}  ${res.status}  ${await res.text()}`);
  } else {
    console.log(`✓ ${p.id}`);
  }
}
