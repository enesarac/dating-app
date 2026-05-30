# Vibe Coding Rules

Hızlı iterasyon yaparken kalite çıtasını düşürmemek için bu kurallar tüm geliştirme sürecinde geçerlidir.

---

## 1. Kapsam Disiplini

- Görevin kapsamı dışına çıkma. Bug fix = bug fix. Feature = feature. Çevre temizliği ayrı commit.
- Sormadan refactor etme; bağlamı olmayan iyileştirmeler PR'ı büyütür, review'u zorlaştırır.
- "Şu an gerek yok" diye başlayan şeyi yapma. YAGNI.

---

## 2. Tip Güvenliği

- `any` kullanma. Geçici olsa bile `unknown` kullan ve narrowing ekle.
- Supabase sorgularında `Database` tipini kullan; `as` cast'lerini minimumda tut.
- Zod schema ile API boundary'de validasyon yap; iç fonksiyonlarda tekrarlama.

---

## 3. Bileşen Yazım Kuralları

- Her bileşen tek sorumluluk taşır. Hem layout hem iş mantığı hem data fetch aynı dosyada olmamalı.
- Props `accessibilityLabel` gerektirir. `hitSlop` minimum touch target 44x44 için şart.
- Theme token'ların dışında sabit renk/boyut yazma (`#fff`, `16` gibi magic number).
- StyleSheet dışarıda tanımlanır; render içinde inline obje yaratma.

---

## 4. Performans

- `FlatList` / `FlashList` kullan; `ScrollView` + `map` kombinasyonunu büyük listede kullanma.
- `useCallback` ve `useMemo` sadece gerçek performans sorununda kullan; erken optimizasyon kod gürültüsü yaratır.
- `expo-image` profil fotoğrafları için zorunlu; `Image` doğrudan kullanma.
- Reanimated animasyonları worklet içinde; JS thread'e köprü kurma.

---

## 5. Veri & State

- Sunucu verisi → TanStack Query. Global UI state → Zustand. Form state → React Hook Form. Bunların dışına taşma.
- Optimistic update yazmadan önce rollback stratejisini düşün.
- Supabase realtime subscription'ı açtıysan `useEffect` cleanup'ında kaldır.

---

## 6. Güvenlik

- Service role key asla client bundle'a girmez; `.env` içindeki hangi variable'ın nereye gittiğini kontrol et.
- RLS'siz tablo açma. Migration'da politika da yazılır.
- User input her zaman Zod ile validate edilir; DB'ye ham veri gitmez.
- `console.log` içinde user data bırakma; production'da log seviyesini kısıtla.

---

## 7. Test

- Test, feature'ın kendisiyle aynı PR'da gider. "Sonra test yazarım" geçerli değil.
- Testing Library ile render test yaz; implementation detail test etme.
- Kritik iş mantığı (eşleşme kuralı, lock mekanizması) birim testi ile kapsanır.

---

## 8. Commit & Branch Disiplini

- Her commit tek bir amaca hizmet eder (atomic commit).
- Commit mesajı `type(scope): kısa açıklama` formatında (conventional commits).
- Feature branch'te migration SQL varsa `supabase db reset` ile test edilmiş olmalı.

---

## 9. Dokümantasyon

- Neden yaptığını yaz, ne yaptığını değil. Kod zaten ne yapıldığını gösteriyor.
- ADR (Architecture Decision Record) formatında `docs/decisions/` altına yaz.
- Magic number veya non-obvious workaround varsa tek satır yorum yeterli.

---

## 10. Dating App'e Özel

- "Bu yeterince iyi görünüyor" çıtası yoktur. Profil kartı, match ekranı, chat composer premium hissettirmeli.
- Animasyon yoksa etkileşim yok. Swipe, match, send — her biri feedback verir.
- Locked mode UI'sı kullanıcıya "partnerim sadece benimle ilgileniyor" güvenini verir; bu sadece bir overlay değil, ürünün kalbi.
