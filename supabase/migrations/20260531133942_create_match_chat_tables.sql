-- 2.3: Discover/Match/Chat tabloları
-- Kapsam: likes, matches, match_participants, messages
-- Check/unique/index constraintler 2.5'te, RLS 2.6'da uygulanacak.

-- ─── likes ───────────────────────────────────────────────────────────────────
create table likes (
  id            uuid        primary key default gen_random_uuid(),
  from_user_id  uuid        not null references profiles(id) on delete cascade,
  to_user_id    uuid        not null references profiles(id) on delete cascade,
  action        text        not null,
  created_at    timestamptz not null default now()
);

-- ─── matches ─────────────────────────────────────────────────────────────────
create table matches (
  id                   uuid        primary key default gen_random_uuid(),
  user_a_id            uuid        not null references profiles(id) on delete cascade,
  user_b_id            uuid        not null references profiles(id) on delete cascade,
  status               text        not null default 'active',
  matched_at           timestamptz not null default now(),
  last_interaction_at  timestamptz not null default now(),
  ended_at             timestamptz,
  ended_by_user_id     uuid        references profiles(id) on delete set null,
  ended_reason         text,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);

-- ─── match_participants ───────────────────────────────────────────────────────
-- Tek aktif match kuralı bu tablo üzerinden enforce edilir (2.5'te partial unique index).
create table match_participants (
  match_id    uuid        not null references matches(id) on delete cascade,
  user_id     uuid        not null references profiles(id) on delete cascade,
  status      text        not null default 'active',
  created_at  timestamptz not null default now(),
  primary key (match_id, user_id)
);

-- ─── messages ────────────────────────────────────────────────────────────────
create table messages (
  id            uuid        primary key default gen_random_uuid(),
  match_id      uuid        not null references matches(id) on delete cascade,
  sender_id     uuid        not null references profiles(id) on delete cascade,
  body          text        not null,
  message_type  text        not null default 'text',
  read_at       timestamptz,
  created_at    timestamptz not null default now(),
  deleted_at    timestamptz
);
