# pair

Dating app — "aynı anda sadece tek aktif eşleşme" kuralı üzerine kurulu.

**Stack:** Expo SDK 56 · Expo Router · React Native · Supabase · TypeScript

---

## Kurulum

```bash
# Bağımlılıkları yükle
npm install

# Ortam değişkenlerini ayarla
cp .env.example .env.local
# .env.local içindeki SUPABASE_URL ve SUPABASE_PUBLISHABLE_KEY değerlerini doldur
```

## Geliştirme

```bash
npm run ios          # iOS simülatör
npm run android      # Android emülatör
npm run web          # Web tarayıcı
```

## Supabase

```bash
npm run supabase:start        # Local Postgres + Auth + Studio başlat
npm run supabase:stop         # Durdur
npm run supabase:db:reset     # Local DB'yi sıfırla ve tüm migration'ları yeniden uygula

# Migration sonrası TypeScript tiplerini yenile
npm run supabase:types        # Local schema'dan üret (varsayılan)
npm run supabase:types:remote # Remote schema'dan üret (local Docker yoksa)
```

Local Studio: `http://localhost:54323`
Local API: `http://localhost:54321`

Ayrıntılı workflow için → [`docs/supabase-workflow.md`](docs/supabase-workflow.md)

## Kalite Kontrol

```bash
npm run typecheck      # TypeScript
npm run lint           # ESLint
npm run format         # Prettier (yaz)
npm run format:check   # Prettier (kontrol)
npm run test           # Jest
```

## Klasör Yapısı

```
app/              Expo Router route dosyaları
components/ui/    Shared UI primitive'leri
features/         auth · discover · profile · match · chat · safety
lib/              supabase · query · state · analytics · validation
theme/            colors · spacing · typography · radius · shadows
types/            database.ts (supabase gen types çıktısı)
supabase/         config.toml · migrations/
docs/             decisions/ · supabase-workflow · vibe-coding-rules
```

## Kararlar

- [`docs/decisions/0001-tech-stack.md`](docs/decisions/0001-tech-stack.md)
- [`docs/decisions/0002-ui-system.md`](docs/decisions/0002-ui-system.md)
- [`docs/decisions/0003-database-model-and-security.md`](docs/decisions/0003-database-model-and-security.md)
- [`docs/vibe-coding-rules.md`](docs/vibe-coding-rules.md)
