-- ===========================================================
--  IELTS 학습앱 — Supabase 스키마 & 보안 정책
--  적용: Supabase 대시보드 → SQL Editor → New query → 아래 전체 붙여넣기 → Run
--  (자동 RLS를 켜두셨어도, 아래에서 정책을 명시적으로 정의합니다.)
-- ===========================================================

-- 1) profiles : 사용자 1명당 1행 (auth.users와 연결)
create table if not exists public.profiles (
  id           uuid primary key references auth.users(id) on delete cascade,
  email        text,
  display_name text,
  current_level text default 'l1',
  is_admin     boolean not null default false,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

-- 2) user_state : 레벨별 학습 데이터 전체(앱의 DB 객체)를 통째로 저장
--    (사용자 1명 × 레벨(l1/l2/l3) 당 1행)
create table if not exists public.user_state (
  user_id    uuid not null references auth.users(id) on delete cascade,
  level      text not null,
  state      jsonb not null default '{}'::jsonb,  -- {scores, journal, vocab, days, results, ...}
  updated_at timestamptz not null default now(),
  primary key (user_id, level)
);

-- RLS 활성화 (안전을 위해 명시)
alter table public.profiles   enable row level security;
alter table public.user_state enable row level security;

-- 테이블 접근 권한(GRANT) — RLS 정책과 별개로 반드시 필요!
--   RLS = "어떤 '행'을 볼지" 거름 / GRANT = "테이블에 접근 자체"를 허용
--   이게 없으면 로그인해도 "permission denied for table" 에러가 납니다.
grant usage on schema public to anon, authenticated;
grant select, insert, update, delete on public.profiles   to authenticated;
grant select, insert, update, delete on public.user_state to authenticated;

-- 관리자 여부 헬퍼 (security definer = 내부 조회 시 RLS 우회 → 정책 재귀 방지)
create or replace function public.is_admin()
returns boolean language sql security definer stable as $$
  select coalesce((select is_admin from public.profiles where id = auth.uid()), false);
$$;

-- ---- profiles 정책 ----
drop policy if exists profiles_select on public.profiles;
create policy profiles_select on public.profiles
  for select using (id = auth.uid() or public.is_admin());   -- 본인 또는 관리자

drop policy if exists profiles_insert on public.profiles;
create policy profiles_insert on public.profiles
  for insert with check (id = auth.uid());                   -- 본인 행만 생성

drop policy if exists profiles_update on public.profiles;
create policy profiles_update on public.profiles
  for update using (id = auth.uid()) with check (id = auth.uid());

-- ---- user_state 정책 ----
drop policy if exists state_rw_own on public.user_state;
create policy state_rw_own on public.user_state
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());  -- 본인 읽기/쓰기

drop policy if exists state_select_admin on public.user_state;
create policy state_select_admin on public.user_state
  for select using (public.is_admin());                      -- 관리자는 전체 조회(읽기 전용)

-- 3) 신규 가입 시 profiles 행 자동 생성
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles (id, email, display_name)
  values (new.id, new.email, split_part(new.email, '@', 1))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ===========================================================
--  나를 관리자로 지정 (앱에서 한 번 가입/로그인한 뒤 실행)
--  아래 이메일을 본인 것으로 바꿔서 실행하세요:
--    update public.profiles set is_admin = true where email = 'somin1427@gmail.com';
-- ===========================================================
