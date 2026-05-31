# 0003 — Database Modeli ve Güvenlik Mimarisi

**Tarih:** 2026-05-31
**Durum:** Taslak — Aşama 2 boyunca tamamlanacak

---

## 1. Kapsam

Bu ADR, Aşama 2 için Supabase üzerindeki tablo şeması, RLS politikaları, storage yapısı ve migration
sırasını belirler.

**Bu adımın kapsamında:**

- Tablo grupları ve durum alanlarının kesinleşmesi
- Tek aktif match kuralının constraint düzeyinde nasıl hayata geçirileceği
- Konum ve storage kararları
- RLS prensipleri
- Migration sırası

**Bu adımın dışında kalan (ayrı adımlarda yapılacak):**

- SQL migration dosyaları (2.2–2.9 adımları)
- RPC implementation (`create_match`, `end_match`, `get_discover_feed` vb.)
- Edge Function kodları
- UI bileşenleri

---

## 2. Tablo Grupları

### Auth / Profile

| Tablo             | Açıklama                                                                                   |
| ----------------- | ------------------------------------------------------------------------------------------ |
| `profiles`        | `auth.users` ile 1:1; display_name, bio, doğum tarihi, cinsiyet, konum, availability_state |
| `profile_photos`  | Profil fotoğrafları; sıra, is_primary, storage path, moderation_status                     |
| `profile_prompts` | Kullanıcının seçtiği soru-cevap prompt'ları (biyografi zenginleştirme)                     |
| `preferences`     | Keşfet filtre tercihleri; cinsiyet, yaş aralığı, mesafe                                    |

### Discover / Match / Chat

| Tablo                | Açıklama                                                                        |
| -------------------- | ------------------------------------------------------------------------------- |
| `likes`              | Kullanıcıdan kullanıcıya beğeni; action: like / pass                            |
| `matches`            | Karşılıklı beğeniyle oluşan eşleşme; status, ended_reason                       |
| `match_participants` | Eşleşmeye taraf olan kullanıcılar — tek aktif match kısıtının uygulandığı tablo |
| `messages`           | Mesajlar; message_type: text / image / system                                   |

### Safety / Notification / Config

| Tablo        | Açıklama                                                              |
| ------------ | --------------------------------------------------------------------- |
| `blocks`     | Engelleme kayıtları                                                   |
| `reports`    | Kullanıcı şikayetleri; status                                         |
| `devices`    | Push token'ları ve platform bilgisi (Expo Notifications, sonraki faz) |
| `app_config` | Remote feature flag ve uygulama geneli config (admin paneli olmadan)  |

