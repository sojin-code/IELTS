# 빌드 & 운영 프롬프트 모음

웹페이지 외부화를 위한 작업 분담:
- **Claude Code** = 복잡한 코딩 (프로젝트 구조, PWA, 오프라인, 배포, 선택적 동기화)
- **Cowork** = 매일 콘텐츠 갱신 (`content.json` 수정·커밋)

아래 프롬프트를 그대로 복사해서 쓰세요.

---

## 0. 가장 빠른 시작 (코딩 없이 5분 배포)

1. GitHub에서 새 저장소 생성 (예: `ielts-study`, **Public**).
2. `index.html` 과 `content.json` 두 파일 업로드.
3. 저장소 **Settings → Pages → Source: main 브랜치 / root** 선택 → 저장.
4. 몇 분 뒤 `https://<아이디>.github.io/ielts-study/` 로 접속.
5. 아이폰·아이패드: Safari로 접속 → 공유 → **홈 화면에 추가**. 안드로이드: Chrome 메뉴 → **앱 설치**.

> 음성 인식은 **Chrome(데스크톱·안드로이드)·Safari(iOS 14.5+)**에서 작동합니다.
> 기록은 기기별 브라우저에 저장됩니다. 다른 기기로 옮길 땐 일지 탭의 **JSON 내보내기/가져오기**를 쓰세요.

---

## 1. Claude Code 프롬프트 — 정식 프로젝트로 빌드

> 시작용 `index.html` 과 `content.json` 을 빈 폴더에 넣고, 그 폴더에서 Claude Code를 실행한 뒤 아래를 붙여넣으세요.

```
이 폴더의 index.html과 content.json은 IELTS 6개월 학습용 웹앱의 시작점이야.
이걸 GitHub Pages에 배포할 정식 PWA 프로젝트로 발전시켜줘. 요구사항:

1. PWA 완성: manifest.json(앱 이름 "IELTS Master", 테마색 #0f6e56, standalone, 아이콘 192/512)
   과 service worker(sw.js)를 추가해 오프라인에서도 앱 셸이 열리게 해줘.
   단, content.json은 항상 네트워크 우선(no-store)으로 가져와 매일 갱신이 반영되게 해.
2. 기존 index.html의 기능(음성 인식, 점수/일지/어휘 localStorage, 오늘의 계획)은 절대 깨지 않게 유지.
3. 코드를 모듈로 정리: app.js(로직), styles.css(스타일)로 분리하고 index.html은 마크업만.
4. 음성 인식의 iOS Safari 호환성을 점검해줘(continuous 모드가 끊기면 자동 재시작 유지).
5. 간단한 GitHub Actions 워크플로(.github/workflows/pages.yml)로 main 푸시 시 자동 배포되게 해줘.
6. README.md에 배포 방법과 매일 content.json 갱신 방법을 정리해줘.

전부 정적 호스팅으로 동작해야 하고, 외부 유료 서비스 없이 무료로 운영 가능해야 해.
완료 후 로컬에서 테스트하는 방법을 알려줘.
```

### 선택 — 기기 간 기록 동기화가 필요해지면 (Firebase)

```
지금 학습 기록이 localStorage라 기기마다 따로 저장돼. 컴퓨터·아이패드·폰에서
같은 기록을 보도록 Firebase Firestore 동기화를 추가해줘. 요구사항:
- 익명 로그인 또는 이메일 링크 로그인(둘 중 더 간단한 쪽) 한 가지.
- 점수/일지/어휘/스피킹 기록을 Firestore에 저장하고, 오프라인일 땐 localStorage로
  폴백한 뒤 온라인 복귀 시 병합.
- Firebase 설정값(apiKey 등)은 config.js로 분리하고, 내가 직접 값을 넣을 수 있게
  자리표시자와 설정 방법을 README에 적어줘.
- 무료 Spark 요금제 한도 안에서 동작하도록 읽기/쓰기를 최소화해줘.
```

---

## 2. Cowork 프롬프트 — 매일 새 DAY 추가 (새 챗 불필요)

> 앱은 이제 `content.json`의 **`days` 배열**로 동작합니다. 하루에 한 DAY씩 진행되고,
> 4파트(리딩·리스닝·스피킹·라이팅)를 모두 끝내면 **다음 날** 다음 DAY가 자동으로 열립니다.
> 그래서 Cowork의 일은 "남은 DAY가 부족하지 않게 새 DAY를 계속 채워두는 것"입니다.
> Cowork에서 이 저장소 폴더(또는 GitHub 연동)를 열고, 아래를 반복 작업으로 등록하세요.

