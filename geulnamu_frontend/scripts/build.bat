@echo off
REM 🌿 글나무 - 프로덕션 빌드 스크립트 (Windows)

echo ====================================
echo 🌿 글나무 프로덕션 빌드
echo ====================================

REM .env 파일 존재 여부 확인
if not exist ".env" (
    echo ❌ .env 파일이 없습니다!
    echo .env.example을 복사해서 .env 파일을 만들고 실제 값을 입력해주세요.
    pause
    exit /b 1
)

echo ✅ .env 파일 확인됨
echo 🔧 의존성 설치 중...
call flutter pub get

echo 🏗️ 웹 빌드 시작...
call flutter build web --release

echo ✅ 빌드 완료!
echo 📁 빌드 결과물: build/web/

pause