**Sonraya bırakılanlar:** `interests`, `profile_interests` (ilgi alanı kataloğu ihtiyacı netleşince
eklenecek), `message_reads` (okundu bilgisi chat fazında değerlendirilecek), `notification_tokens`
(ayrı tablo olarak kullanılmayacak; MVP'de push token sorumluluğu `devices` tablosunda).

---

## 3. Durum Alanları

Tüm durum alanları Postgres `TEXT` + `CHECK` constraint ile tanımlanacak; ileride `ENUM`'a
dönüştürmeye olanak tanır.

| Alan                               | Değerler                                                                             |
| ---------------------------------- | ------------------------------------------------------------------------------------ |
| `profiles.availability_state`      | `onboarding` · `active` · `locked` · `paused` · `banned` · `deleted`                 |
| `likes.action`                     | `like` · `pass`                                                                      |
| `matches.status`                   | `active` · `ended` · `expired` · `blocked` · `reported`                              |
| `matches.ended_reason`             | `manual` · `timeout` · `blocked` · `moderation` — aktif match sırasında `NULL` kalır |
| `messages.message_type`            | `text` · `image` · `system`                                                          |
| `profile_photos.moderation_status` | `pending` · `approved` · `rejected`                                                  |
| `reports.status`                   | `open` · `reviewing` · `resolved` · `dismissed`                                      |

---

## 4. Tablo Alan Kontratları

Bu bölüm 2.2–2.4 migration'larının kaynak sözleşmesidir. Constraint ve RLS detayları 2.5 ve
2.6'da SQL'e dökülecek.

### `profiles`

| Alan                   | Tip                | Nullable? | Not                              |
| ---------------------- | ------------------ | --------- | -------------------------------- |
| `id`                   | `uuid`             | ✗         | PK · `references auth.users(id)` |
| `display_name`         | `text`             | ✗         |                                  |
| `birth_date`           | `date`             | ✗         |                                  |
| `gender`               | `text`             | ✗         |                                  |
| `interested_in`        | `text[]`           | ✗         |                                  |
| `bio`                  | `text`             | ✓         |                                  |
| `latitude`             | `double precision` | ✓         |                                  |
| `longitude`            | `double precision` | ✓         |                                  |
| `city`                 | `text`             | ✓         |                                  |
| `country`              | `text`             | ✓         |                                  |
| `availability_state`   | `text`             | ✗         | default `'onboarding'`           |
| `is_locked`            | `boolean`          | ✗         | default `false`                  |
| `is_visible`           | `boolean`          | ✗         | default `false`                  |
| `profile_completed_at` | `timestamptz`      | ✓         |                                  |
| `last_active_at`       | `timestamptz`      | ✓         |                                  |
| `created_at`           | `timestamptz`      | ✗         | default `now()`                  |
| `updated_at`           | `timestamptz`      | ✗         | default `now()`                  |

> `availability_state` ana kaynak; `is_locked` ve `is_visible` geriye dönük okunabilirlik ve
> query kolaylığı için senkron tutulur.

---

### `profile_photos`

| Alan                | Tip           | Nullable? | Not                       |
| ------------------- | ------------- | --------- | ------------------------- |
| `id`                | `uuid`        | ✗         | PK                        |
| `user_id`           | `uuid`        | ✗         | `references profiles(id)` |
| `storage_path`      | `text`        | ✗         |                           |
| `sort_order`        | `int`         | ✗         |                           |
| `is_primary`        | `boolean`     | ✗         | default `false`           |
| `moderation_status` | `text`        | ✗         | default `'pending'`       |
| `created_at`        | `timestamptz` | ✗         | default `now()`           |

---

### `profile_prompts`

| Alan         | Tip           | Nullable? | Not                       |
| ------------ | ------------- | --------- | ------------------------- |
| `id`         | `uuid`        | ✗         | PK                        |
| `user_id`    | `uuid`        | ✗         | `references profiles(id)` |
| `prompt_key` | `text`        | ✗         |                           |
| `answer`     | `text`        | ✗         |                           |
| `created_at` | `timestamptz` | ✗         | default `now()`           |
| `updated_at` | `timestamptz` | ✗         | default `now()`           |

---

### `preferences`

| Alan                 | Tip           | Nullable? | Not                            |
| -------------------- | ------------- | --------- | ------------------------------ |
| `user_id`            | `uuid`        | ✗         | PK · `references profiles(id)` |
| `min_age`            | `int`         | ✓         |                                |
| `max_age`            | `int`         | ✓         |                                |
| `max_distance_km`    | `int`         | ✓         |                                |
| `interested_genders` | `text[]`      | ✓         |                                |
| `relationship_goals` | `text[]`      | ✓         |                                |
| `created_at`         | `timestamptz` | ✗         | default `now()`                |
| `updated_at`         | `timestamptz` | ✗         | default `now()`                |

---

### `likes`

| Alan           | Tip           | Nullable? | Not                       |
| -------------- | ------------- | --------- | ------------------------- |
| `id`           | `uuid`        | ✗         | PK                        |
| `from_user_id` | `uuid`        | ✗         | `references profiles(id)` |
| `to_user_id`   | `uuid`        | ✗         | `references profiles(id)` |
| `action`       | `text`        | ✗         |                           |
| `created_at`   | `timestamptz` | ✗         | default `now()`           |

> `unique(from_user_id, to_user_id)` · `check(from_user_id <> to_user_id)`

---

### `matches`

| Alan                  | Tip           | Nullable? | Not                       |
| --------------------- | ------------- | --------- | ------------------------- |
| `id`                  | `uuid`        | ✗         | PK                        |
| `user_a_id`           | `uuid`        | ✗         | `references profiles(id)` |
| `user_b_id`           | `uuid`        | ✗         | `references profiles(id)` |
| `status`              | `text`        | ✗         | default `'active'`        |
| `matched_at`          | `timestamptz` | ✗         | default `now()`           |
| `last_interaction_at` | `timestamptz` | ✗         | default `now()`           |
| `ended_at`            | `timestamptz` | ✓         |                           |
| `ended_by_user_id`    | `uuid`        | ✓         | `references profiles(id)` |
| `ended_reason`        | `text`        | ✓         |                           |
| `created_at`          | `timestamptz` | ✗         | default `now()`           |
| `updated_at`          | `timestamptz` | ✗         | default `now()`           |

> `check(user_a_id <> user_b_id)` · Aktif match tekilliği doğrudan bu tabloda değil,
> `match_participants` üzerinden enforce edilir.

---

### `match_participants`

| Alan         | Tip           | Nullable? | Not                       |
| ------------ | ------------- | --------- | ------------------------- |
| `match_id`   | `uuid`        | ✗         | `references matches(id)`  |
| `user_id`    | `uuid`        | ✗         | `references profiles(id)` |
| `status`     | `text`        | ✗         | default `'active'`        |
| `created_at` | `timestamptz` | ✗         | default `now()`           |

> PK `(match_id, user_id)` · Partial unique index: `unique(user_id) where status = 'active'`

---

### `messages`

| Alan           | Tip           | Nullable? | Not                       |
| -------------- | ------------- | --------- | ------------------------- |
| `id`           | `uuid`        | ✗         | PK                        |
| `match_id`     | `uuid`        | ✗         | `references matches(id)`  |
| `sender_id`    | `uuid`        | ✗         | `references profiles(id)` |
| `body`         | `text`        | ✗         |                           |
| `message_type` | `text`        | ✗         | default `'text'`          |
| `read_at`      | `timestamptz` | ✓         |                           |
| `created_at`   | `timestamptz` | ✗         | default `now()`           |
| `deleted_at`   | `timestamptz` | ✓         |                           |

---

### `blocks`

| Alan         | Tip           | Nullable? | Not                       |
| ------------ | ------------- | --------- | ------------------------- |
| `id`         | `uuid`        | ✗         | PK                        |
| `blocker_id` | `uuid`        | ✗         | `references profiles(id)` |
| `blocked_id` | `uuid`        | ✗         | `references profiles(id)` |
| `created_at` | `timestamptz` | ✗         | default `now()`           |

> `unique(blocker_id, blocked_id)` · `check(blocker_id <> blocked_id)`

---

### `reports`

| Alan               | Tip           | Nullable? | Not                       |
| ------------------ | ------------- | --------- | ------------------------- |
| `id`               | `uuid`        | ✗         | PK                        |
| `reporter_id`      | `uuid`        | ✗         | `references profiles(id)` |
| `reported_user_id` | `uuid`        | ✗         | `references profiles(id)` |
| `match_id`         | `uuid`        | ✓         | `references matches(id)`  |
| `message_id`       | `uuid`        | ✓         | `references messages(id)` |
| `reason`           | `text`        | ✗         |                           |
| `details`          | `text`        | ✓         |                           |
| `status`           | `text`        | ✗         | default `'open'`          |
| `created_at`       | `timestamptz` | ✗         | default `now()`           |

---

### `devices`

| Alan         | Tip           | Nullable? | Not                       |
| ------------ | ------------- | --------- | ------------------------- |
| `id`         | `uuid`        | ✗         | PK                        |
| `user_id`    | `uuid`        | ✗         | `references profiles(id)` |
| `platform`   | `text`        | ✗         |                           |
| `push_token` | `text`        | ✗         |                           |
| `created_at` | `timestamptz` | ✗         | default `now()`           |
| `updated_at` | `timestamptz` | ✗         | default `now()`           |

> Push token kaydı sonraki notification fazında client tarafından yapılacak.

---

### `app_config`

| Alan         | Tip           | Nullable? | Not             |
| ------------ | ------------- | --------- | --------------- |
| `key`        | `text`        | ✗         | PK              |
| `value`      | `jsonb`       | ✗         |                 |
| `updated_at` | `timestamptz` | ✗         | default `now()` |

---

**2.1B sonucu:** Bu alan kontratları 2.2, 2.3 ve 2.4 migration'larının kaynak sözleşmesidir.
Constraint ve RLS detayları 2.5 ve 2.6'da SQL'e dökülecek.

---

## Constraint ve Index Kontratları

Bu bölüm SQL yazmadan, 2.5 migrationında uygulanacak constraint/index sözleşmesini ve 2.6 için
RLS policy davranışlarını netleştirir.

### 1. Check Constraintler

- `profiles.availability_state` → `('onboarding', 'active', 'locked', 'paused', 'banned', 'deleted')`
- `profiles` state uyum kuralı:
  - `availability_state = 'locked'` ise `is_locked = true` ve `is_visible = false`
  - `availability_state = 'active'` ise `is_locked = false` ve `is_visible = true`
  - `availability_state <> 'locked'` ise `is_locked = false`
  - `onboarding` / `paused` / `banned` / `deleted` için `is_visible = false`
  - Bu uyum DB check veya trigger ile enforce edilecek; 2.5'te karar SQL'e dökülecek.
- `likes.action` → `('like', 'pass')`
- `matches.status` → `('active', 'ended', 'expired', 'blocked', 'reported')`
- `matches.ended_reason` → `('manual', 'timeout', 'blocked', 'moderation')` veya `NULL`
- `matches.user_a_id <> matches.user_b_id`
- `match_participants.status` → `('active', 'ended', 'expired', 'blocked', 'reported')`
- `messages.message_type` → `('text', 'image', 'system')`
- `profile_photos.moderation_status` → `('pending', 'approved', 'rejected')`
- `reports.status` → `('open', 'reviewing', 'resolved', 'dismissed')`
- `blocks.blocker_id <> blocks.blocked_id`

### 2. Unique Constraintler

- `likes`: `unique(from_user_id, to_user_id)`
- `blocks`: `unique(blocker_id, blocked_id)`
- `profile_photos`: `unique(user_id, sort_order)` — aynı kullanıcıda sıra çakışması olmaz
- `profile_photos` primary photo: `unique(user_id) where is_primary = true` — partial unique index;
  kullanıcı başına tek primary photo enforce edilir
- `match_participants`: PK `(match_id, user_id)`
- `match_participants` aktif teklik: `unique(user_id) where status = 'active'` — partial unique index
- `devices`: `unique(push_token)` — MVP kararı; `unique(user_id, push_token)` de kabul edilebilir
  ancak token global tekliği daha güvenli

### 3. Performans İndexleri

| İndex                                 | Amaç                          |
| ------------------------------------- | ----------------------------- |
| `profiles(availability_state)`        | Discover feed filtresi        |
| `profiles(city, country)`             | Konum bazlı filtreleme        |
| `likes(from_user_id, to_user_id)`     | Çift yön like sorgusu         |
| `likes(to_user_id, action)`           | Karşılıklı like tespiti       |
| `matches(status)`                     | Aktif match listesi           |
| `matches(user_a_id)`                  | Kullanıcıya ait match sorgusu |
| `matches(user_b_id)`                  | Kullanıcıya ait match sorgusu |
| `match_participants(user_id, status)` | Aktif participant kontrolü    |
| `messages(match_id, created_at)`      | Chat feed sıralaması          |
| `blocks(blocker_id, blocked_id)`      | Blok varlık kontrolü          |
| `reports(reported_user_id, status)`   | Moderasyon sorgusu            |
| `devices(user_id)`                    | Kullanıcı cihaz listesi       |

### 4. RLS Policy Kontratı

SQL yazmadan 2.6 için her tablonun policy davranışı:

**`profiles`**

- Kullanıcı kendi profilini okuyabilir ve güncelleyebilir.
- Discover feed doğrudan tablo `SELECT` ile değil, `get_discover_feed` RPC üzerinden sunulur;
  client `profiles` tablosunu direkt filtreleyemez.

**`profile_photos` / `profile_prompts` / `preferences`**

- Kullanıcı yalnızca kendi `user_id`'sine ait kayıtları okuyabilir ve yazabilir.

**`likes`**

- Kullanıcı yalnızca kendi `from_user_id` ile `INSERT` yapabilir.
- Kullanıcı kendi like kayıtlarını okuyabilir.

**`matches` / `match_participants`**

- Client doğrudan `INSERT`, `UPDATE`, `DELETE` yapamaz; tüm yazma işlemleri RPC üzerinden.
- Kullanıcı, `match_participants`ta participant olduğu match kayıtlarını okuyabilir.

**`messages`**

- Kullanıcı, participant olduğu match'e ait mesajları okuyabilir.
- Yalnızca `match_participants.status = 'active'` olan katılımcı `INSERT` yapabilir.

**`blocks`**

- Kullanıcı kendi block kayıtlarını yazabilir ve okuyabilir.

**`reports`**

- Kullanıcı kendi report kayıtlarını `INSERT` edebilir.
- Kullanıcı yalnızca kendi gönderdiği reportları okuyabilir.

**`devices`**

- Kullanıcı kendi cihaz kayıtlarına `INSERT` / `UPDATE` / `DELETE` / `SELECT` yapabilir.

**`app_config`**

- Authenticated kullanıcı okuyabilir.
- Client yazamaz; yalnızca admin düzeyinde güncelleme yapılır.

### 5. RPC Boundary Notu

Aşağıdaki fonksiyonlar ileride yazılacaktır; bu ADR yalnızca tablo/constraint/RLS sözleşmesini
tanımlar — RPC implementasyonu sonraki aşamalara bırakılır:

`complete_onboarding` · `get_discover_feed` · `submit_profile_action` ·
`create_match_transaction` · `end_match` · `expire_inactive_matches` ·
`block_user` · `report_user`

---

**2.1C sonucu:** 2.5 ve 2.6 migrationları için constraint/index/RLS kontratı netleşti.

---

## 5. Tek Aktif Match Kuralı

Uygulamanın çekirdek kısıtı — "bir kullanıcının aynı anda yalnızca bir aktif eşleşmesi olabilir" —
**`match_participants` tablosunda** uygulanır.

Uygulama stratejisi:

- `match_participants(user_id)` üzerine **partial unique index**: `WHERE status = 'active'`
- Bu index, aynı `user_id`'nin birden fazla aktif match'te yer almasını veritabanı düzeyinde engeller.
- `create_match` RPC bu tabloyu yazarken index ihlalini yakalar; uygulama katmanına hata döner.
- RLS politikası: kullanıcı kendi `match_participants` satırını okuyabilir; doğrudan INSERT yapamaz
  (yalnızca RPC üzerinden).

Detaylı SQL, Adım 2.5 (index/constraint) migration'ında yer alacak.

---

## 6. Konum Kararı

**Seçilen:** `latitude DOUBLE PRECISION`, `longitude DOUBLE PRECISION`, `city TEXT`, `country TEXT`
— `profiles` tablosunda düz sütunlar.

**Reddedilen (MVP için):** PostGIS `GEOGRAPHY(Point)` + `ST_DWithin`

**Gerekçe:**

- PostGIS Supabase local'de ek extension kurulumu gerektirir; CI ve EAS Build pipeline'ını
  karmaşıklaştırır.
- MVP için yakın mesafe filtresi (örn. "50 km içinde") Haversine formülüyle bir SQL fonksiyonu
  veya RPC ile yeterince hesaplanabilir.
- Kullanıcı tabanı büyüdüğünde ve coğrafi sorgu performansı darboğaz haline geldiğinde PostGIS'e
  geçiş bir migration ile yapılabilir.

**Yeniden değerlendirme koşulu:** Aktif kullanıcı sayısı 10 k'yı geçtiğinde veya keşfet feed
latency > 500 ms ölçüldüğünde.

---

## 7. Storage Kararı

**Bucket:** `profile-photos`

**Kararlar:**

- **Private bucket** — dosyalar doğrudan URL ile erişilemez.
- **Signed URL** — kendi fotoğrafları için client `storage.createSignedUrl()` çağırabilir.
  Başka kullanıcıların fotoğrafları (discover feed, chat) service role üzerinden Edge Function/RPC
  ile üretilen signed URL ile servis edilir; client direkt okuyamaz.
- RLS politikası: kullanıcı yalnızca kendi `{user_id}/` prefix'i altına upload yapabilir.
- Silme: match bittiğinde veya hesap kapatıldığında fotoğraflar temizlenir (Edge Function veya
  DB trigger — Adım 2.7'de kararlaştırılacak).

**Reddedilen:** Public bucket — profil fotoğraflarını doğrudan indexlenebilir kılmak GDPR ve
güven açısından uygun değil.

---

## 8. RLS Prensipleri

1. **Tüm public tablolarda RLS açık.** `ENABLE ROW LEVEL SECURITY` ve policy blokları 2.6
   migrationında merkezi olarak uygulanır; 2.2–2.5 migrationları yalnızca tablo oluşturma ve
   constraint/index tanımlamasıyla sınırlıdır.
2. **Client doğrudan `matches` veya `match_participants` tablosuna INSERT yapamaz.** Yalnızca
   `create_match` RPC üzerinden — RPC `SECURITY DEFINER` ile çalışır.
3. **Discover feed RPC üzerinden sunulur.** Client `profiles` tablosunu doğrudan filtreleyemez;
   `get_discover_feed` RPC `availability_state = 'active'` ve blok/like geçmişini filtreler.
4. **Kullanıcı yalnızca kendi verisini değiştirebilir.** `profiles`, `profile_photos`,
   `devices` için `auth.uid() = user_id` politikası.
5. **Mesajları yalnızca match katılımcıları okuyabilir.** `messages` için
   `match_participants` join ile katılımcılık doğrulanır.
6. **Blok listesi çift yönlü çalışır.** Engellenen kullanıcı, engelleyeni discover'da ve
   chat'te göremez; RLS politikası her iki yönü de kapatır.

---

## 9. Migration Planı

Migration'lar `supabase/migrations/` altında numaralı dosyalar olarak oluşturulacak.

| Adım    | Kapsam                                                               | Bağımlılık |
| ------- | -------------------------------------------------------------------- | ---------- |
| **2.2** | `profiles`, `profile_photos`, `profile_prompts`, `preferences`       | —          |
| **2.3** | `likes`, `matches`, `match_participants`, `messages`                 | 2.2        |
| **2.4** | `blocks`, `reports`, `devices`, `app_config`                         | 2.2        |
| **2.5** | Index'ler, CHECK constraint'ler, partial unique index (match kuralı) | 2.2–2.4    |
| **2.6** | RLS politikaları (tüm tablolar)                                      | 2.5        |
| **2.7** | Storage bucket ve politikaları                                       | 2.2        |
| **2.8** | Seed / test kullanıcıları ve app_config başlangıç değerleri          | 2.6        |
| **2.9** | `npm run supabase:types` — TypeScript tip yenileme                   | 2.8        |

2.2–2.4 migrationları tablo oluşturma odaklıdır. 2.5 index/check/unique constraintleri uygular.
2.6 RLS enable ve policy bloklarını merkezi olarak uygular.

---

## 10. Açık Kararlar

Aşağıdaki konular Aşama 2 içinde veya sonrasında netleştirilecek; şimdilik kapsam dışı.

| Konu                               | Neden Bekliyor                                                                       |
| ---------------------------------- | ------------------------------------------------------------------------------------ |
| **PostGIS**                        | MVP için gerekli değil; yeniden değerlendirme koşulu bölüm 5'te tanımlı              |
| **interests / profile_interests**  | İlgi alanı kataloğu ihtiyacı ürün kararına bağlı; profil ekranı netleşince eklenecek |
| **message_reads**                  | Okundu alındısı chat fazında değerlendirilecek; şimdilik kapsam dışı                 |
| **super_like**                     | MVP dışı; ürün öncelik sıralamasına göre sonraki sürümde değerlendirilebilir         |
| **Admin panel**                    | Teknik PRD'de kapsam dışı; moderasyon şimdilik manuel Supabase Studio üzerinden      |
| **Otomatik medya moderasyonu**     | ML servisi entegrasyonu (Rekognition vb.) beta sonrasına bırakıldı                   |
| **Notification scheduling**        | `pg_cron` veya Edge Function tercihine Adım 2.4'te karar verilecek                   |
| **Realtime publication detayları** | `messages` ve `matches` için Supabase Realtime ayarları chat fazında yapılacak       |
