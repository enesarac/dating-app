# 0002 — UI System Kararı: Custom Design System

**Tarih:** 2026-05-30  
**Durum:** Kabul edildi

---

## Neden Custom Design System?

Dating app, standart bir iş uygulaması değil; duygusal yoğunluk, güven ve estetik beklentisi yüksek bir deneyim sunar.  
Profil kartı üzerindeki swipe animasyonu, match anının konfeti patlaması, locked mode overlay'i, chat composer'ın klavye davranışı — bunlar framework'ten değil, ince gesture + animation kontrolünden ortaya çıkar.

Custom StyleSheet yaklaşımı:
- Render perf'i tahmin edilebilir (shadow DOM / style runtime yok).
- Animasyonlar `react-native-reanimated` worklet'leriyle native thread'de çalışır; JS-driven bridge overhead yok.
- Design token'lar TypeScript ile tam type-safe; refactor otomatik.
- Üçüncü taraf bileşen kütüphanesinin patch/upgrade riskini taşımaz.

---

## Neden NativeWind / Tamagui / React Native Paper İlk Kurulumda Yok?

### NativeWind
- Tailwind class'larının native StyleSheet'e derlenmesi SDK versiyon kırılganlığı yaratır.
- Class-based API dating app kartları, animasyon state'leri ve gesture feedback için yeterince expressive değil.
- Heroku bench: basit ekranlarda performans kazancı yokken karmaşık animasyon senaryolarında ek debug yükü.

### Tamagui
- Güçlü compile-time optimizasyonu var; ancak SDK 56 / React 19 / Reanimated 4 stack'iyle uyumluluk henüz test edilmedi.
- Kendi tema sistemi ve token mimarisine lock-in; dating app'in token'larını Tamagui'ye adapte etmek yerine kendi token'larımızı yazmak daha verimli.
- Olgunlaşmakta olan ekosistem; beta değişiklikleri iterasyon hızını düşürebilir.

### React Native Paper (Material Design)
- Material Design dili iOS 26 ve Android UI 8.5'in native hissiyatıyla çelişiyor.
- Kart, avatar, chip, bottom sheet gibi primitive'leri zaten kendimiz yazıyoruz; ek bağımlılık gerekmez.

**Bu karar UI kalitesinden taviz değildir.** Aksine, dating app'e özel premium kontrol için bilinçli bir tercihtir.

---

## Hangi UI Primitive'leri Yapılacak?

`components/ui/` altında hazır olan iskelet:

| Bileşen | Açıklama |
|---|---|
| `Screen` | SafeArea + KeyboardAvoidingView + scroll desteği |
| `AppText` | Variant tabanlı typography (TextVariant sistemi) |
| `Button` | primary / secondary / ghost / danger, loading state |
| `IconButton` | Accessible icon action, hitSlop, variant |
| `TextField` | label, error, hint, leftIcon, rightIcon, focus ring |
| `Card` | shadow, padding, onPress (pressable variant) |
| `Avatar` | expo-image, initials fallback, size sistemi |
| `Badge` | brand / success / warning / error / info |
| `EmptyState` | icon + title + description + CTA |
| `LoadingState` | ActivityIndicator, fullScreen mod |

---

## Hangi UI Altyapı Paketleri Kullanılacak?

| Paket | Ne İçin |
|---|---|
| `react-native-reanimated` | Swipe card animasyonu, match konfeti, modal/sheet transitions |
| `react-native-gesture-handler` | Pan gesture, swipe to like/pass, pull-to-refresh |
| `@gorhom/bottom-sheet` | Match ekranı, filtre sheet, profil detay |
| `expo-image` | Profil fotoğrafı; blurhash placeholder, cache, fade-in |
| `lucide-react-native` | SVG ikon seti, her ikon bağımsız import (tree-shaking) |

---

## Dating App İçin Kalite Barı

Aşağıdaki UI senaryolar "premium MVP" olarak tanımlandı; her biri özel tasarım gerektirir:

| Senaryo | Açıklama |
|---|---|
| **Profil Kartı** | Fotoğraf stack, blur/gradient overlay, isim/yaş/mesafe bilgisi, swipe gesture ile like/pass |
| **Match Animasyonu** | Konfeti veya particle, modal overlay, CTA (mesaj gönder / sonra) |
| **Locked Mode** | Aktif eşleşme varken keşfet ekranı blur/lock overlay; diğer profillere erişim engeli |
| **Chat Composer** | Keyboard-aware input, send button, emoji desteği, character limit göstergesi |
| **Bottom Sheet** | @gorhom/bottom-sheet — snap points, backdrop, handle, scroll içerik |
| **Modal** | Expo Router modal pattern veya custom modal overlay (confirm, alert, image viewer) |
| **Empty State** | Her liste/ekranda (no matches, no messages, no likes) illüstrasyonlu boş durum |
| **Error State** | Network hata, retry CTA, kullanıcı dostu mesaj |

---

## Tamagui / NativeWind Pivot Koşulu

Tamagui veya NativeWind, MVP tamamlandıktan sonra yalnızca şu koşulda değerlendirilir:

1. **Pair kararı** — tek bir kişinin unilateral kararı değil.
2. **Küçük pilot** — önce tek bir ekran (örn. Settings) üzerinde prototype.
3. **Kanıtlanmış fayda** — ölçülebilir hız artışı veya geliştirici deneyimi iyileşmesi.
4. **Uyumluluk testi** — Expo SDK + Reanimated + Gesture Handler stack'iyle tam uyum.

Bu koşullar sağlanmadan mevcut sistemden dönüş yapılmaz.
