# Teknik PRD: Guven ve Odak Odakli Yeni Nesil Flort Uygulamasi

## 1. Dokuman Amaci

Bu dokuman, kaynak PRD'de tarif edilen "aynı anda sadece tek aktif eslesme" kuralini merkeze alan dating app'in teknik gereksinimlerini tanimlar. Uygulama klasik dating app ozelliklerini desteklerken, kullanicilarin sonsuz kaydirma yerine guvenli ve tek kisiye odakli bir sohbet deneyimi yasamasini saglayacaktir.

Verilen ana teknoloji kararlari:

- Mobil uygulama: React Native Expo
- Backend ve veritabani: Supabase
- UI/UX hedefi: Android UI 8.5 ve iOS 26 ile uyumlu modern, native hissiyatli arayuz

Bu dokumanda bu uc karar disinda yeni bir teknoloji kesinlestirilmemistir. Ek teknoloji ihtiyaclari "Karar Bekleyen Teknolojiler" bolumunde soru olarak listelenmistir.

## 2. Urun Ozeti

Uygulama, kullanicilarin profil olusturup kesfet akisi uzerinden diger profilleri begenebildigi, karsilikli begeniyle eslesebildigi ve mesajlasabildigi bir flort uygulamasidir.

Uygulamanin fark yaratan cekirdek kurali:

- Bir kullanicinin ayni anda yalnizca bir aktif eslesmesi olabilir.
- Aktif eslesme basladiginda iki kullanici da kesfet havuzundan cikar.
- Aktif eslesme devam ederken kullanicilar yeni profil goremez, yeni begeni alamaz, yeni eslesme olusturamaz.
- Eslesme manuel olarak bitirildiginde veya belirlenen sessizlik suresi doldugunda iki kullanici tekrar havuza doner.

## 3. Hedefler

- Kullaniciya "karsi taraf su an sadece benimle ilgileniyor" guvenini vermek.
- Klasik dating app ozelliklerini eksiksiz sunmak: kayit, profil, fotograf, kesfet, begeni, eslesme, sohbet, bildirim, engelleme, sikayet, ayarlar.
- Supabase tarafinda tutarli, yarismaya dayanikli ve guvenli bir eslesme mekanizmasi kurmak.
- React Native Expo ile Android ve iOS'ta performansli, erisilebilir ve native davranan bir deneyim sunmak.
- Veritabani seviyesinde RLS, transaction, unique constraint ve RPC/Edge Function kontrolleriyle "tek aktif eslesme" kuralini ihlal edilemez hale getirmek.

## 4. Kapsam Disi

Ilk teknik PRD kapsaminda kesinlestirilmeyen veya sonraki faza birakilabilecek konular:

- Web uygulamasi
- Canli video gorusme
- AI destekli eslestirme modeli
- Ucretli abonelik ve odeme altyapisi
- Detayli CRM/admin paneli
- Sosyal medya ile gelismis entegrasyonlar

Bu alanlar urun stratejisine gore sonraki surumlerde eklenebilir.

## 5. Kullanici Rolleri

### 5.1 Misafir Kullanici

- Uygulamayi acar.
- Kayit/giris akisini gorur.
- Hesap olusturmadan kesfet veya sohbet kullanamaz.

### 5.2 Onboarding Kullanici

- Telefon/e-posta veya secilen auth yontemiyle hesap olusturur.
- Profil bilgilerini tamamlar.
- Fotograf yukler.
- Tercihlerini belirler.
- Guvenlik ve topluluk kurallarini kabul eder.

### 5.3 Aktif Havuz Kullanici

- Kesfet ekraninda profil gorur.
- Sag/sol kaydirma veya butonlarla begeni/gecme islemi yapar.
- Havuzda gorunurdur.
- Baska aktif havuz kullanicilari tarafindan gorulebilir.

### 5.4 Kilitli Kullanici

- Bir aktif eslesmesi vardir.
- Kesfet ekranina erisemez.
- Diger kullanicilarin havuzunda gorunmez.
- Sadece aktif eslesmesiyle sohbet edebilir.

### 5.5 Moderator/Admin

- Sikayetleri inceler.
- Profil ve mesaj iceriklerini denetler.
- Gerekirse kullaniciyi askıya alir, banlar veya icerigi kaldirir.

## 6. Cekirdek State Machine

Kullanici durumu teknik olarak `profiles.availability_state` alanindan takip edilmelidir.

Onerilen durumlar:

- `onboarding`: Profil tamamlanmadi.
- `active`: Kesfet havuzunda gorunebilir ve eslesmeye acik.
- `locked`: Aktif eslesmesi var, havuz disinda.
- `paused`: Kullanici kendi istegiyle hesabini gecici duraklatti.
- `banned`: Moderasyon nedeniyle kapatildi.
- `deleted`: Hesap silindi veya anonimlestirildi.

Kaynak PRD'deki `is_locked` ve `is_visible` alanlari dogrudan kullanilabilir, ancak state machine karmasiklastikca tek bir `availability_state` alaninin ana durum kaynagi olmasi daha sagliklidir. Geriye donuk okunabilirlik icin hesaplanan veya senkron tutulan alanlar su sekilde olabilir:

- `is_locked = availability_state = 'locked'`
- `is_visible = availability_state = 'active'`

## 7. Ana Kullanici Akislari

### 7.1 Kayit ve Onboarding

1. Kullanici uygulamayi acar.
2. Giris/kayit yontemini secer.
3. Supabase Auth ile kimlik dogrulama tamamlanir.
4. Kullanici profil bilgilerini girer:
   - Ad veya gorunen ad
   - Dogum tarihi
   - Cinsiyet
   - Ilgi duydugu cinsiyet/cinsiyetler
   - Konum izni veya manuel konum
   - Biyografi
   - Fotograf
   - Iliski niyeti
5. Profil tamamlaninca `availability_state = active` olur.
6. Kullanici kesfet ekranina yonlendirilir.

### 7.2 Kesfet ve Begenme

1. Aktif kullanici kesfet ekranini acar.
2. Uygulama sadece uygun profilleri getirir:
   - `availability_state = active`
   - kullanici kendisi degil
   - engellenmemis/sikayet nedeniyle gizlenmemis
   - daha once gecilmemis veya begenilmemis
   - tercih filtrelerine uygun
3. Kullanici profili begenir veya gecer.
4. Begenme isleminde sistem karsilikli begeni olup olmadigini kontrol eder.
5. Karsilikli begeni yoksa kullanici kesfetmeye devam eder.
6. Karsilikli begeni varsa aktif eslesme transaction icinde olusturulur.

### 7.3 Mutlak Odaklanma Modu: Eslesme ve Kilitlenme

Karsilikli begeni aninda backend atomik olarak su islemleri yapar:

