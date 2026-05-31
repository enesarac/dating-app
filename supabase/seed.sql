-- seed.sql — Local geliştirme verisi
-- Bu dosya sadece local development içindir; production/remote'a asla gitmemeli.
-- Tüm test kullanıcılar için şifre: Test1234!
-- crypt() pgcrypto üzerinden çalışır; Supabase local'de varsayılan olarak mevcut.

-- ─── UUID referans tablosu ────────────────────────────────────────────────────
-- alice  : 00000001-0000-0000-0000-000000000000
-- bob    : 00000002-0000-0000-0000-000000000000
-- carol  : 00000003-0000-0000-0000-000000000000
-- dan    : 00000004-0000-0000-0000-000000000000
-- eve    : 00000005-0000-0000-0000-000000000000  (onboarding)
-- frank  : 00000006-0000-0000-0000-000000000000  (locked)
-- match  : 00000001-0000-0000-0000-000000000001  (alice × bob)

-- ─── auth.users ───────────────────────────────────────────────────────────────
insert into auth.users (
  id, aud, role, email, encrypted_password,
  email_confirmed_at, created_at, updated_at,
  raw_app_meta_data, raw_user_meta_data,
  is_super_admin, is_sso_user, is_anonymous
) values
  (
    '00000001-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
    'alice@test.local', crypt('Test1234!', gen_salt('bf')),
    now(), now(), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    false, false, false
  ),
  (
    '00000002-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
    'bob@test.local', crypt('Test1234!', gen_salt('bf')),
    now(), now(), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    false, false, false
  ),
  (
    '00000003-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
    'carol@test.local', crypt('Test1234!', gen_salt('bf')),
    now(), now(), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    false, false, false
  ),
  (
    '00000004-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
    'dan@test.local', crypt('Test1234!', gen_salt('bf')),
    now(), now(), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    false, false, false
  ),
  (
    '00000005-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
    'eve@test.local', crypt('Test1234!', gen_salt('bf')),
    now(), now(), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    false, false, false
  ),
  (
    '00000006-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
    'frank@test.local', crypt('Test1234!', gen_salt('bf')),
    now(), now(), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    false, false, false
  )
on conflict (id) do nothing;

-- ─── auth.identities ──────────────────────────────────────────────────────────
insert into auth.identities (
  id, user_id, provider_id, identity_data, provider,
  last_sign_in_at, created_at, updated_at
) values
  (
    '00000001-0001-0000-0000-000000000000',
    '00000001-0000-0000-0000-000000000000', 'alice@test.local',
    '{"sub":"00000001-0000-0000-0000-000000000000","email":"alice@test.local"}'::jsonb,
    'email', now(), now(), now()
  ),
  (
    '00000002-0001-0000-0000-000000000000',
    '00000002-0000-0000-0000-000000000000', 'bob@test.local',
    '{"sub":"00000002-0000-0000-0000-000000000000","email":"bob@test.local"}'::jsonb,
    'email', now(), now(), now()
  ),
  (
    '00000003-0001-0000-0000-000000000000',
    '00000003-0000-0000-0000-000000000000', 'carol@test.local',
    '{"sub":"00000003-0000-0000-0000-000000000000","email":"carol@test.local"}'::jsonb,
    'email', now(), now(), now()
  ),
  (
    '00000004-0001-0000-0000-000000000000',
    '00000004-0000-0000-0000-000000000000', 'dan@test.local',
    '{"sub":"00000004-0000-0000-0000-000000000000","email":"dan@test.local"}'::jsonb,
    'email', now(), now(), now()
  ),
  (
    '00000005-0001-0000-0000-000000000000',
    '00000005-0000-0000-0000-000000000000', 'eve@test.local',
    '{"sub":"00000005-0000-0000-0000-000000000000","email":"eve@test.local"}'::jsonb,
    'email', now(), now(), now()
  ),
  (
    '00000006-0001-0000-0000-000000000000',
    '00000006-0000-0000-0000-000000000000', 'frank@test.local',
    '{"sub":"00000006-0000-0000-0000-000000000000","email":"frank@test.local"}'::jsonb,
    'email', now(), now(), now()
  )
on conflict (provider_id, provider) do nothing;