```
이 저장소의 content.json을 관리하는 게 네 일이야. days 배열에 IELTS 연습 DAY를 채워둬.
매번 실행할 때:

1. content.json을 읽고, days 배열에서 "아직 학습자가 완료하지 않은 미래 DAY"가 몇 개
   남았는지 확인해. (앱은 하루 1 DAY씩 소비함.) 남은 미래 DAY가 5개 미만이면 새 DAY를 추가해.
2. 새 DAY는 마지막 day 번호 +1부터 이어서 만들고, 각 DAY에 reading·listening·speaking·
   writing 네 파트를 모두 넣어. 아래 [스키마]를 정확히 따라.
3. 난이도: 학습자는 IELTS 5.0~5.5에서 7.0으로 가는 중. day 번호가 올라갈수록 지문 길이와
   어휘 난도를 조금씩 높여(주차 기준: 1~8주 기초, 9~16주 전략, 17~22주 실전, 23~26주 마무리).
   한 문단에 모르는 단어가 10개 넘게 나올 난도면 낮춰.
4. 저작권 안전: 케임브리지 등 기출 지문/음원을 그대로 복사하지 마. 같은 유형·난이도의
   '원본' 지문과 대본을 직접 작성해. 리스닝은 오디오 파일 없이 script(대본)만 주면 됨
   (앱이 브라우저 음성합성으로 읽어줌). accent는 en-GB/en-AU/en-US 중 선택.
5. 정답 키 필수: 모든 reading/listening 문제에 정답을 넣어.
   - tfng: "a"는 "TRUE"/"FALSE"/"NOT GIVEN" 중 하나(대문자).
   - mcq: "options" 배열 + "a"는 정답 보기의 글자("A"/"B"/...).
   - gap: 빈칸은 문제 텍스트에 ________(밑줄)로 표시하고, "a"는 허용 정답 배열
     (숫자는 숫자/영어단어 둘 다, 예: ["15","fifteen"]).
   speaking은 {part,q}, writing은 {task,minWords,minutes,q}. (task는 "t1" 또는 "t2";
   t1은 시각자료 대신 데이터 표를 q 안에 텍스트로 넣어줘.)
6. meta.lastUpdated를 오늘 날짜로 갱신해.
7. JSON 문법을 검증하고(파서로 한 번 파싱), 정답 글자가 보기 범위 안인지 확인한 뒤,
   "chore: add days N~M (YYYY-MM-DD)" 메시지로 커밋·푸시해.
   (푸시 같은 외부 반영 작업은 실행 전 나에게 한 번 확인받아.)
8. 추가한 DAY 번호와 주제를 3줄로 보고해.
```

> **참고:** Cowork이 GitHub에 커밋/푸시하는 건 외부에 공개 반영되는 작업이므로,
> 실행 전 확인을 받도록 위 7단계에 명시해 두었습니다.

### content.json days 스키마 (이 형식을 그대로 따르게 하세요)

```json
{
  "day": 6,
  "reading": {
    "title": "지문 제목", "minutes": 20,
    "passage": "문단1\n\n문단2\n\n문단3 ...",
    "questions": [
      { "type": "tfng", "q": "진술문.", "a": "TRUE" },
      { "type": "gap",  "q": "... ________ ...", "a": ["answer", "동의어"] },
      { "type": "mcq",  "q": "질문?", "options": ["A보기","B보기","C보기","D보기"], "a": "B" }
    ]
  },
  "listening": {
    "title": "음원 제목", "accent": "en-GB", "rate": 0.95,
    "script": "SPEAKER: 대본 ...",
    "questions": [ { "type": "gap", "q": "... ________", "a": ["..."] } ]
  },
  "speaking": { "part": "p2", "q": "스피킹 질문/큐카드" },
  "writing":  { "task": "t2", "minWords": 250, "minutes": 40, "q": "에세이 문제" }
}
```

> 한 DAY = 리딩 1지문(6~8문항) + 리스닝 1음원(6문항) + 스피킹 1문제 + 라이팅 1과제 기준.
> 앱은 reading/listening만 자동 채점하고, speaking/writing은 "AI 피드백용 복사" 버튼으로
> Claude에 붙여 채점받는 구조이므로 정답 키는 reading/listening에만 있으면 됩니다.

---

## 3. 폴더 구조 (Claude Code 빌드 후 예상)

```
ielts-study/
├─ index.html          # 마크업
├─ app.js              # 로직 (음성인식·기록·차트)
├─ styles.css          # 스타일
├─ content.json        # Cowork이 매일 갱신
├─ manifest.json       # PWA
├─ sw.js               # 서비스 워커(오프라인)
├─ icons/              # 192/512 아이콘
├─ progress.md         # 주차별 밴드 기록(코치가 관리)
├─ README.md
└─ .github/workflows/pages.yml
```

---

## 4. 흐름 요약

```
[Cowork] content.json 매일 갱신·커밋  ──►  [GitHub 저장소]
                                              │  (GitHub Pages 자동 배포)
                                              ▼
        컴퓨터 · 아이패드 · 폰 어디서든  ──►  [웹페이지]  ◄── 음성 인식·기록 입력
                                              │
                              스피킹 답변 텍스트 복사  ──►  [Claude 앱]에서 밴드 피드백
```

매일 새 챗을 켤 필요 없이, 웹페이지를 열기만 하면 **오늘의 DAY** 과제(리딩·리스닝·스피킹·
라이팅)가 떠 있고, 4파트를 모두 끝내면 다음 날 다음 DAY가 자동으로 열립니다.
리딩·리스닝은 앱이 즉시 채점하고, 스피킹·라이팅은 "AI 피드백용 복사" 버튼으로 Claude에
붙여넣어 밴드 피드백을 받으면 됩니다. Cowork은 남은 DAY가 떨어지지 않게 새 DAY만 채워두면 됩니다.