1. Iki kullanicinin de hala `availability_state = active` oldugunu kontrol eder.
2. Iki kullanicinin da aktif eslesmesi olmadigini kontrol eder.
3. `matches` tablosunda `status = active` kaydi olusturur.
4. Iki kullanicinin profil durumunu `availability_state = locked` yapar.
5. `is_locked = true`, `is_visible = false` degerlerini senkronlar.
6. Sohbet odasini olusturur.
7. Iki kullaniciya match bildirimi gonderir.
8. Mobil uygulamada kesfet akisi kapatilir ve ozel sohbet odasi acilir.

Bu islemler mutlaka Supabase tarafinda transaction/RPC veya Edge Function uzerinden yapilmalidir. Sadece client tarafinda kontrol yeterli degildir.

### 7.4 Guvenli Sohbet

1. Kilitli kullanici uygulamayi actiginda ana ekran olarak aktif sohbeti gorur.
2. Mesajlasma Supabase Realtime ile anlik guncellenir.
3. Her mesaj veya anlamli etkilesimde `matches.last_interaction_at` guncellenir.
4. Kullanici sohbeti manuel bitirebilir, karsidakini engelleyebilir veya sikayet edebilir.
5. Aktif eslesme surerken kullanici kesfet ekranina girmeye calisirsa kilitli durum ekrani gosterilir.

### 7.5 Manuel Ayrilma

1. Kullanici sohbet ekraninda "Konusmayi Bitir" eylemini secer.
2. Onay modali acilir.
3. Onaydan sonra backend atomik olarak:
   - Aktif eslesmeyi `ended` yapar.
   - `ended_by_user_id` alanini doldurur.
   - `ended_reason = manual` yazar.
   - Iki kullaniciyi de `availability_state = active` durumuna alir.
   - `is_locked = false`, `is_visible = true` yapar.
4. Sohbet arsivlenir veya urun kararina gore iki taraftan da kaldirilir.
5. Iki kullanici tekrar kesfet havuzuna doner.

### 7.6 Sessizlik Nedeniyle Otomatik Ayrilma

1. Aktif eslesme olustugunda `last_interaction_at = matched_at` olur.
2. Belirlenen sure boyunca mesaj veya etkilesim olmazsa sistem eslesmeyi otomatik bitirir.
3. Varsayilan sure kaynak PRD'deki ornege uygun olarak 24 saat kabul edilebilir, ancak bu urun ayari olarak degistirilebilir olmalidir.
4. Backend periyodik gorev veya zamanlanmis fonksiyonla su kontrolu yapar:
   - `status = active`
   - `last_interaction_at < now() - timeout_duration`
5. Eslesme `expired` yapilir.
6. Iki kullanicinin kilidi acilir.
7. Iki kullaniciya sessizlik nedeniyle eslesmenin bittigi bildirilir.

## 8. Klasik Dating App Ozellikleri

### 8.1 Profil

- Fotograf galerisi
- Gorunen ad
- Yas
- Konum
- Bio
- Ilgi alanlari
- Iliski niyeti
- Boy, egitim, meslek gibi opsiyonel bilgiler
- Profil tamamlanma yuzdesi
- Profil onizleme

### 8.2 Tercihler ve Filtreler

- Yas araligi
- Maksimum mesafe
- Cinsiyet tercihi
- Iliski niyeti
- Temel profil kriterleri
- Daha once gecilen profilleri tekrar gosterme politikasinin belirlenmesi

### 8.3 Kesfet

- Kart tabanli profil gosterimi
- Sag kaydir: begen
- Sol kaydir: gec
- Geri alma: ilk surumde opsiyonel
- Profil detayina bakma
- Gunluk begeni limiti: urun kararina bagli
- Kilitliyken kesfet kapali durum ekrani

### 8.4 Eslesme

- Karsilikli begeni kontrolu
- Tek aktif eslesme kuralini veritabani seviyesinde enforce etme
- Match aninda animasyon ve sohbet yonlendirmesi
- Match gecmisi icin arsiv mantigi

### 8.5 Sohbet

- Text mesaj
- Mesaj okundu/gonderildi durumu
- Yaziyor gostergesi
- Mesaj zaman damgasi
- Mesaj silme: opsiyonel
- Fotograf/gif/sesli mesaj: karar bekleyen ek kapsam
- Sikayet ve engelleme
- Sohbeti bitirme

### 8.6 Bildirimler

- Yeni match bildirimi
- Yeni mesaj bildirimi
- Sessizlik suresi dolmak uzere hatirlatma
- Eslesme otomatik bitti bildirimi
- Sikayet/moderasyon bildirimleri

### 8.7 Guvenlik ve Moderasyon

- Kullanici engelleme
- Kullanici sikayet etme
- Fotograf ve profil metni moderasyonu
- Mesaj sikayeti
- Ban/askiya alma
- Supheli davranis sinyalleri
- Yas dogrulama politikasinin belirlenmesi

### 8.8 Ayarlar

- Profil duzenleme
- Tercihleri duzenleme
- Bildirim ayarlari
- Hesabi duraklatma
- Hesabi silme
- Gizlilik ve KVKK/GDPR metinleri
- Topluluk kurallari

## 9. Mobil Uygulama Mimarisi

### 9.1 React Native Expo Yapisi

Onerilen uygulama katmanlari:

- `app/`: Route/screen yapisi
- `components/`: Tekrar kullanilabilir UI bilesenleri
- `features/`: Domain bazli ozellik modulleri
- `lib/supabase/`: Supabase client, auth helper, RPC wrapper
- `lib/state/`: Global state yonetimi
- `lib/validation/`: Form ve payload validasyonlari
- `theme/`: Renk, spacing, typography, platform tokenlari
- `types/`: Supabase ve app TypeScript tipleri

Expo tarafinda hedeflenen kabiliyetler:

- EAS Build ile Android ve iOS build
- Expo Notifications veya secilecek bildirim altyapisi
- Expo Image Picker veya secilecek medya secim altyapisi
- Secure storage ihtiyaci icin secilecek paket
- Deep link/universal link stratejisi

### 9.2 Navigasyon

Kesin navigasyon kutuphanesi karar bekleyen teknoloji olarak sorulmalidir. Varsayilan mimari ihtiyac:

- Auth stack
- Onboarding stack
- Main stack
- Discover screen
- Locked match/chat screen
- Profile edit screen
- Settings screen
- Report/block modal flow

Kullanici durumuna gore route guard:

- `onboarding`: Onboarding ekranlari
- `active`: Kesfet ana ekrani
- `locked`: Aktif sohbet ana ekrani
- `paused`: Hesap duraklatildi ekrani
- `banned`: Moderasyon ekrani

### 9.3 Client State

Client tarafinda tutulacak temel state:

- Auth session
- Aktif profil
- Kullanici availability state
- Aktif match
- Aktif sohbet mesajlari
- Kesfet kart listesi
- Bildirim izin durumu
- Uygulama konfig ayarlari

Kalici ve hassas olmayan state local storage'da tutulabilir. Auth token ve hassas bilgiler icin guvenli saklama karari verilmelidir.

## 10. UI/UX Gereksinimleri

### 10.1 Genel Tasarim Ilkeleri

