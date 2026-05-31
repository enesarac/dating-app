-- 2.5: Kritik index ve constraintler
-- Kapsam: check constraintler, unique constraintler, performans indexleri
-- RLS 2.6'da uygulanacak.

-- ─── profiles: check constraintler ──────────────────────────────────────────
alter table profiles
  add constraint profiles_availability_state_check
    check (availability_state in ('onboarding', 'active', 'locked', 'paused', 'banned', 'deleted')),
  add constraint profiles_state_consistency_check
    check (
      case availability_state
        when 'locked'  then is_locked = true  and is_visible = false
        when 'active'  then is_locked = false and is_visible = true
        else                is_locked = false and is_visible = false
      end
    );

-- ─── likes: check constraintler ──────────────────────────────────────────────
alter table likes
  add constraint likes_action_check
    check (action in ('like', 'pass')),
  add constraint likes_no_self_like_check
    check (from_user_id <> to_user_id);

-- ─── matches: check constraintler ────────────────────────────────────────────
alter table matches
  add constraint matches_status_check
    check (status in ('active', 'ended', 'expired', 'blocked', 'reported')),
  add constraint matches_ended_reason_check
    check (ended_reason is null or ended_reason in ('manual', 'timeout', 'blocked', 'moderation')),
  add constraint matches_no_self_match_check
    check (user_a_id <> user_b_id);

-- ─── match_participants: check constraintler ─────────────────────────────────
alter table match_participants
  add constraint match_participants_status_check
    check (status in ('active', 'ended', 'expired', 'blocked', 'reported'));

-- ─── messages: check constraintler ───────────────────────────────────────────
alter table messages
  add constraint messages_message_type_check
    check (message_type in ('text', 'image', 'system'));

-- ─── profile_photos: check constraintler ─────────────────────────────────────
alter table profile_photos
  add constraint profile_photos_moderation_status_check
    check (moderation_status in ('pending', 'approved', 'rejected'));

-- ─── reports: check constraintler ────────────────────────────────────────────
alter table reports
  add constraint reports_status_check
    check (status in ('open', 'reviewing', 'resolved', 'dismissed'));

-- ─── blocks: check constraintler ─────────────────────────────────────────────
alter table blocks
  add constraint blocks_no_self_block_check
    check (blocker_id <> blocked_id);

-- ─── unique constraintler ────────────────────────────────────────────────────
-- likes: aynı çift için tek kayıt; bu index performans için de kullanılır.
alter table likes
  add constraint likes_from_to_unique unique (from_user_id, to_user_id);

-- blocks: aynı çift için tek kayıt; bu index performans için de kullanılır.
alter table blocks
  add constraint blocks_pair_unique unique (blocker_id, blocked_id);

-- profile_photos: aynı kullanıcıda sıra çakışması olmaz.
alter table profile_photos
  add constraint profile_photos_user_sort_order_unique unique (user_id, sort_order);

-- devices: global push token tekliği.
alter table devices
  add constraint devices_push_token_unique unique (push_token);

-- ─── partial unique indexler ─────────────────────────────────────────────────
-- profile_photos: kullanıcı başına tek primary fotoğraf.
create unique index profile_photos_primary_unique_idx
  on profile_photos (user_id)
  where is_primary = true;

-- match_participants: tek aktif match kuralı (çekirdek kısıt).
create unique index match_participants_active_unique_idx
  on match_participants (user_id)
  where status = 'active';

-- ─── performans indexleri ─────────────────────────────────────────────────────
-- profiles
create index profiles_availability_state_idx on profiles (availability_state);
create index profiles_city_country_idx        on profiles (city, country);

-- likes: (from_user_id, to_user_id) unique constraint tarafından zaten kapsanır.
create index likes_to_user_action_idx on likes (to_user_id, action);

-- matches
create index matches_status_idx    on matches (status);
create index matches_user_a_idx    on matches (user_a_id);
create index matches_user_b_idx    on matches (user_b_id);

-- match_participants
create index match_participants_user_status_idx on match_participants (user_id, status);

-- messages
create index messages_match_created_idx on messages (match_id, created_at);

-- reports
create index reports_reported_user_status_idx on reports (reported_user_id, status);

-- devices
create index devices_user_idx on devices (user_id);
