-- 2.4: Safety/Notification/Config tabloları
-- Kapsam: blocks, reports, devices, app_config
-- Check/unique/index constraintler 2.5'te, RLS 2.6'da uygulanacak.

-- ─── blocks ──────────────────────────────────────────────────────────────────
create table blocks (
  id          uuid        primary key default gen_random_uuid(),
  blocker_id  uuid        not null references profiles(id) on delete cascade,
  blocked_id  uuid        not null references profiles(id) on delete cascade,
  created_at  timestamptz not null default now()
);

-- ─── reports ─────────────────────────────────────────────────────────────────
create table reports (
  id               uuid        primary key default gen_random_uuid(),
  reporter_id      uuid        not null references profiles(id) on delete cascade,
  reported_user_id uuid        not null references profiles(id) on delete cascade,
  match_id         uuid        references matches(id) on delete set null,
  message_id       uuid        references messages(id) on delete set null,
  reason           text        not null,
  details          text,
  status           text        not null default 'open',
  created_at       timestamptz not null default now()
);

-- ─── devices ─────────────────────────────────────────────────────────────────
create table devices (
  id          uuid        primary key default gen_random_uuid(),
  user_id     uuid        not null references profiles(id) on delete cascade,
  platform    text        not null,
  push_token  text        not null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- ─── app_config ──────────────────────────────────────────────────────────────
-- Remote feature flag ve uygulama geneli config; client yazamaz, sadece okuyabilir.
create table app_config (
  key        text    primary key,
  value      jsonb   not null,
  updated_at timestamptz not null default now()
);