- Uygulama ilk ekranda dogrudan kullanilabilir deneyim sunmali; pazarlama sayfasi gibi hissettirmemeli.
- Dating app enerjisi tasimali, ancak sonsuz secenek ve oyunlastirma hissini azaltan sakin bir dil kullanmali.
- Kartlar sade, okunabilir ve fotograf odakli olmali.
- Kilitli modda kullaniciya cezalandirilmis hissi degil, "ozel alan" hissi verilmeli.
- Butonlar, formlar ve modal akislari Android ve iOS platform davranislarina yakin olmali.
- Metinler kisa, net ve guven verici olmali.

### 10.2 Android UI 8.5 ve iOS 26 Uyum Notlari

Bu hedefler teknik olarak platforma duyarlı tasarim tokenlariyla ele alinmalidir:

- Android ve iOS icin farkli shadow/elevation tokenlari
- Platforma uygun bottom sheet, action sheet ve modal davranislari
- iOS icin guvenli alanlara tam uyum
- Android icin geri tusu ve gesture davranislarina tam uyum
- Dynamic type/font scaling destekleri
- Light/dark mode icin tema altyapisi
- Minimum touch target: 44x44 pt/dp
- Kamera, fotograf, konum ve bildirim izinleri icin native izin ekranlariyla uyumlu ara ekranlar

### 10.2.1 UI System ve Kalite Bari

MVP surumunde UI "gecici prototip" kalitesinde degil, ilk kullanici testine ve store review surecine uygun premium seviyede olmalidir. Bu nedenle UI karari sadece styling kutuphanesi secimi olarak degil, tasarim sistemi ve native hissiyat kalitesi olarak ele alinmalidir.

Baslangic UI yaklasimi:

- Ana styling yaklasimi: React Native `StyleSheet` + typed theme tokenlari.
- UI component sistemi: uygulamaya ozel custom primitive ve compound componentler.
- NativeWind/Tamagui/React Native Paper ilk kurulumda ana UI sistemi olarak kullanilmaz.
- Bu karar UI kalitesinden taviz anlamina gelmez; aksine dating app'e ozel fotograf karti, match animasyonu, kilitli mod, sohbet composer ve guvenlik modal davranislarinin daha kontrollu tasarlanmasini saglar.

Beklenen temel UI primitive'leri:

- `Screen`
- `AppText`
- `Button`
- `IconButton`
- `TextField`
- `Card`
- `Avatar`
- `Badge`
- `Sheet`
- `Modal`
- `EmptyState`
- `LoadingState`

Kaliteli native deneyim icin kullanilmasi planlanan altyapi paketleri:

- Gesture ve kart etkilesimleri icin `react-native-gesture-handler`
- Akici animasyonlar icin `react-native-reanimated`
- Bottom sheet davranisi icin `@gorhom/bottom-sheet`
- Fotograf performansi icin `expo-image`
- Ikonlar icin `lucide-react-native`

UI kalite kriterleri:

- Profil kartlari fotograf odakli, net hiyerarsili ve tek elle kullanima uygun olmalidir.
- Match olusumu ve locked mode gecisi urunun "tek kisiye odaklanma" vaadini hissettirmelidir.
- Bos durumlar, hata durumlari ve izin reddi durumlari guven verici ve kisa metinlerle ele alinmalidir.
- Tum ortak componentlerde light/dark tema, minimum touch target, font scaling ve platform shadow/elevation farklari hesaba katilmalidir.
- UI componentleri ic ice kart yapisindan ve asiri dekoratif gradient/orb kullanimindan kacinmalidir.

Tamagui veya NativeWind, MVP sirasinda yalnizca belirgin hiz veya kalite avantaji kanitlanirsa Pair karariyla yeniden degerlendirilir. Boyle bir pivot yapilirsa once kucuk bir ekranda pilot uygulanir, sonra tum UI sistemine yayilip yayilmamasi kararlastirilir.

### 10.3 Ana Ekranlar

Auth:

- Splash/loading
- Giris
- Kayit
- OTP veya secilen dogrulama ekrani

Onboarding:

- Temel bilgiler
- Fotograf yukleme
- Ilgi alanlari
- Tercihler
- Guvenlik/topluluk kurallari

Kesfet:

- Profil karti
- Profil detay
- Begen/gec eylemleri
- Bos havuz durumu
- Kilitli mod yonlendirme durumu

Match:

- Match animasyonu
- Ozel sohbet odasina gecis

Sohbet:

- Mesaj listesi
- Composer
- Yaziyor gostergesi
- Sohbeti bitir
- Sikayet/engelle
- Sessizlik suresi uyarisi

Ayarlar:

- Profil duzenleme
- Tercihler
- Bildirimler
- Gizlilik
- Hesap duraklatma/silme

## 11. Supabase Veri Modeli

### 11.1 `profiles`

Kullanici profilinin ana tablosu.

Alanlar:

- `id uuid primary key references auth.users(id)`
- `display_name text not null`
- `birth_date date not null`
- `gender text not null`
- `interested_in text[] not null`
- `bio text`
- `location geography` veya lat/lng alanlari
- `city text`
- `country text`
- `availability_state text not null default 'onboarding'`
- `is_locked boolean not null default false`
- `is_visible boolean not null default false`
- `profile_completed_at timestamptz`
- `last_active_at timestamptz`
- `created_at timestamptz default now()`
- `updated_at timestamptz default now()`

Kisitlar:

- `availability_state in ('onboarding', 'active', 'locked', 'paused', 'banned', 'deleted')`
- `is_locked` ve `is_visible` alanlari state ile tutarli olmali.

### 11.2 `profile_photos`

- `id uuid primary key`
- `user_id uuid references profiles(id)`
- `storage_path text not null`
- `sort_order int not null`
- `is_primary boolean default false`
- `moderation_status text default 'pending'`
- `created_at timestamptz default now()`

### 11.3 `profile_prompts`

- `id uuid primary key`
- `user_id uuid references profiles(id)`
- `prompt_key text not null`
- `answer text not null`
- `created_at timestamptz default now()`
- `updated_at timestamptz default now()`

### 11.4 `preferences`

- `user_id uuid primary key references profiles(id)`
- `min_age int`
- `max_age int`
- `max_distance_km int`
- `interested_genders text[]`
- `relationship_goals text[]`
- `created_at timestamptz default now()`
- `updated_at timestamptz default now()`

### 11.5 `likes`

Begenme ve gecme aksiyonlarini tutar.

- `id uuid primary key`
- `from_user_id uuid references profiles(id)`
- `to_user_id uuid references profiles(id)`
- `action text not null`
- `created_at timestamptz default now()`

Kisitlar:

- `action in ('like', 'pass')`
- Unique: `(from_user_id, to_user_id)`
- `from_user_id <> to_user_id`

### 11.6 `matches`

Aktif ve gecmis eslesmeleri tutar.

- `id uuid primary key`
- `user_a_id uuid references profiles(id)`
- `user_b_id uuid references profiles(id)`
- `status text not null default 'active'`
- `matched_at timestamptz default now()`
- `last_interaction_at timestamptz default now()`
- `ended_at timestamptz`
- `ended_by_user_id uuid references profiles(id)`
- `ended_reason text`
- `created_at timestamptz default now()`
- `updated_at timestamptz default now()`

