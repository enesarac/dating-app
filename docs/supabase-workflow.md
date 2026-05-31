# Supabase Workflow

## Genel Strateji

Local-first geliştirme: değişiklikler önce local'de test edilir, sonra remote'a push edilir.  
Service role key **asla** client bundle'a girmez.

---

## Local Development

```bash
# Supabase CLI kur (henüz kurulmadıysa)
brew install supabase/tap/supabase

# Local stack'i başlat (Postgres + Auth + Storage + Edge Functions + Studio)
supabase start

# Studio URL: http://localhost:54323
# API URL: http://localhost:54321
# Anon key: supabase status komutuyla görebilirsin
```

`.env.local` dosyasına local değerleri koy (`.gitignore`'da gizlenir):

```
EXPO_PUBLIC_SUPABASE_URL=http://localhost:54321
EXPO_PUBLIC_SUPABASE_PUBLISHABLE_KEY=<local-anon-key>
```

---

## Migration Akışı

```bash
# Yeni migration oluştur
supabase migration new <açıklayıcı_isim>
# Örn: supabase migration new create_users_table

# Oluşturulan dosyayı düzenle:
# supabase/migrations/<timestamp>_<isim>.sql

# Local'e uygula
npm run supabase:db:reset   # ya da
supabase migration up

# TypeScript tiplerini yenile
npm run supabase:types
```

---

## Remote Ortam

```bash
# Supabase projesine bağlan (ilk kez)
supabase link --project-ref <project-ref>

# Remote'a push et
supabase db push

# Remote'dan migration pull (takım üyesi değişiklik yaptıysa)
supabase db pull
```

---

## Branch Stratejisi

| Branch      | Supabase Ortamı | Env Dosyası                  |
| ----------- | --------------- | ---------------------------- |
| `main`      | Production      | `.env.production` (gizlenir) |
| `develop`   | Staging         | `.env.staging` (gizlenir)    |
| `feature/*` | Local           | `.env.local` (gizlenir)      |

---

## Güvenlik Kuralları

- **Service role key sadece Edge Function'larda ve CI/CD ortamında kullanılır.**
- Client SDK her zaman `EXPO_PUBLIC_SUPABASE_PUBLISHABLE_KEY` (anon key) ile başlatılır.
- RLS (Row Level Security) tüm tablolarda varsayılan olarak açık tutulur.
- RLS enable ve policy blokları 2.6 migration'ında merkezi olarak uygulanır; her migration dosyasına ayrı ayrı yazılmaz.

---

## TypeScript Tipleri

Her migration sonrası `types/database.ts` güncellenmelidir.

```bash
# Varsayılan: local schema'dan tip üret (local Docker çalışıyorken)
npm run supabase:types

# Remote schema'dan tip üret (local Docker çalışmıyorsa veya remote'dan kontrol gerekiyorsa)
npm run supabase:types:remote
```

`types/database.ts` dosyası commit edilir; el ile düzenlenmez.

---

## Edge Functions

```bash
# Yeni edge function oluştur
supabase functions new <fonksiyon-adı>

# Local'de çalıştır
supabase functions serve <fonksiyon-adı>

# Remote'a deploy et
supabase functions deploy <fonksiyon-adı>
```

Edge Function'lar `supabase/functions/<isim>/index.ts` altında yaşar.
