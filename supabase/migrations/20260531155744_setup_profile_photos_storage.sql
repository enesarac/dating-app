-- 2.7: Storage bucket ve profil fotoğraf erişim politikası
-- Bucket: profile-photos (private)
-- Path format: {user_id}/{filename}
-- Client: kendi dosyalarını okuyabilir / upload / update / delete yapabilir.
-- Başka kullanıcıların fotoğrafları service role/Edge Function üzerinden signed URL ile servis edilir.

-- ─── bucket ──────────────────────────────────────────────────────────────────
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'profile-photos',
  'profile-photos',
  false,
  5242880,  -- 5 MB
  array['image/jpeg', 'image/png', 'image/webp']
);

-- ─── storage.objects policies ────────────────────────────────────────────────
-- SELECT: kullanıcı yalnızca kendi prefix'i ({uid}/*) altındaki dosyaları okuyabilir.
-- createSignedUrl() da bu policy üzerinden authorize edilir.
create policy "profile_photos_storage_select_own"
  on storage.objects for select
  to authenticated
  using (
    bucket_id = 'profile-photos'
    and (select auth.uid())::text = (storage.foldername(name))[1]
  );

-- INSERT: kullanıcı yalnızca kendi prefix'i altına upload yapabilir.
create policy "profile_photos_storage_insert_own"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'profile-photos'
    and (select auth.uid())::text = (storage.foldername(name))[1]
  );

-- UPDATE: upsert için gerekli (INSERT + SELECT + UPDATE olmadan upsert sessizce başarısız olur).
create policy "profile_photos_storage_update_own"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'profile-photos'
    and (select auth.uid())::text = (storage.foldername(name))[1]
  )
  with check (
    bucket_id = 'profile-photos'
    and (select auth.uid())::text = (storage.foldername(name))[1]
  );

-- DELETE: kullanıcı kendi dosyasını silebilir.
create policy "profile_photos_storage_delete_own"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'profile-photos'
    and (select auth.uid())::text = (storage.foldername(name))[1]
  );