Kisitlar:

- `status in ('active', 'ended', 'expired', 'blocked', 'reported')`
- `ended_reason in ('manual', 'timeout', 'blocked', 'moderation')`
- `user_a_id <> user_b_id`
- Aktif eslesme icin kullanici basina tek kayit kuralini enforce eden partial unique index gerekir.

Onerilen index mantigi:

- `unique active_match_user_a on matches(user_a_id) where status = 'active'`
- `unique active_match_user_b on matches(user_b_id) where status = 'active'`

Bu iki index tek basina kullanici iki farkli kolonda gecerken yeterli olmayabilir. Daha saglam uygulama icin:

- `active_match_participants(match_id, user_id)` ara tablosu kullanilabilir.
- Bu tabloda `unique(user_id) where status = 'active'` benzeri bir constraint kurulabilir.
- Eslesme olusturma mutlaka transaction icinde yapilmalidir.

### 11.7 `match_participants`

Tek aktif eslesme kuralini daha guvenli enforce etmek icin onerilir.

- `match_id uuid references matches(id)`
- `user_id uuid references profiles(id)`
- `status text not null default 'active'`
- `created_at timestamptz default now()`

Kisitlar:

- Primary key: `(match_id, user_id)`
- Partial unique index: `unique(user_id) where status = 'active'`

### 11.8 `messages`

- `id uuid primary key`
- `match_id uuid references matches(id)`
- `sender_id uuid references profiles(id)`
- `body text not null`
- `message_type text not null default 'text'`
- `read_at timestamptz`
- `created_at timestamptz default now()`
- `deleted_at timestamptz`

Kisitlar:

- Sadece aktif match katilimcilari mesaj yazabilir.
- `message_type in ('text', 'image', 'system')`

### 11.9 `blocks`

- `id uuid primary key`
- `blocker_id uuid references profiles(id)`
- `blocked_id uuid references profiles(id)`
- `created_at timestamptz default now()`

Kisitlar:

- Unique: `(blocker_id, blocked_id)`

### 11.10 `reports`

- `id uuid primary key`
- `reporter_id uuid references profiles(id)`
- `reported_user_id uuid references profiles(id)`
- `match_id uuid references matches(id)`
- `message_id uuid references messages(id)`
- `reason text not null`
- `details text`
- `status text default 'open'`
- `created_at timestamptz default now()`

### 11.11 `devices`

Push notification tokenlari icin.

- `id uuid primary key`
- `user_id uuid references profiles(id)`
- `platform text not null`
- `push_token text not null`
- `created_at timestamptz default now()`
- `updated_at timestamptz default now()`

### 11.12 `app_config`

Urun ayarlarini kod deploy etmeden degistirmek icin.

- `key text primary key`
- `value jsonb not null`
- `updated_at timestamptz default now()`

Ornek:

- `match_timeout_hours = 24`
- `daily_like_limit = null`
- `min_profile_photos = 2`

## 12. Backend Mantigi

### 12.1 Kritik RPC/Function'lar

`complete_onboarding(profile_payload)`:

- Profilin zorunlu alanlarini validate eder.
- Profil tamamlaninca kullaniciyi `active` hale getirir.

`get_discover_feed(filters)`:

- Sadece uygun ve gorunur profilleri dondurur.
- Engellenmis, raporlanmis, daha once aksiyon alinmis profilleri dislar.
- Kilitli kullanici icin bos sonuc ve kilitli durum bilgisi dondurur.

`submit_profile_action(to_user_id, action)`:

- Kullanici aktif mi kontrol eder.
- `like` veya `pass` kaydi olusturur.
- `like` icin karsilikli begeni varsa `create_match_transaction` calistirir.

`create_match_transaction(user_a_id, user_b_id)`:

- Iki kullaniciyi row-level lock ile kilitler.
- Iki kullanicinin da `active` oldugunu dogrular.
- Aktif match olmadigini dogrular.
- Match ve participants kayitlarini olusturur.
- Iki profili `locked` hale getirir.
- Sohbeti baslatir.

`end_match(match_id, reason)`:

- Istegi yapan kullanicinin match katilimcisi oldugunu dogrular.
- Match'i bitirir.
- Participants durumunu kapatir.
- Iki kullaniciyi uygun durumdaysa `active` hale getirir.
- Sistem mesajlari ve bildirimleri uretir.

`expire_inactive_matches()`:

- Timeout suresini `app_config` veya environment uzerinden okur.
- Inaktif aktif matchleri bulur.
- `end_match` mantigiyla `expired` yapar.

`block_user(blocked_user_id)`:

- Block kaydi olusturur.
- Varsa aktif match'i `blocked` yapar.
- Kullanici kilitlerini cozer.

`report_user(payload)`:

- Report kaydi olusturur.
- Gerekiyorsa aktif match'i kapatir veya moderator kuyruguna alir.

### 12.2 Transaction ve Race Condition Gereksinimleri

Tek aktif eslesme kuralinda en kritik risk, iki kullanicinin ayni anda farkli kisilerle eslesmesidir. Bu nedenle:

- Match olusturma client tarafinda degil backend transaction icinde yapilmalidir.
- `profiles` veya `match_participants` satirlari `select ... for update` mantigiyla kilitlenmelidir.
- Partial unique index ile user basina tek aktif match garanti edilmelidir.
- Her match olusturma denemesi idempotent veya guvenli hata dondurebilir olmalidir.
- Client, "profil az once musait degildi" gibi durumlari zarif bos durumla gostermelidir.

### 12.3 RLS Politikasi

Temel RLS kurallari:

- Kullanici kendi profilini okuyabilir ve guncelleyebilir.
- Kesfet feed'i dogrudan tablo query'siyle degil RPC ile verilmelidir.
- Kullanici sadece aktif match katilimcisi oldugu mesajlari okuyabilir.
- Kullanici sadece aktif match katilimcisi ise mesaj yazabilir.
- Kullanici kendi likes kayitlarini olusturabilir, ancak match'i dogrudan client olusturamaz.
- Kullanici sadece kendi block/report kayitlarini olusturabilir.
- Admin/moderator rolleri ayrica service role veya custom claims ile yetkilendirilmelidir.

## 13. Storage Gereksinimleri

Supabase Storage kullanilacaksa:

- Bucket: `profile-photos`
- Private veya public kararinin gizlilik etkisi degerlendirilmelidir.
- Fotograflar kullanici klasoru altinda saklanmalidir: `{user_id}/{photo_id}.jpg`
- Upload sonrasi `profile_photos` kaydi olusturulmalidir.
- Moderasyon tamamlanmadan fotograf kesfet havuzunda gosterilmeyebilir.
- Thumbnail/resize stratejisi karar bekleyen teknoloji olarak netlestirilmelidir.

## 14. Realtime Gereksinimleri

Supabase Realtime kullanilacak alanlar:

