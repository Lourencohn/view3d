-- TROVATA — schema completo do Supabase
--
-- Como usar:
--   1. Crie um projeto em https://supabase.com
--   2. Abra: SQL Editor → New query
--   3. Cole TODO este arquivo e clique "Run"
--   4. Copie URL + anon key (Settings → API) para lib/supabase_config.dart
--   5. Em Authentication → Settings, desligue "Confirm email" para facilitar dev
--   6. Crie um usuário em Authentication → Add user (ou via login no app)
--
-- O que isto cria:
--   - Tabelas: empresas, profiles (linkada a auth.users), produtos, compartilhamentos
--   - RLS multi-tenant (cada vendedor só vê produtos da própria empresa)
--   - Bucket de Storage `produtos` (read público pro viewer)
--   - Trigger que cria profile automaticamente no signup
--   - 1 empresa de exemplo + 4 produtos com GLBs públicos de modelviewer.dev

-- ────────────────────────────────────────────────────────────
-- 1. TABELAS
-- ────────────────────────────────────────────────────────────

create table if not exists public.empresas (
  id          text primary key,
  nome        text not null,
  cnpj        text,
  ativo       boolean not null default true,
  criado_em   timestamptz not null default now()
);

create table if not exists public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  nome        text not null,
  email       text,
  empresa_id  text not null references public.empresas(id),
  papel       text not null default 'vendedor' check (papel in ('admin','vendedor')),
  criado_em   timestamptz not null default now()
);

create table if not exists public.produtos (
  id          text primary key,
  nome        text not null,
  descricao   text,
  categoria   text,
  empresa_id  text not null references public.empresas(id),
  glb_url     text not null,
  viewer_url  text,
  thumb_url   text,
  ativo       boolean not null default true,
  criado_em   timestamptz not null default now(),
  sku         text,
  cor         text,
  dimensoes   text,
  peso        text,
  materiais   text,
  preco       text
);

create index if not exists idx_produtos_empresa on public.produtos(empresa_id);
create index if not exists idx_produtos_ativo on public.produtos(ativo);

create table if not exists public.compartilhamentos (
  id            uuid primary key default gen_random_uuid(),
  produto_id    text not null references public.produtos(id) on delete cascade,
  empresa_id    text not null,
  uid           uuid not null references auth.users(id) on delete cascade,
  canal         text,
  comprador     text,
  contato       text,
  data_hora     timestamptz not null default now(),
  views         int not null default 0,
  ar_sessions   int not null default 0,
  ultimo_acesso timestamptz
);

create index if not exists idx_compart_uid on public.compartilhamentos(uid, data_hora desc);

-- ────────────────────────────────────────────────────────────
-- 2. ROW LEVEL SECURITY (multi-tenant)
-- ────────────────────────────────────────────────────────────

alter table public.empresas enable row level security;
alter table public.profiles enable row level security;
alter table public.produtos enable row level security;
alter table public.compartilhamentos enable row level security;

-- profiles: cada user lê/atualiza só o próprio
drop policy if exists "own_profile_read" on public.profiles;
create policy "own_profile_read" on public.profiles
  for select using (auth.uid() = id);

drop policy if exists "own_profile_update" on public.profiles;
create policy "own_profile_update" on public.profiles
  for update using (auth.uid() = id);

-- empresas: user lê só a empresa à qual pertence
drop policy if exists "empresa_membro_read" on public.empresas;
create policy "empresa_membro_read" on public.empresas
  for select using (
    id in (select empresa_id from public.profiles where id = auth.uid())
  );

-- produtos: leitura PÚBLICA (viewer sem login precisa baixar o .glb).
-- Escrita só por admins da própria empresa.
drop policy if exists "produtos_public_read" on public.produtos;
create policy "produtos_public_read" on public.produtos
  for select using (true);

drop policy if exists "produtos_admin_write" on public.produtos;
create policy "produtos_admin_write" on public.produtos
  for all using (
    exists (
      select 1 from public.profiles
      where id = auth.uid()
        and papel = 'admin'
        and empresa_id = produtos.empresa_id
    )
  );

