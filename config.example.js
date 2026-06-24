// ┌─────────────────────────────────────────────────────────────┐
// │  1) 이 파일을 복사해서 같은 폴더에 config.js 로 저장하세요.       │
// │  2) Supabase → Project Settings → API 에서 값 두 개를 채우세요.  │
// │                                                               │
// │  anonKey(=anon public key)는 프론트엔드에 넣는 용도라 공개돼도   │
// │  안전합니다(RLS가 데이터를 지킴).                                │
// │  ⛔ service_role 키와 DB 비밀번호는 절대 여기에 넣지 마세요.      │
// └─────────────────────────────────────────────────────────────┘
window.SUPABASE_CONFIG = {
  url:     "https://YOUR-PROJECT-ref.supabase.co",
  anonKey: "YOUR-ANON-PUBLIC-KEY"
};