- Aktif match degisimi
- Yeni mesajlar
- Mesaj okundu bilgisi
- Typing indicator icin presence veya broadcast
- Kullanici kilit durumunun client tarafinda anlik guncellenmesi

Realtime abonelikleri ekran odakli acilip kapatilmali, background'da gereksiz dinleme yapilmamalidir.

## 15. Bildirim Gereksinimleri

Bildirim tipleri:

- `match_created`
- `message_received`
- `match_timeout_warning`
- `match_expired`
- `match_ended`
- `moderation_update`

Bildirim gonderimi backend'den tetiklenmelidir. Client sadece cihaz tokenini kaydetmelidir.

Karar bekleyen konu:

- Expo Push Notifications yeterli mi, yoksa FCM/APNs dogrudan entegrasyon mu istenecek?

## 16. Guvenlik, Gizlilik ve Uyumluluk

Minimum gereksinimler:

- 18 yas alti kaydi engellenmeli.
- RLS tum kullanici verileri icin aktif olmali.
- Hassas profil bilgileri gereksiz yere client'a donmemeli.
- Silinen hesaplar icin anonimlestirme veya hard delete politikasi belirlenmeli.
- Kullanici konumu hassasiyetle saklanmali; hassas koordinat yerine yuvarlatilmis konum tercih edilebilir.
- Engellenen kullanicilar birbirini kesfet, sohbet ve profil goruntulemede gormemeli.
- Sikayet edilen icerikler moderator erisimine uygun sekilde saklanmali.
- KVKK/GDPR icin veri indirme ve silme talepleri planlanmali.

## 17. Performans Gereksinimleri

- Kesfet feed'i sayfali gelmelidir.
- Profil kartlari fotograf on-yukleme yapabilmelidir.
- Mesaj listesi sanallastirilmis veya performansli liste bileseniyle render edilmelidir.
- Ana ekran ilk acilis hedefi: 2 saniye altinda anlamli UI.
- Realtime abonelikleri minimum veriyle calismalidir.
- Sorgular icin indexler:
  - `profiles(availability_state)`
  - `likes(from_user_id, to_user_id)`
  - `matches(status)`
  - `messages(match_id, created_at)`
  - `match_participants(user_id, status)`

## 18. Analitik ve Olcumleme

Olculmesi gereken eventler:

- `sign_up_started`
- `sign_up_completed`
- `onboarding_completed`
- `profile_photo_uploaded`
- `discover_profile_viewed`
- `profile_liked`
- `profile_passed`
- `match_created`
- `chat_message_sent`
- `match_ended_manual`
- `match_ended_timeout`
- `user_blocked`
- `user_reported`
- `account_paused`
- `account_deleted`

Urun metrikleri:

- Onboarding tamamlama orani
- Gunluk aktif kullanici
- Begeniden match'e donusum
- Match sonrasi ilk mesaj orani
- Ortalama aktif match suresi
- Timeout ile biten match orani
- Manuel bitirme orani
- Sikayet orani

Analitik araci karar bekleyen teknoloji olarak sorulmalidir.

## 19. Test Stratejisi

### 19.1 Unit Test

- Validation fonksiyonlari
- State mapping
- Profil filtreleme helper'lari
- Zaman asimi hesaplamalari

### 19.2 Integration Test

- `submit_profile_action`
- `create_match_transaction`
- `end_match`
- `expire_inactive_matches`
- RLS politikalarinin dogru veri erisimi

### 19.3 Race Condition Testleri

- Ayni kullanicinin ayni anda iki farkli match olusturma denemesi
- Iki kullanicinin ayni anda birbirini begenmesi
- Match bitirilirken mesaj gonderme denemesi
- Timeout job calisirken manuel bitirme denemesi

### 19.4 E2E Test

- Kayit ve onboarding
- Kesfet ve begeni
- Match olusumu
- Kilitli modda kesfete erisim engeli
- Mesajlasma
- Manuel sohbet bitirme
- Timeout sonrasi havuza donme
- Engelleme ve sikayet

E2E araci karar bekleyen teknoloji olarak sorulmalidir.

## 20. Hata ve Bos Durumlar

Zarif ele alinmasi gereken durumlar:

- Kesfet havuzunda profil yok.
- Kullanici kilitli ama aktif match getirilemiyor.
- Match az once bitti, client hala sohbet ekraninda.
- Mesaj gonderilirken match kapanmis.
- Fotograf upload basarisiz.
- Konum izni reddedildi.
- Push notification izni reddedildi.
- Kullanici banned/paused/deleted durumuna alindi.

## 21. Kodlama Yol Haritasi ve Is Paketleri

Bu bolum, uygulama gelistirme sirasinda takip edilecek genel yapilacaklar listesi olarak kullanilacaktir. Maddeler `1.1`, `1.2`, `1.3` seklinde kucuk is paketlerine bolunmustur.

Iki kisilik vibe coding icin ana model:

### Model A: Dikey Bolunme (Ekran/Ozellik Bazli)

Uygulama teknik katmanlara gore degil, feature'lara gore bolunur. Bir feature'in sahibi o feature'i uctan uca tasir:

- UI ekranlari ve componentleri
- Navigasyon baglantilari
- Client state ve form logic'i
- Supabase tablo/RPC/RLS ihtiyaclari
- Realtime, storage veya notification baglantilari
- Test ve manuel dogrulama
- Vibe coding icin kullanilan feature prompt'lari ve notlari

Sahiplik etiketleri:

- `Feature sahibi`: Ilgili feature slice'i uctan uca sahiplenen kisi. Gercek kisi ismi calisma sirasinda ekip icinde belirlenir.
- `Pair`: Iki kisinin birlikte karar vermesi gereken ortak mimari, veri kontrati, race condition, release veya guvenlik isleri.

Onemli kural: "bir kisi frontend, diger kisi backend" gibi yatay bir ayrim yapilmaz. Ornegin Auth feature'ini alan kisi auth ekranlarini, Supabase Auth entegrasyonunu, ilgili RLS/RPC ihtiyaclarini ve testlerini birlikte tamamlar. Kesfet feature'ini alan kisi de ana sayfa/kesfet UI'ini, feed sorgusunu, like/pass logic'ini ve edge case'lerini birlikte tamamlar.

Feature sahibi kodlamaya baslamadan once kisa bir feature prompt/not hazirlamalidir:

- Feature'in amaci
- Ekranlar
- Supabase ihtiyaclari
- Kabul kriterleri
- Hata ve bos durumlar
- Test senaryolari

Ortak tablo, RLS veya RPC degisikligi baska feature'i etkiliyorsa degisiklik `Pair` olarak gozden gecirilmelidir.

### 21.1 Asama 1: Proje Kurulumu ve Teknik Kararlar

