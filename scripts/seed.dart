// scripts/seed.dart
//
// Popula o Firestore com:
//   - 1 empresa
//   - 1 usuário admin
//   - 4 produtos de exemplo usando GLB públicos do modelviewer.dev
//
// USO:
//   1. Rode `flutterfire configure` antes (precisa do firebase_options.dart real)
//   2. Crie o usuário admin no Console do Firebase Authentication
//      (email/senha) e copie o UID dele
//   3. Cole o UID na constante ADMIN_UID abaixo
//   4. Rode: `dart run scripts/seed.dart`
//
// Roda fora do app — só precisa do Firebase Admin SDK pra autenticar.
// Como não estamos usando Admin SDK aqui (pra simplificar), o seed precisa
// rodar logado como o próprio admin. Use a versão de emulador do Firebase
// Auth se quiser iterar sem criar contas reais.

// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../lib/firebase_options.dart';

const ADMIN_EMAIL = 'admin@maraca-design.com.br';
const ADMIN_PASSWORD = 'troque-isto-em-prod';
const ADMIN_UID = 'COLE_O_UID_AQUI'; // UID do auth.users
const EMPRESA_ID = 'maraca-001';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Login como admin (precisa existir no Auth)
  await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: ADMIN_EMAIL,
    password: ADMIN_PASSWORD,
  );
  print('✓ logado como ${FirebaseAuth.instance.currentUser?.email}');

  final db = FirebaseFirestore.instance;
  final batch = db.batch();

  // ─── Empresa
  batch.set(db.collection('empresas').doc(EMPRESA_ID), {
    'nome': 'Maraca Design Comercial',
    'cnpj': '00.000.000/0001-00',
    'ativo': true,
    'criadoEm': FieldValue.serverTimestamp(),
  });

  // ─── Usuário admin
  batch.set(db.collection('usuarios').doc(ADMIN_UID), {
    'nome': 'Marina Vasques',
    'email': ADMIN_EMAIL,
    'empresaId': EMPRESA_ID,
    'papel': 'admin',
    'criadoEm': FieldValue.serverTimestamp(),
  });

  // ─── Produtos
  final produtos = [
    {
      'id': 'plt-est-01',
      'nome': 'Poltrona Estúdio',
      'categoria': 'Móveis',
      'descricao':
          'Estrutura em madeira maciça com estofado em linho natural. '
              'Linhas escultóricas e proporção generosa.',
      'glbUrl': 'https://modelviewer.dev/assets/ShopifyModels/Chair.glb',
      'sku': 'PLT-EST-01',
      'cor': 'Areia',
      'dimensoes': '78 × 84 × 92 cm',
      'peso': '14,2 kg',
      'materiais': 'Linho, madeira',
      'preco': r'R$ 2.890,00',
    },
    {
      'id': 'vso-atl-04',
      'nome': 'Vaso Atelier',
      'categoria': 'Decoração',
      'descricao': 'Vaso geométrico em cerâmica de alta queima. '
          'Pintura à mão, peças com variações únicas.',
      'glbUrl': 'https://modelviewer.dev/assets/ShopifyModels/GeoPlanter.glb',
      'sku': 'VSO-ATL-04',
      'cor': 'Terracota',
      'dimensoes': '22 × 22 × 28 cm',
      'peso': '2,1 kg',
      'materiais': 'Cerâmica',
      'preco': r'R$ 389,00',
    },
    {
      'id': 'elt-vrt-12',
      'nome': 'Liquidificador Vortex',
      'categoria': 'Eletro',
      'descricao': 'Motor de 1500W com jarra em vidro borossilicato '
          'e seis lâminas em aço inox.',
      'glbUrl': 'https://modelviewer.dev/assets/ShopifyModels/Mixer.glb',
      'sku': 'ELT-VRT-12',
      'cor': 'Aço escovado',
      'dimensoes': '21 × 24 × 41 cm',
      'peso': '4,8 kg',
      'materiais': 'Aço, vidro',
      'preco': r'R$ 1.290,00',
    },
    {
      'id': 'col-trn-07',
      'nome': 'Maquete Trem 1:35',
      'categoria': 'Outros',
      'descricao': 'Réplica em escala 1:35 da locomotiva clássica europeia.',
      'glbUrl': 'https://modelviewer.dev/assets/ShopifyModels/ToyTrain.glb',
      'sku': 'COL-TRN-07',
      'cor': 'Verde inglês',
      'dimensoes': '38 × 9 × 14 cm',
      'peso': '1,4 kg',
      'materiais': 'Metal fundido',
      'preco': r'R$ 769,00',
    },
  ];

  for (final p in produtos) {
    final id = p['id'] as String;
    batch.set(db.collection('produtos').doc(id), {
      ...p,
      'empresaId': EMPRESA_ID,
      'viewerUrl': 'https://viewer.showcas3d.app/v/$id',
      'ativo': true,
      'criadoEm': FieldValue.serverTimestamp(),
    });
  }

  await batch.commit();
  print('✓ seed concluído (${produtos.length} produtos)');
  await FirebaseAuth.instance.signOut();
}