-- ─── profiles ────────────────────────────────────────────────────────────────
-- State consistency check:
--   active  → is_locked=false, is_visible=true
--   locked  → is_locked=true,  is_visible=false
--   others  → is_locked=false, is_visible=false
insert into profiles (
  id, display_name, birth_date, gender, interested_in,
  bio, latitude, longitude, city, country,
  availability_state, is_locked, is_visible,
  profile_completed_at, created_at, updated_at
) values
  (
    '00000001-0000-0000-0000-000000000000',
    'Alice', '1999-03-15', 'female', '{male}',
    'Kahve ve kitap tutkunu. İstanbul''un tarihi sokaklarını keşfetmeyi severim.',
    41.0082, 28.9784, 'Istanbul', 'TR',
    'active', false, true,
    now() - interval '2 days', now() - interval '2 days', now()
  ),
  (
    '00000002-0000-0000-0000-000000000000',
    'Bob', '1997-06-20', 'male', '{female}',
    'Fotoğrafçı ve gezgin. Hafta sonları Boğaz''da yürüyüş yaparım.',
    41.0135, 28.9500, 'Istanbul', 'TR',
    'active', false, true,
    now() - interval '3 days', now() - interval '3 days', now()
  ),
  (
    '00000003-0000-0000-0000-000000000000',
    'Carol', '2000-01-10', 'female', '{male,female}',
    'Müzisyen ve kahve bağımlısı. Konser ve galeri açılışlarından kaçmam.',
    41.0195, 29.0045, 'Istanbul', 'TR',
    'active', false, true,
    now() - interval '1 day', now() - interval '1 day', now()
  ),
  (
    '00000004-0000-0000-0000-000000000000',
    'Dan', '1996-09-05', 'male', '{male}',
    'Yazılımcı ve dağcı. Hafta sonları Uludağ yollarındayım.',
    40.9900, 28.9500, 'Istanbul', 'TR',
    'active', false, true,
    now() - interval '4 days', now() - interval '4 days', now()
  ),
  (
    '00000005-0000-0000-0000-000000000000',
    'Eve', '2001-05-20', 'female', '{male}',
    null,
    41.0300, 29.0100, 'Istanbul', 'TR',
    'onboarding', false, false,
    null, now(), now()
  ),
  (
    '00000006-0000-0000-0000-000000000000',
    'Frank', '1998-11-30', 'male', '{female}',
    'Aşçı ve film eleştirmeni.',
    41.0050, 28.9600, 'Istanbul', 'TR',
    'locked', true, false,
    now() - interval '10 days', now() - interval '10 days', now()
  )
on conflict (id) do nothing;

-- ─── preferences ─────────────────────────────────────────────────────────────
insert into preferences (
  user_id, min_age, max_age, max_distance_km,
  interested_genders, relationship_goals,
  created_at, updated_at
) values
  (
    '00000001-0000-0000-0000-000000000000',
    24, 35, 50, '{male}', '{serious,casual}',
    now(), now()
  ),
  (
    '00000002-0000-0000-0000-000000000000',
    22, 30, 30, '{female}', '{serious}',
    now(), now()
  ),
  (
    '00000003-0000-0000-0000-000000000000',
    23, 33, 50, '{male,female}', '{casual,friendship}',
    now(), now()
  ),
  (
    '00000004-0000-0000-0000-000000000000',
    25, 38, 40, '{male}', '{serious}',
    now(), now()
  )
on conflict (user_id) do nothing;

-- ─── profile_prompts ─────────────────────────────────────────────────────────
insert into profile_prompts (id, user_id, prompt_key, answer, created_at, updated_at) values
  (
    '00000001-0000-0000-0000-000000000003',
    '00000001-0000-0000-0000-000000000000',
    'favorite_activity',
    'Kapalıçarşı''da kaybolmak ve yeni bir antikacı keşfetmek',
    now(), now()
  ),
  (
    '00000002-0000-0000-0000-000000000003',
    '00000001-0000-0000-0000-000000000000',
    'looking_for',
    'Gerçek bir bağlantı; birlikte sessiz olabildiğimiz biri',
    now(), now()
  ),
  (
    '00000003-0000-0000-0000-000000000003',
    '00000002-0000-0000-0000-000000000000',
    'favorite_activity',
    'Boğaz''ın iki yakasını fotoğraflamak ve analog film banyo etmek',
    now(), now()
  ),
  (
    '00000004-0000-0000-0000-000000000003',
    '00000002-0000-0000-0000-000000000000',
    'pet_peeve',
    'Son dakika plan iptalleri ve yarım bırakılan filmler',
    now(), now()
  ),
  (
    '00000005-0000-0000-0000-000000000003',
    '00000003-0000-0000-0000-000000000000',
    'looking_for',
    'Konser sonrası uzun yürüyüş yapacak ve müzik tartışacak biri',
    now(), now()
  )