- `1.1` Karar bekleyen teknolojileri netlestir. Sahip: Pair. Cikti: navigasyon, state, UI, test, analitik ve bildirim kararlari yazili hale gelir.
- `1.2` Expo React Native projesini TypeScript ile olustur. Sahip: Pair. Cikti: calisan bos uygulama.
- `1.3` Supabase projesini ve local/remote ortam stratejisini kur. Sahip: Pair. Cikti: Supabase URL/key/env yapisi hazir olur.
- `1.4` Ortam degiskenlerini ayir. Sahip: Pair. Cikti: `.env.example`, development ve production degisken listesi.
- `1.5` Feature bazli klasor mimarisini olustur. Sahip: Pair. Cikti: `app`, `features/auth`, `features/discover`, `features/profile`, `features/match`, `features/chat`, `features/safety`, `lib`, `theme`, `types` yapisi.
- `1.6` Kod kalite araclarini kur. Sahip: Pair. Cikti: TypeScript check, lint, format ve temel test komutlari.
- `1.7` Tema tokenlarini baslat. Sahip: Pair. Cikti: renk, spacing, typography, radius, shadow/elevation tokenlari.
- `1.8` Supabase migration akisini belirle. Sahip: Pair. Cikti: migration dosyalari ve calistirma komutlari netlesir.
- `1.9` Vibe coding calisma kuralini yaz. Sahip: Pair. Cikti: feature sahibi, prompt notu, branch/commit, review ve entegrasyon kurallari netlesir.
- `1.10` UI system kararini ve kalite barini yaz. Sahip: Pair. Cikti: `docs/decisions/0002-ui-system.md` icinde custom design system, temel component primitive'leri, NativeWind/Tamagui kullanmama gerekcesi, UI altyapi paketleri ve premium MVP kalite kriterleri netlesir.

### 21.2 Asama 2: Ortak Supabase Veri Modeli ve Guvenlik Temeli

- `2.1` Ortak database sema taslagini kesinlestir. Sahip: Pair. Cikti: feature sahipleri hangi tabloya dokunacagini bilir.
- `2.2` `profiles`, `profile_photos`, `profile_prompts`, `preferences` tablolarini olustur. Sahip: Auth/Profile feature sahibi. Cikti: Auth/Profile feature'lari icin temel sema.
- `2.3` `likes`, `matches`, `match_participants`, `messages` tablolarini olustur. Sahip: Discover/Match/Chat feature sahibi. Cikti: Discover/Match/Chat feature'lari icin temel sema.
- `2.4` `blocks`, `reports`, `devices`, `app_config` tablolarini olustur. Sahip: Safety/Notification feature sahibi. Cikti: safety, notification ve app ayarlari icin sema.
- `2.5` Kritik index ve constraintleri ekle. Sahip: Pair. Cikti: kullanici basina tek aktif match DB seviyesinde korunur.
- `2.6` Ilk RLS politikalarini yaz. Sahip: Pair. Cikti: kullanici sadece yetkili oldugu verileri okuyup yazabilir.
- `2.7` Storage bucket ve foto erisim politikasini kur. Sahip: Auth/Profile feature sahibi. Cikti: profil fotografi upload altyapisi.
- `2.8` Seed/test kullanicilari hazirla. Sahip: Discover/Match feature sahibi. Cikti: gelistirme sirasinda kesfet ve match test edilebilir.
- `2.9` Supabase TypeScript tiplerini uret ve client'a bagla. Sahip: Pair. Cikti: tum feature'larda tipli DB erisimi.

### 21.3 Asama 3: Feature Slice - Auth ve Onboarding

Sahip: `Feature sahibi`

- `3.1` Auth feature prompt/notunu hazirla. Cikti: ekranlar, Supabase ihtiyaclari, kabul kriterleri ve testler netlesir.
- `3.2` Splash ve session kontrol akisini kur. Cikti: kullanici durumuna gore dogru ekrana yonlendirme.
- `3.3` Giris/kayit ekranlarini yap. Cikti: Supabase Auth ile calisan temel auth.
- `3.4` Onboarding temel bilgi ekranlarini yap. Cikti: ad, dogum tarihi, cinsiyet ve niyet bilgileri alinabilir.
- `3.5` Fotograf yukleme ekranini yap. Cikti: kullanici profil fotografi yukleyebilir.
- `3.6` Tercih ve filtre onboarding ekranini yap. Cikti: yas, mesafe, cinsiyet tercihi kaydedilebilir.
- `3.7` `complete_onboarding` RPC/function mantigini yaz. Cikti: profil tamamlaninca kullanici `active` olur.
- `3.8` Onboarding route guard'larini bagla. Cikti: eksik profilli kullanici kesfete gecemez.
- `3.9` Auth/onboarding hata ve bos durumlarini tamamla. Cikti: upload, izin ve validasyon hatalari anlasilir gosterilir.
- `3.10` Auth/onboarding manuel test listesini calistir. Cikti: yeni kullanici kayit olup aktif hale gelebilir.

### 21.4 Asama 4: Feature Slice - Ana Sayfa ve Kesfet

Sahip: `Feature sahibi`

- `4.1` Discover feature prompt/notunu hazirla. Cikti: ana sayfa, listeleme, kesfet ve bos durumlar netlesir.
- `4.2` Auth sonrasi ana app shell ve temel navigasyonu kur. Cikti: authenticated kullanici ana ekrana gecer.
- `4.3` `get_discover_feed` RPC/function mantigini yaz. Cikti: sadece uygun ve gorunur profiller gelir.
- `4.4` Kesfet kart UI'ini yap. Cikti: fotograf odakli profil karti.
- `4.5` Profil detay modal/sayfasini yap. Cikti: kullanici karttan detaylara inebilir.
- `4.6` Like/pass aksiyonlarini client ve backend'e bagla. Cikti: `likes` tablosuna guvenli aksiyon yazilir.
- `4.7` Bos havuz, filtre sonucu yok ve hata ekranlarini yap. Cikti: kesfet akisi bosken uygulama guvenli davranir.
- `4.8` Kilitli kullanici icin kesfet engelini ekle. Cikti: `locked` kullanici profil gormez.
- `4.9` Kesfet performansini iyilestir. Cikti: sayfali veri, fotograf on-yukleme ve akici kart gecisi.
- `4.10` Kesfet manuel test listesini calistir. Cikti: aktif kullanici profilleri gorur, begenir ve gecer.

### 21.5 Asama 5: Feature Slice - Profil ve Ayarlar

Sahip: `Feature sahibi`

- `5.1` Profile/settings feature prompt/notunu hazirla. Cikti: profil duzenleme ve ayar kapsamı netlesir.
- `5.2` Profil onizleme ekranini yap. Cikti: kullanici kendi profilini kesfette gorunecegi gibi gorebilir.
- `5.3` Profil duzenleme ekranini yap. Cikti: temel profil alanlari guncellenebilir.
- `5.4` Fotograf siralama/silme/ana fotograf secme akislarini yap. Cikti: profil galerisi yonetilebilir.
- `5.5` Tercihleri duzenleme ekranini yap. Cikti: kesfet filtreleri sonradan degistirilebilir.
- `5.6` Hesap duraklatma ve tekrar aktif etme mantigini kur. Cikti: `paused` durumundaki kullanici havuzda gorunmez.
- `5.7` Hesap silme veya silme talebi akisini tanimla. Cikti: gizlilik politikasina uygun hesap kapatma davranisi.
- `5.8` Gizlilik, topluluk kurallari ve yardim ekranlarini ekle. Cikti: temel yasal/guvenlik sayfalari.
- `5.9` Profil ve ayarlar manuel test listesini calistir. Cikti: kullanici profilini ve tercihlerini duzenleyebilir.

