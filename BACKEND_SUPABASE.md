# Supabase 백엔드 설계서 (Phase 2)

공개 서비스로 키우기 위한 백엔드 구성입니다. 목표는 세 가지:
1. **계정 로그인** — 사용자별 신원
2. **클라우드 동기화** — 학습 데이터가 기기 간에 이어짐(폰↔PC)
3. **관리자 대시보드** — 사용자별 진도와 일지 피드백 열람

> 백엔드 구축(앱에 로그인·동기화·관리자 화면 붙이기)은 **Claude Code 작업**입니다. 이 문서엔 ①Supabase에서 직접 할 일, ②Claude Code에 붙여넣을 빌드 프롬프트가 모두 들어 있습니다.

---

## 1. 아키텍처 한눈에

```
[사용자 브라우저: index.html + config.js + supabase-js]
        │   로그인(이메일 매직링크)
        │   save() 때마다 내 state(jsonb) 업서트 / 로그인 시 내려받기
        ▼
[Supabase]  profiles(프로필·관리자여부)   user_state(레벨별 학습데이터 jsonb)
        ▲   RLS: 사용자는 자기 행만, 관리자는 전체 읽기
        │
[관리자(소진)]  관리자 탭 → 모든 사용자 진도·일지 열람
```

- 데이터는 **레벨별 앱 상태(DB)** 를 통째로 `user_state.state`(jsonb)에 저장합니다. 앱 구조를 거의 안 바꾸고 동기화만 추가하는 방식이라 안전합니다.
- 관리자 대시보드는 `state` 안의 `journal`·`scores`·`days`를 읽어 보여줍니다.

---

## 2. Supabase에서 직접 할 일 (소진 님)

**(A) 스키마·정책 적용**
1. Supabase 대시보드 → **SQL Editor → New query**
2. 같은 폴더의 **`supabase_schema.sql`** 전체를 붙여넣고 **Run**
   → `profiles`, `user_state` 테이블 + RLS 정책 + 신규가입 트리거가 생성됩니다.

**(B) 이메일 로그인 켜기**
1. **Authentication → Providers → Email** 활성화 (매직링크 방식 권장: 비밀번호 없이 링크로 로그인)
2. **Authentication → URL Configuration**
   - **Site URL**: `https://sojin-code.github.io/IELTS/`
   - **Redirect URLs**에도 같은 주소 추가 (이게 있어야 매직링크가 돌아옵니다)

**(C) 앱 연결값 채우기**
1. **Project Settings → API**에서 **Project URL**과 **anon public key** 복사
2. `config.example.js`를 복사해 **`config.js`** 로 저장하고 두 값을 넣기
   - ⛔ `service_role` 키, DB 비밀번호는 절대 넣지 마세요(프론트 공개 = 유출).

**(D) 나를 관리자로 지정** — 앱에서 **한 번 가입/로그인한 뒤**, SQL Editor에서:
```sql
update public.profiles set is_admin = true where email = 'somin1427@gmail.com';
```

---

## 3. Claude Code 빌드 프롬프트 (그대로 복사 → 저장소 폴더에서 Claude Code 실행 후 붙여넣기)

```
이 폴더는 GitHub Pages로 호스팅되는 IELTS 학습 단일 페이지 앱(index.html)이야.
지금은 데이터가 브라우저 localStorage(키: ielts_app_v2_<level>, level은 l1/l2/l3)에만 저장돼.
여기에 Supabase 백엔드를 붙여 (1) 로그인, (2) 클라우드 동기화, (3) 관리자 대시보드를 추가해줘.

[보존 — 매우 중요]
- 기존 기능(레벨 선택, DAY 잠금/하루1DAY, 리딩/리스닝 채점, 스피킹 음성인식, 라이팅,
  대시보드, 진도 그래프, 일지, 표현, JSON 백업)은 절대 깨지 말 것.
- content.<level>.json 로딩 방식과 레벨별 localStorage 구조는 그대로 유지.

[Supabase 연결]
- supabase-js v2를 CDN으로 로드: https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2
- 설정은 config.js의 window.SUPABASE_CONFIG(url, anonKey)에서 읽어. config.js가 없거나
  값이 비어 있으면 '로컬 전용 모드'로 기존처럼 동작(로그인 없이).

[인증]
- 이메일 매직링크 로그인(비밀번호 없음). 헤더에 로그인/로그아웃 버튼.
- 첫 로그인/가입 시 개인정보 동의 체크박스 필수:
  "학습 데이터와 일지가 기기 간 동기화를 위해 저장되며, 서비스 관리자가 코칭·지원 목적으로
   열람할 수 있음에 동의합니다." 동의해야 진행.

[동기화]
- 로그인 상태에서 save() 호출 시 user_state에 업서트:{user_id, level, state, updated_at}.
  과도한 쓰기 방지로 1~2초 디바운스.
- 로그인 시(그리고 레벨 전환 시) 해당 레벨 user_state를 불러와 로컬 DB와 병합
  (updated_at이 최신인 쪽 우선) 후 화면 갱신.
- 오프라인이면 localStorage로 동작, 온라인 복귀 시 동기화.
- profiles.current_level도 레벨 변경 시 함께 업데이트.

[관리자 대시보드]
- profiles.is_admin = true 인 사용자에게만 보이는 '관리자' 탭/화면.
- 기능: 사용자 목록(이메일·표시이름·현재레벨) → 각 사용자 클릭 시 레벨별 완료 DAY 수,
  최근 밴드(state.scores), 일지 항목(state.journal: 날짜·활동·회고 메모)을 열람.
- 비관리자에겐 이 탭이 보이지 않게(데이터는 RLS가, UI는 코드가 숨김).

[스키마/정책]
- 테이블·RLS·트리거는 supabase_schema.sql로 이미 적용됨(profiles, user_state, is_admin(),
  정책, on_auth_user_created 트리거). 앱은 이 구조에 맞춰 읽고 써줘.

[보안]
- anon 키만 프론트에 사용. service_role 키·DB 비밀번호는 절대 코드/저장소에 넣지 말 것.
- 모든 테이블 접근은 RLS에 의존(사용자=자기 데이터, 관리자=전체 읽기).

[완료 후]
- 로컬 테스트 방법, config.js 채우는 법, 관리자 지정 SQL을 README에 정리.
- 변경 요약과, 혹시 깨질 위험이 있는 부분을 알려줘.
```

---

## 4. 개인정보·보안 체크리스트

- 일지는 개인적인 내용이라 **동의 + RLS**로 보호합니다(위 동의 문구·정책 포함).
- 관리자도 RLS상 **읽기만** 가능하게 설계했습니다(수정 권한 없음).
- `anon` 키는 공개 전제(프론트에 노출돼도 RLS가 막음). `service_role`·DB 비번은 **절대 금지**.
- GitHub 저장소에 `config.js`를 올려도 anon 키라 괜찮지만, 원치 않으면 `.gitignore`에 `config.js`를 넣고 배포 환경에서만 주입하세요.

## 5. 다음 단계 제안

1. 위 2번(Supabase 설정)부터 진행 → 막히면 화면 캡처해 주세요.
2. `config.js` 준비되면 3번 프롬프트로 Claude Code에서 빌드.
3. 빌드 후 함께 테스트(가입→동기화→관리자 열람) → 문제 잡기.
4. 이후 레벨별 180일 콘텐츠를 스킬/스케줄로 대량 생성.
