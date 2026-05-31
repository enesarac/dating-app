-- 2.2: Auth/Profile tabloları
-- Kapsam: profiles, profile_photos, profile_prompts, preferences
-- Check/index/unique constraintler 2.5'te, RLS 2.6'da uygulanacak.

-- ─── profiles ───────────────────────────────────────────────────────────────
create table profiles (
  id                    uuid             primary key references auth.users(id) on delete cascade,
  display_name          text             not null,
  birth_date            date             not null,
  gender                text             not null,
  interested_in         text[]           not null,
  bio                   text,
  latitude              double precision,
  longitude             double precision,
  city                  text,
  country               text,
  availability_state    text             not null default 'onboarding',
  is_locked             boolean          not null default false,
  is_visible            boolean          not null default false,
  profile_completed_at  timestamptz,
  last_active_at        timestamptz,
  created_at            timestamptz      not null default now(),
  updated_at            timestamptz      not null default now()
);

-- ─── profile_photos ──────────────────────────────────────────────────────────
create table profile_photos (
  id                uuid          primary key default gen_random_uuid(),
  user_id           uuid          not null references profiles(id) on delete cascade,
  storage_path      text          not null,
  sort_order        int           not null,
  is_primary        boolean       not null default false,
  moderation_status text          not null default 'pending',
  created_at        timestamptz   not null default now()
);

-- ─── profile_prompts ─────────────────────────────────────────────────────────
create table profile_prompts (
  id          uuid        primary key default gen_random_uuid(),
  user_id     uuid        not null references profiles(id) on delete cascade,
  prompt_key  text        not null,
  answer      text        not null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- ─── preferences ─────────────────────────────────────────────────────────────
create table preferences (
  user_id             uuid        primary key references profiles(id) on delete cascade,
  min_age             int,
  max_age             int,
  max_distance_km     int,
  interested_genders  text[],
  relationship_goals  text[],
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);
