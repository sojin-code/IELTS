@echo off
chcp 65001 >nul
cd /d "%~dp0"
set "LOG=deploy_log.txt"
echo ====== 실행 %DATE% %TIME% ====== > "%LOG%"

echo ============================================
echo   IELTS 앱 GitHub 배포 (sojin-code/sj)
echo ============================================
echo.

REM --- Git 설치 확인 ---
where git >> "%LOG%" 2>&1
if errorlevel 1 (
  echo [결과] Git이 설치돼 있지 않습니다.
  echo.
  echo  1) https://git-scm.com/download/win 에서 설치
  echo  2) 설치 후 이 deploy.bat 을 다시 더블클릭
  echo.
  echo [오류] Git 미설치 - where git 실패 >> "%LOG%"
  echo (이 내용은 deploy_log.txt 에도 저장됨)
  echo.
  echo 계속하려면 아무 키나 누르세요. . .
  pause >nul
  exit /b 1
)

echo [1/4] 저장소 확인/초기화...
if not exist ".git" (
  git init >> "%LOG%" 2>&1
  git branch -M main >> "%LOG%" 2>&1
  git remote add origin https://github.com/sojin-code/sj.git >> "%LOG%" 2>&1
)
git config user.email "sojin1427@khu.ac.kr" >> "%LOG%" 2>&1
git config user.name  "sojin-code" >> "%LOG%" 2>&1

echo [2/4] 변경사항 추가...
git add -A >> "%LOG%" 2>&1

echo [3/4] 커밋...
git commit -m "update %DATE% %TIME%" >> "%LOG%" 2>&1

echo [4/4] GitHub로 푸시... (처음 1회는 브라우저 로그인 창이 뜹니다)
git push -u origin main >> "%LOG%" 2>&1
if errorlevel 1 (
  echo  원격에 기존 파일이 있어 병합 후 재시도합니다...
  git pull --rebase origin main >> "%LOG%" 2>&1
  git push -u origin main >> "%LOG%" 2>&1
)

echo. >> "%LOG%"
echo ====== 종료 상태 코드: %errorlevel% ====== >> "%LOG%"

echo.
echo ============================================
echo   실행이 끝났습니다.
echo   아래는 실행 기록입니다 (deploy_log.txt 에도 저장됨):
echo ============================================
type "%LOG%"
echo.
echo 창을 닫지 말고, 위 내용을 그대로 알려주시면 도와드릴게요.
echo 계속하려면 아무 키나 누르세요. . .
pause >nul