on conflict (id) do nothing;

-- ─── app_config ──────────────────────────────────────────────────────────────
insert into app_config (key, value, updated_at) values
  ('min_app_version',    '"1.0.0"',  now()),
  ('max_profile_photos', '6',        now()),
  ('max_profile_prompts','3',        now()),
  ('discover_page_size', '20',       now()),
  ('match_expiry_days',  '7',        now())
on conflict (key) do update
  set value = excluded.value, updated_at = now();

-- ─── likes ───────────────────────────────────────────────────────────────────
-- alice → bob (like) ve bob → alice (like) → karşılıklı; match var
-- carol → bob (like) → karşılıklı değil
-- dan → carol (like) → karşılıklı değil
insert into likes (id, from_user_id, to_user_id, action, created_at) values
  (
    '00000001-0000-0000-0000-000000000002',
    '00000001-0000-0000-0000-000000000000',
    '00000002-0000-0000-0000-000000000000',
    'like', now() - interval '1 day'
  ),
  (
    '00000002-0000-0000-0000-000000000002',
    '00000002-0000-0000-0000-000000000000',
    '00000001-0000-0000-0000-000000000000',
    'like', now() - interval '23 hours'
  ),
  (
    '00000003-0000-0000-0000-000000000002',
    '00000003-0000-0000-0000-000000000000',
    '00000002-0000-0000-0000-000000000000',
    'like', now() - interval '12 hours'
  ),
  (
    '00000004-0000-0000-0000-000000000002',
    '00000004-0000-0000-0000-000000000000',
    '00000003-0000-0000-0000-000000000000',
    'like', now() - interval '6 hours'
  )
on conflict (from_user_id, to_user_id) do nothing;

-- ─── matches ─────────────────────────────────────────────────────────────────
-- alice × bob; tek aktif match (partial unique index'e uygun)
insert into matches (
  id, user_a_id, user_b_id, status,
  matched_at, last_interaction_at,
  created_at, updated_at
) values (
  '00000001-0000-0000-0000-000000000001',
  '00000001-0000-0000-0000-000000000000',
  '00000002-0000-0000-0000-000000000000',
  'active',
  now() - interval '22 hours',
  now() - interval '5 minutes',
  now() - interval '22 hours',
  now() - interval '5 minutes'
)
on conflict (id) do nothing;

-- ─── match_participants ───────────────────────────────────────────────────────
-- Her iki kullanıcı için aktif participant kaydı
-- partial unique index: unique(user_id) where status='active' → alice ve bob başka aktif match'te değil
insert into match_participants (match_id, user_id, status, created_at) values
  (
    '00000001-0000-0000-0000-000000000001',
    '00000001-0000-0000-0000-000000000000',
    'active', now() - interval '22 hours'
  ),
  (
    '00000001-0000-0000-0000-000000000001',
    '00000002-0000-0000-0000-000000000000',
    'active', now() - interval '22 hours'
  )
on conflict (match_id, user_id) do nothing;

-- ─── messages ────────────────────────────────────────────────────────────────
insert into messages (
  id, match_id, sender_id, body, message_type,
  read_at, created_at
) values
  (
    '00000001-0000-0000-0000-000000000004',
    '00000001-0000-0000-0000-000000000001',
    '00000001-0000-0000-0000-000000000000',
    'Merhaba! 👋', 'text',
    now() - interval '21 hours',
    now() - interval '22 hours'
  ),
  (
    '00000002-0000-0000-0000-000000000004',
    '00000001-0000-0000-0000-000000000001',
    '00000002-0000-0000-0000-000000000000',
    'Selam Alice! Nasılsın?', 'text',
    now() - interval '20 hours',
    now() - interval '21 hours'
  ),
  (
    '00000003-0000-0000-0000-000000000004',
    '00000001-0000-0000-0000-000000000001',
    '00000001-0000-0000-0000-000000000000',
    'İyiyim, teşekkürler. Bugün Kapalıçarşı''ya gittim.', 'text',
    null,
    now() - interval '5 minutes'
  )
on conflict (id) do nothing;
