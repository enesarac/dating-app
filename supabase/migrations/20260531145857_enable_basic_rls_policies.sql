-- 2.6A: RLS enable ve temel kullanıcı-kendi-verisi policy'leri
-- Kapsam (policy): profiles, profile_photos, profile_prompts, preferences,
--                  likes, blocks, reports, devices, app_config
-- Kapsam (sadece enable): matches, match_participants, messages → 2.6B'de policy eklenecek
--
-- NOT: auth.role() deprecated; TO clause kullanıldı.
--      UPDATE policy'lerinde hem USING hem WITH CHECK zorunlu.
--      (select auth.uid()) row başına tekrar çağrılmaz; plan cache'i kullanır.

-- ─── RLS enable (tüm public tablolar) ────────────────────────────────────────
alter table profiles           enable row level security;
alter table profile_photos     enable row level security;
alter table profile_prompts    enable row level security;
alter table preferences        enable row level security;
alter table likes              enable row level security;
alter table matches            enable row level security;
alter table match_participants enable row level security;
alter table messages           enable row level security;
alter table blocks             enable row level security;
alter table reports            enable row level security;
alter table devices            enable row level security;
alter table app_config         enable row level security;

-- ─── profiles ────────────────────────────────────────────────────────────────
create policy "profiles_select_own"
  on profiles for select
  to authenticated
  using ((select auth.uid()) = id);

create policy "profiles_insert_own"
  on profiles for insert
  to authenticated
  with check ((select auth.uid()) = id);

create policy "profiles_update_own"
  on profiles for update
  to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

-- ─── profile_photos ──────────────────────────────────────────────────────────
create policy "profile_photos_select_own"
  on profile_photos for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "profile_photos_insert_own"
  on profile_photos for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy "profile_photos_update_own"
  on profile_photos for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "profile_photos_delete_own"
  on profile_photos for delete
  to authenticated
  using ((select auth.uid()) = user_id);

-- ─── profile_prompts ─────────────────────────────────────────────────────────
create policy "profile_prompts_select_own"
  on profile_prompts for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "profile_prompts_insert_own"
  on profile_prompts for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy "profile_prompts_update_own"
  on profile_prompts for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "profile_prompts_delete_own"
  on profile_prompts for delete
  to authenticated
  using ((select auth.uid()) = user_id);

-- ─── preferences ─────────────────────────────────────────────────────────────
create policy "preferences_select_own"
  on preferences for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "preferences_insert_own"
  on preferences for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy "preferences_update_own"
  on preferences for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "preferences_delete_own"
  on preferences for delete
  to authenticated
  using ((select auth.uid()) = user_id);

-- ─── likes ───────────────────────────────────────────────────────────────────
-- UPDATE/DELETE yok: like bir kez gönderilir; değiştirmek RPC üzerinden olacak.
create policy "likes_select_own"
  on likes for select
  to authenticated
  using ((select auth.uid()) = from_user_id);

create policy "likes_insert_own"
  on likes for insert
  to authenticated
  with check ((select auth.uid()) = from_user_id);

-- ─── blocks ──────────────────────────────────────────────────────────────────
create policy "blocks_select_own"
  on blocks for select
  to authenticated
  using ((select auth.uid()) = blocker_id);

create policy "blocks_insert_own"
  on blocks for insert
  to authenticated
  with check ((select auth.uid()) = blocker_id);

create policy "blocks_delete_own"
  on blocks for delete
  to authenticated
  using ((select auth.uid()) = blocker_id);

-- ─── reports ─────────────────────────────────────────────────────────────────
-- UPDATE/DELETE yok: gönderilen report moderasyon sürecine girer; client değiştiremez.
create policy "reports_select_own"
  on reports for select
  to authenticated
  using ((select auth.uid()) = reporter_id);

create policy "reports_insert_own"
  on reports for insert
  to authenticated
  with check ((select auth.uid()) = reporter_id);

-- ─── devices ─────────────────────────────────────────────────────────────────
create policy "devices_select_own"
  on devices for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "devices_insert_own"
  on devices for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy "devices_update_own"
  on devices for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "devices_delete_own"
  on devices for delete
  to authenticated
  using ((select auth.uid()) = user_id);

-- ─── app_config ───────────────────────────────────────────────────────────────
-- Client sadece okuyabilir; INSERT/UPDATE/DELETE policy yok (admin only).
create policy "app_config_select_authenticated"
  on app_config for select
  to authenticated
  using (true);
