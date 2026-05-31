-- 2.6B: Match/chat participant-based RLS policy'leri
-- Kapsam: matches, match_participants, messages
-- RLS enable 2.6A'da yapıldı; bu migration sadece policy ekler.
-- Client INSERT/UPDATE/DELETE: matches ve match_participants için yok (RPC üzerinden).
-- messages UPDATE/DELETE yok; okundu bilgisi ileride RPC veya ayrı policy ile ele alınacak.

-- ─── matches ─────────────────────────────────────────────────────────────────
-- Kullanıcı yalnızca participant olduğu match kayıtlarını okuyabilir.
create policy "matches_select_participant"
  on matches for select
  to authenticated
  using (
    exists (
      select 1
      from match_participants mp
      where mp.match_id = matches.id
        and mp.user_id = (select auth.uid())
    )
  );

-- ─── match_participants ───────────────────────────────────────────────────────
-- Kullanıcı yalnızca kendi participant satırını okuyabilir.
create policy "match_participants_select_own"
  on match_participants for select
  to authenticated
  using ((select auth.uid()) = user_id);

-- ─── messages ────────────────────────────────────────────────────────────────
-- SELECT: participant olduğu match'e ait tüm mesajları okuyabilir.
create policy "messages_select_participant"
  on messages for select
  to authenticated
  using (
    exists (
      select 1
      from match_participants mp
      where mp.match_id = messages.match_id
        and mp.user_id = (select auth.uid())
    )
  );

-- INSERT: kendi adına ve yalnızca aktif participant olduğu match'e mesaj gönderebilir.
create policy "messages_insert_active_participant"
  on messages for insert
  to authenticated
  with check (
    (select auth.uid()) = sender_id
    and exists (
      select 1
      from match_participants mp
      where mp.match_id = messages.match_id
        and mp.user_id = (select auth.uid())
        and mp.status = 'active'
    )
  );
