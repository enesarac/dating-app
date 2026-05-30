# 0001 — Tech Stack Kararları

**Tarih:** 2026-05-30  
**Durum:** Kabul edildi

---

## Bağlam

Dating app MVP'si için Expo React Native + Supabase temelinde teknoloji yığını belirlendi.  
Karar kriterleri: hız, type-safety, bakım kolaylığı, dating app'e özel UI gereksinimleri, küçük ekip.

---

## Kararlar

### Navigasyon — Expo Router

**Seçilen:** Expo Router (file-system routing, React Navigation tabanlı)  
**Reddedilen:** React Navigation manuel kurulumu  
**Gerekçe:** SDK 56 ile birlikte expo-router olgunlaştı. Typed routes, deep link, tab/stack/modal navigasyonu için standart oldu. Dosya tabanlı yapı ekibe okunabilirlik kazandırır.

---

### State Yönetimi — TanStack Query + Zustand

**Seçilen:** TanStack Query (server state) + Zustand (küçük client/UI state)  
**Reddedilen:** Redux Toolkit, Jotai, MobX  
**Gerekçe:**  
- Sunucu verisini (profiller, eşleşmeler, mesajlar) cache, stale, refetch, optimistic update paradigmasıyla yönetmek için TanStack Query en olgun çözüm.  
- Global UI state (modal açık/kapalı, onboarding adımı gibi) için Zustand minimal ve TypeScript dostu.  
- Context API büyük uygulamalarda re-render baskısı oluşturur; ikili çözüm bu sorunu önler.

---

### Form & Validasyon — React Hook Form + Zod

**Seçilen:** React Hook Form + Zod + @hookform/resolvers  
**Reddedilen:** Formik, Yup  
**Gerekçe:**  
- RHF performanslı (uncontrolled), Zod type inference ile TypeScript'e native.  
- Validasyon şemaları server/client arasında paylaşılabilir.  
- Formik performans sorunları ve Yup tip desteği eksikliği nedeniyle elendi.

---

### UI / Styling — Custom Design System (StyleSheet + typed theme tokens)

**Seçilen:** Custom React Native design system; StyleSheet + typed token dosyaları  
**Reddedilen:** NativeWind, Tamagui, React Native Paper (ilk kurulumda)  
**Gerekçe:** Bkz. `0002-ui-system.md` (detaylı gerekçe orada).

---

### UI Altyapı Kütüphaneleri

| Kütüphane | Kullanım |
|---|---|
| `react-native-reanimated` | Swipe, match animasyonları, transition |
| `react-native-gesture-handler` | Pan gesture, swipe card |
| `@gorhom/bottom-sheet` | Match ekranı, filtreler, detay sayfaları |
| `expo-image` | Profil fotoğrafı — performanslı cache/placeholder |
| `lucide-react-native` | İkon seti (SVG, tree-shakeable) |

---

### Test — jest-expo + @testing-library/react-native

**Seçilen:** jest-expo + @testing-library/react-native  
**Gerekçe:** Expo SDK ile uyumlu resmi test kurulumu. Testing Library render-agnostic, erişilebilirlik odaklı test yaklaşımı zorlar.

**E2E — Maestro (dokümante edildi, henüz kurulmadı)**  
Maestro mobile-first YAML tabanlı E2E aracı. React Native'de Detox'a göre daha az boilerplate, CI entegrasyonu kolay. Sonraki beta aşamasında kurulacak.

---

### Analytics — PostHog (no-op in development)

**Seçilen:** PostHog (self-hosted veya EU cloud)  
**Gerekçe:** Açık kaynak, GDPR uyumlu EU instance, product analytics + feature flags tek araçta.  
**Kural:** `EXPO_PUBLIC_APP_ENV=development` iken analytics no-op çalışır. Autocapture ve session replay kapalı tutulur; yalnızca explicit `analytics.capture()` çağrıları aktif.

---

### Crash Reporting — Sentry (ertelendi)

**Karar:** Sentry React Native kullanılacak.  
**Durum:** SDK entegrasyonu sonraki beta/release aşamasına bırakıldı. Simdilik `EXPO_PUBLIC_SENTRY_DSN` env'de rezerve.  
**Not:** Sentry native modülleri `npx expo install @sentry/react-native` + config plugin gerektirir; EAS Build'e bağlı.

---

### Push Bildirimleri — Expo Notifications (ertelendi)

**Karar:** Expo Notifications kullanılacak.  
**Durum:** Token kayıt altyapısı safety/notification fazında yapılacak. Şu an kapsam dışı.

---

### Backend — Supabase (local-first CLI/migrations)

**Kural:**  
- Local development: `supabase start` → local Postgres + Auth + Storage + Edge Functions  
- Remote: branch/merge migration akışı (`supabase db push`)  
- Mobil client: sadece `EXPO_PUBLIC_SUPABASE_URL` ve `EXPO_PUBLIC_SUPABASE_PUBLISHABLE_KEY`  
- **Service role key asla client bundle'a girmez.**

---

## Sonradan Tekrar Değerlendirilecekler

| Konu | Koşul |
|---|---|
| NativeWind / Tamagui pivot | Pair kararıyla küçük pilot sonrası (bkz. `0002-ui-system.md`) |
| Maestro E2E kurulumu | Beta aşamasında, CI pipeline hazır olduğunda |
| Sentry entegrasyonu | Beta / release branch açılmadan önce |
| Expo Notifications token kaydı | Safety/notification fazı başlamadan önce |
| Abonelik / ödeme altyapısı | Post-MVP, product-market fit sonrası |
| Web uygulaması | Kapsam dışı — sonraki milestone'da değerlendirilecek |