### 21.6 Asama 6: Mutlak Odaklanma Modu ve Match Kilidi

- `6.1` Match/locked mode feature prompt/notunu hazirla. Sahip: Pair. Cikti: tek aktif match kuralinin tum kabul kriterleri netlesir.
- `6.2` `submit_profile_action` RPC/function mantigini tamamla. Sahip: Discover/Match feature sahibi. Cikti: like sonrasi match kontrolu backend'de yapilir.
- `6.3` `create_match_transaction` mantigini yaz. Sahip: Pair. Cikti: iki kullanici atomik olarak `locked` duruma gecer.
- `6.4` `match_participants` uzerinden tek aktif match constraintini test et. Sahip: Pair. Cikti: ayni kullanici icin ikinci aktif match olusmaz.
- `6.5` Match olustu ekranini yap. Sahip: Discover/Match feature sahibi. Cikti: kullanici match oldugunu anlar ve sohbete yonlenir.
- `6.6` Kullanici state senkronizasyonunu bagla. Sahip: Discover/Match feature sahibi. Cikti: app acilisinda `active` veya `locked` durum dogru okunur.
- `6.7` Kilitli mod ana ekranini yap. Sahip: Discover/Match feature sahibi. Cikti: kullanici aktif sohbetine odaklanan ekrani gorur.
- `6.8` Race condition testlerini yaz. Sahip: Pair. Cikti: ayni anda birden fazla match olusma riski test edilir.
- `6.9` Match bitince havuza donus senaryosunu dogrula. Sahip: Pair. Cikti: iki taraf da dogru sekilde `active` olur.

### 21.7 Asama 7: Feature Slice - Sohbet

- `7.1` Chat feature prompt/notunu hazirla. Sahip: Chat feature sahibi. Cikti: sohbet ekranlari, realtime ve kapanis senaryolari netlesir.
- `7.2` Mesaj RLS politikalarini netlestir. Sahip: Chat feature sahibi. Cikti: sadece aktif match katilimcilari mesaj okuyup yazabilir.
- `7.3` Sohbet ekranini yap. Sahip: Chat feature sahibi. Cikti: mesaj listesi ve mesaj yazma alani.
- `7.4` Mesaj gonderme backend/client baglantisini kur. Sahip: Chat feature sahibi. Cikti: mesaj yazildiginda `last_interaction_at` guncellenir.
- `7.5` Supabase Realtime mesaj aboneligini ekle. Sahip: Chat feature sahibi. Cikti: yeni mesajlar anlik gorunur.
- `7.6` Okundu bilgisi MVP kapsaminda gerekiyorsa ekle. Sahip: Pair. Cikti: `read_at` davranisi netlesir.
- `7.7` Yaziyor gostergesi gerekiyorsa presence/broadcast ile ekle. Sahip: Pair. Cikti: typing davranisi calisir.
- `7.8` Manuel "Konusmayi Bitir" akisini yap. Sahip: Chat feature sahibi. Cikti: match kapanir, iki kullanici havuza doner.
- `7.9` Sohbet icinden engelleme ve sikayet giris noktalarini ekle. Sahip: Chat feature sahibi. Cikti: kullanici sohbetten guvenlik aksiyonlarina ulasir.
- `7.10` Chat manuel test listesini calistir. Sahip: Chat feature sahibi. Cikti: aktif match katilimcilari mesajlasabilir.

### 21.8 Asama 8: Feature Slice - Guvenlik, Timeout ve Bildirimler

- `8.1` Safety/notification feature prompt/notunu hazirla. Sahip: Safety/Notification feature sahibi. Cikti: block, report, timeout ve bildirim senaryolari netlesir.
- `8.2` Report kayit ve listeleme mantigini tamamla. Sahip: Safety/Notification feature sahibi. Cikti: sikayetler takip edilebilir.
- `8.3` Block davranisini feed/chat sorgularina uygula. Sahip: Safety/Notification feature sahibi. Cikti: engellenen kullanicilar birbirini gormez.
- `8.4` `app_config.match_timeout_hours` ayarini ekle. Sahip: Safety/Notification feature sahibi. Cikti: timeout suresi kod deploy etmeden degisebilir.
- `8.5` `expire_inactive_matches` fonksiyonunu yaz. Sahip: Safety/Notification feature sahibi. Cikti: sessiz kalan matchler otomatik kapanir.
- `8.6` Zamanlanmis gorev mekanizmasini kur. Sahip: Safety/Notification feature sahibi. Cikti: timeout kontrolu periyodik calisir.
- `8.7` Timeout yaklasiyor uyarisi icin kural tanimla. Sahip: Pair. Cikti: gerekiyorsa kullaniciya hatirlatma gonderilir.
- `8.8` Push token kayit akisini yap. Sahip: Safety/Notification feature sahibi. Cikti: cihaz tokenlari `devices` tablosuna kaydedilir.
- `8.9` Yeni match ve yeni mesaj bildirimlerini bagla. Sahip: Pair. Cikti: backend tetiklemeli temel bildirimler calisir.
- `8.10` Match bitti/expired bildirimlerini bagla. Sahip: Pair. Cikti: kullanici durum degisiminden haberdar olur.
- `8.11` App resume oldugunda state yenilemeyi ekle. Sahip: Safety/Notification feature sahibi. Cikti: background sonrasi kilit/match durumu dogru gorunur.
- `8.12` Safety/timeout/bildirim manuel test listesini calistir. Sahip: Safety/Notification feature sahibi. Cikti: guvenlik ve timeout akislarinda temel sorun kalmaz.

### 21.9 Asama 9: Entegrasyon, Test ve Kalite

- `9.1` Feature entegrasyon gunu yap. Sahip: Pair. Cikti: Auth, Discover, Profile, Match, Chat ve Safety akislarinin birbirine baglantisi dogrulanir.
- `9.2` Fotograf/profil moderasyon statuslerini UI'a yansit. Sahip: Profile feature sahibi. Cikti: pending/rejected durumlari anlasilir olur.
- `9.3` Kritik unit testleri yaz. Sahip: Pair. Cikti: validation, state mapping ve timeout hesaplari test edilir.
- `9.4` Kritik integration testleri yaz. Sahip: Pair. Cikti: match create/end/expire ve RLS davranisi test edilir.
- `9.5` E2E smoke test akislarini hazirla. Sahip: Pair. Cikti: onboarding, discover, match, chat, end match test edilir.
- `9.6` Accessibility ve platform polish yap. Sahip: Feature sahipleri. Cikti: iOS/Android dokunma, safe area, font scaling kontrolleri.
- `9.7` Performans ve realtime abonelik kontrolu yap. Sahip: Feature sahipleri. Cikti: gereksiz dinleme, yavas sorgu ve render sorunlari azalir.
- `9.8` Ortak bug bash yap. Sahip: Pair. Cikti: P0/P1 hatalar listelenir ve kapanir.

