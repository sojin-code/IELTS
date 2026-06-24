// 앱이 Supabase에 접속하기 위한 설정.
// url 은 채워뒀습니다. anonKey 한 곳만 붙여넣고 저장하세요.
//
// anon key 찾는 곳: Supabase → Project Settings → API →
//   "Project API keys" 의 anon / public 키 (또는 새 UI에선 "Publishable key", sb_publishable_... 로 시작)
//   ⛔ "service_role" 또는 "Secret key" 는 절대 넣지 마세요. (그건 비밀키)
//
// anon/publishable 키는 공개돼도 안전합니다 — RLS 정책이 데이터를 지킵니다.

window.SUPABASE_CONFIG = {
  url:     "https://peuvuvrsqlqsomybjqcw.supabase.co",
  anonKey: "sb_publishable_UV6hVgvuZLb6UFAjcwXMtg_5c17CfkB"
};
