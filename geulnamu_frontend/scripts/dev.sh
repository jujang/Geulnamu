#!/bin/bash
# 🌿 글나무 - 개발 모드 실행 스크립트 (Linux/Mac)

echo "===================================="
echo "🌿 글나무 개발 모드 시작"
echo "===================================="

# .env 파일 존재 여부 확인
if [ ! -f ".env" ]; then
    echo "❌ .env 파일이 없습니다!"
    echo ".env.example을 복사해서 .env 파일을 만들고 실제 값을 입력해주세요."
    echo ""
    echo "명령어: cp .env.example .env"
    exit 1
fi

echo "✅ .env 파일 확인됨"
echo "🚀 플러터 앱 실행 중..."

# 웹 개발 모드로 실행
flutter run -d chrome --web-renderer html