### 21.10 Asama 10: Beta Hazirlik ve Release

- `10.1` App icon, splash ve temel marka varliklarini hazirla. Sahip: Feature sahibi. Cikti: build kimligi tamamlanir.
- `10.2` EAS build profillerini kur. Sahip: Pair. Cikti: development, preview ve production build alinabilir.
- `10.3` Supabase staging/production ayrimini netlestir. Sahip: Pair. Cikti: test verisi ve canli veri ayrilir.
- `10.4` Gizlilik metinleri ve store izin aciklamalarini hazirla. Sahip: Pair. Cikti: konum, fotograf ve bildirim izinleri aciklanir.
- `10.5` Internal beta build dagit. Sahip: Pair. Cikti: iki kisi ve yakin test grubu uygulamayi deneyebilir.
- `10.6` Beta bug listesini onceliklendir. Sahip: Pair. Cikti: P0/P1/P2 hata listesi.
- `10.7` Release checklistini tamamla. Sahip: Pair. Cikti: MVP kabul kriterleri tek tek dogrulanir.

### 21.11 Asama 11: MVP Sonrasi Gelistirmeler

- `11.1` Gelismis moderasyon paneli veya admin arayuzu planla. Sahip: Pair.
- `11.2` Okundu/yaziyor/gorsel mesaj gibi chat kalitesi ozelliklerini genislet. Sahip: Pair.
- `11.3` Profil dogrulama veya guven rozeti ekle. Sahip: Pair.
- `11.4` Analitik dashboard kur. Sahip: Pair.
- `11.5` Ucretli ozellikler ve abonelik mimarisini tasarla. Sahip: Pair.
- `11.6` AI destekli profil iyilestirme veya sohbet onerilerini degerlendir. Sahip: Pair.

### 21.12 Her Is Paketi Icin Definition of Done

Bir is paketi tamamlandi sayilmak icin:

- Ilgili ekran, function veya migration calisir durumda olmalidir.
- Hata ve bos durumlar en az temel seviyede ele alinmalidir.
- Feature sahibi, o feature'in UI + logic + Supabase ihtiyaclarini birlikte tamamlamalidir.
- Feature prompt/notu ve kabul kriterleri guncel olmalidir.
- Kritik is kurali client'a degil backend'e guvenmelidir.
- Tip hatasi, lint hatasi ve bariz runtime hata kalmamalidir.
- Degisiklik kisa notla dokumante edilmeli veya commit mesajinda aciklanmalidir.
- Kullanici akisini etkileyen degisiklikte en az bir manuel test yapilmalidir.

## 22. Kabul Kriterleri

MVP tamam sayilmasi icin:

- Kullanici hesap olusturup profilini tamamlayabilmeli.
- Aktif kullanici kesfet ekraninda uygun profilleri gorebilmeli.
- Kullanici profil begenip gecebilmelidir.
- Karsilikli begenide match olusmalidir.
- Match olusunca iki kullanici da `locked` duruma gecmelidir.
- Kilitli kullanici kesfet ekraninda profil gormemelidir.
- Kilitli kullanici baskalarinin kesfet havuzunda gorunmemelidir.
- Aktif match katilimcilari mesajlasabilmelidir.
- Kullanici sohbeti manuel bitirince iki taraf da havuza donmelidir.
- Belirlenen sessizlik suresi dolunca match otomatik kapanmalidir.
- Race condition testlerinde user basina birden fazla aktif match olusmamalidir.
- Engelleme ve sikayet temel akislari calismalidir.
- RLS politikalarinda kullanici yetkisiz mesaj/profil verisi okuyamamalidir.

## 23. Karar Bekleyen Teknolojiler ve Sorular

Asagidaki konular icin ek teknoloji secimi yapmadan once karar verilmelidir:

1. Navigasyon: Expo Router mi, React Navigation mi tercih edilecek?
2. Global state: Zustand, TanStack Query, Redux Toolkit veya baska bir yapi mi kullanilacak?
3. Server state/cache: TanStack Query kullanilsin mi?
4. Form ve validasyon: React Hook Form + Zod uygun mu?
5. UI component sistemi: Baslangic karari custom design system; NativeWind/Tamagui/React Native Paper yalnizca Pair onayli pilot sonrasi degerlendirilecek.
6. Styling: Baslangic karari React Native `StyleSheet` + typed theme tokenlari; styling kutuphanesi ekleme ihtiyaci UI kalite ve gelistirme hizi uzerinden tekrar olculecek.
7. Push notification: Expo Notifications yeterli mi, dogrudan FCM/APNs mi istenecek?
8. Analitik: Supabase events/logs yeterli mi, PostHog/Amplitude/Firebase Analytics gibi bir urun mu kullanilacak?
9. Crash reporting: Sentry veya Firebase Crashlytics kullanilsin mi?
10. E2E test: Detox, Maestro veya baska bir arac mi kullanilacak?
11. Medya moderasyonu: Manuel moderator sureci mi, otomatik API tabanli moderasyon mu?
12. Fotograf isleme: Supabase image transformation, Edge Function veya harici servis mi?
13. Konum/mesafe: Supabase PostGIS kullanilsin mi, yoksa basit lat/lng mesafe hesaplamasi MVP icin yeterli mi?
14. Admin panel: Supabase Studio ile mi baslanacak, sonradan custom admin panel mi yapilacak?
15. Odeme/abonelik: MVP disi mi kalacak, yoksa erken mimariye dahil edilecek mi?

## 24. Teknik Riskler

- Tek aktif match kuralinin sadece client tarafinda uygulanmasi ciddi veri tutarsizligi yaratir.
- Supabase RLS hatalari gizli mesaj/profil verilerinin sizmasina neden olabilir.
- Realtime abonelikleri dogru kapatilmazsa pil ve performans sorunu yaratabilir.
- Timeout job gecikir veya ayni anda birden fazla calisirsa match durumlari tutarsizlasabilir.
- Konum verisi gereksiz hassas saklanirsa gizlilik riski dogar.
- Moderasyon eksikligi kullanici guveni ve app store review sureclerini riske atabilir.

## 25. Teknik Sonuc

Bu uygulamanin teknik kalbi, React Native Expo arayuzunden cok Supabase tarafinda tutarli uygulanan "tek aktif eslesme" kuralidir. Client iyi bir deneyim sunmali, ancak asıl guvence backend transactionlari, RLS politikalari, unique constraintler ve zamanlanmis eslesme temizleme gorevleriyle saglanmalidir.

Ilk implementasyon sirasinda oncelik su sirada olmalidir:

1. Veri modeli ve RLS.
2. Match olusturma/bitirme transactionlari.
3. Mobil auth/onboarding/profil akisi.
4. Kesfet feed ve like/pass.
5. Kilitli mod ve chat.
6. Timeout job ve bildirimler.
7. Moderasyon ve kalite katmani.
