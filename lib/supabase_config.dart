/// Credenciais do projeto Supabase.
///
/// Onde achar:
///   Supabase Dashboard → Settings → API
///   - Project URL  → [url]
///   - anon public  → [anonKey]   (pode commitar, é pública)
///
/// NUNCA cole aqui a `service_role` key — ela ignora RLS.
class SupabaseConfig {
  static const String url = 'https://vvzwsaglaffsgpmijoyk.supabase.co';
  static const String anonKey = 'sb_publishable_smmfhsJZQJMEpaLifqN7kg_2rCfyueS';
}
