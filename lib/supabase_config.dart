/// Credenciais do projeto Supabase.
///
/// Onde achar:
///   Supabase Dashboard → Settings → API
///   - Project URL  → [url]
///   - anon public  → [anonKey]   (pode commitar, é pública)
///
/// NUNCA cole aqui a `service_role` key — ela ignora RLS.
class SupabaseConfig {
  static const String url = 'PLACEHOLDER_SUPABASE_URL';
  static const String anonKey = 'PLACEHOLDER_SUPABASE_ANON_KEY';
}