-- compartilhamentos: vendedor lê os próprios
drop policy if exists "compart_owner_read" on public.compartilhamentos;
create policy "compart_owner_read" on public.compartilhamentos
  for select using (auth.uid() = uid);

drop policy if exists "compart_owner_insert" on public.compartilhamentos;
create policy "compart_owner_insert" on public.compartilhamentos
  for insert with check (auth.uid() = uid);

-- ────────────────────────────────────────────────────────────
-- 3. TRIGGER — cria profile automaticamente no signup
-- ────────────────────────────────────────────────────────────

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, nome, email, empresa_id, papel)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'nome', split_part(new.email, '@', 1)),
    new.email,
    'trovata-birigui',  -- empresa padrão; ajuste manualmente se precisar
    'vendedor'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ────────────────────────────────────────────────────────────
-- 4. STORAGE — bucket público para arquivos .glb
-- ────────────────────────────────────────────────────────────

insert into storage.buckets (id, name, public)
values ('produtos', 'produtos', true)
on conflict (id) do nothing;

drop policy if exists "produtos_public_read" on storage.objects;
create policy "produtos_public_read" on storage.objects
  for select using (bucket_id = 'produtos');

drop policy if exists "produtos_auth_upload" on storage.objects;
create policy "produtos_auth_upload" on storage.objects
  for insert with check (
    bucket_id = 'produtos' and auth.role() = 'authenticated'
  );

-- ────────────────────────────────────────────────────────────
-- 5. SEED — 1 empresa + 4 produtos de exemplo
--    GLBs são públicos de modelviewer.dev (substitua quando tiver os reais)
-- ────────────────────────────────────────────────────────────

insert into public.empresas (id, nome, cnpj, ativo)
values ('trovata-birigui', 'Trovata Catálogo Digital', '00.000.000/0001-00', true)
on conflict (id) do nothing;

insert into public.produtos (id, nome, descricao, categoria, empresa_id, glb_url, viewer_url, sku, cor, dimensoes, peso, materiais, preco)
values
  ('plt-est-01', 'Poltrona Estúdio',
   'Estrutura em madeira maciça com estofado em linho natural. Linhas escultóricas e proporção generosa.',
   'Móveis', 'trovata-birigui',
   'https://modelviewer.dev/assets/ShopifyModels/Chair.glb',
   'http://localhost:8000/viewer/?id=plt-est-01',
   'PLT-EST-01', 'Areia', '78 × 84 × 92 cm', '14,2 kg', 'Linho, madeira', 'R$ 2.890,00'),
  ('vso-atl-04', 'Vaso Atelier',
   'Vaso geométrico em cerâmica de alta queima. Pintura à mão, peças com variações únicas.',
   'Decoração', 'trovata-birigui',
   'https://modelviewer.dev/assets/ShopifyModels/GeoPlanter.glb',
   'http://localhost:8000/viewer/?id=vso-atl-04',
   'VSO-ATL-04', 'Terracota', '22 × 22 × 28 cm', '2,1 kg', 'Cerâmica', 'R$ 389,00'),
  ('elt-vrt-12', 'Liquidificador Vortex',
   'Motor de 1500W com jarra em vidro borossilicato e seis lâminas em aço inox.',
   'Eletro', 'trovata-birigui',
   'https://modelviewer.dev/assets/ShopifyModels/Mixer.glb',
   'http://localhost:8000/viewer/?id=elt-vrt-12',
   'ELT-VRT-12', 'Aço escovado', '21 × 24 × 41 cm', '4,8 kg', 'Aço, vidro', 'R$ 1.290,00'),
  ('col-trn-07', 'Maquete Trem 1:35',
   'Réplica em escala 1:35 da locomotiva clássica europeia.',
   'Outros', 'trovata-birigui',
   'https://modelviewer.dev/assets/ShopifyModels/ToyTrain.glb',
   'http://localhost:8000/viewer/?id=col-trn-07',
   'COL-TRN-07', 'Verde inglês', '38 × 9 × 14 cm', '1,4 kg', 'Metal fundido', 'R$ 769,00')
on conflict (id) do nothing;
