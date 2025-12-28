#!/bin/bash

echo "🚀 ============================================"
echo "📦 백엔드 배포 시작..."
echo "============================================ 🚀"

# 배포 경로 설정 (인자로 전달받음)
DEPLOY_PATH=$1

# 1️⃣ 구버전 프로세스 종료
echo "1️⃣ 구버전 애플리케이션 종료 중..."
PID=$(ps aux | grep 'geulnamu-0.0.1-SNAPSHOT.jar' | grep -v grep | awk '{print $2}')

if [ -n "$PID" ]; then
  echo "   찾은 PID: $PID"
  kill -15 $PID  # SIGTERM으로 graceful shutdown 시도
  sleep 5
  
  # 프로세스가 아직 살아있으면 강제 종료
  if ps -p $PID > /dev/null; then
    echo "   Graceful shutdown 실패, 강제 종료..."
    kill -9 $PID
  fi
  
  echo "   ✅ 구버전 애플리케이션 종료 완료!"
else
  echo "   ℹ️ 실행 중인 애플리케이션이 없습니다."
fi

# 2️⃣ 오래된 로그 파일 정리 (30일 이전)
echo "2️⃣ 오래된 로그 파일 정리 중..."
cd $DEPLOY_PATH

# 30일 이전 로그 파일 개수 확인
OLD_LOG_COUNT=$(find . -maxdepth 1 -name "geulnamu_*.log" -mtime +30 2>/dev/null | wc -l)

if [ "$OLD_LOG_COUNT" -gt 0 ]; then
  echo "   🗑️ 30일 이전 로그 파일 $OLD_LOG_COUNT 개 발견"
  find . -maxdepth 1 -name "geulnamu_*.log" -mtime +30 -delete
  echo "   ✅ 오래된 로그 파일 삭제 완료!"
else
  echo "   ℹ️ 삭제할 오래된 로그 파일이 없습니다."
fi

# 현재 남아있는 로그 파일 개수
CURRENT_LOG_COUNT=$(ls -1 geulnamu_*.log 2>/dev/null | wc -l)
echo "   📁 현재 로그 파일 개수: $CURRENT_LOG_COUNT 개"

# 3️⃣ 새 애플리케이션 실행
echo "3️⃣ 새 애플리케이션 실행 중..."
cd $DEPLOY_PATH

# 환경변수 설정 (중요!)
echo "   🔧 환경변수 설정 중..."

# 1순위: 시스템 전역 bashrc (/etc/bash.bashrc)
if [ -f "/etc/bash.bashrc" ]; then
  echo "   📂 /etc/bash.bashrc에서 환경변수 로드 중..."
  source /etc/bash.bashrc
  echo "   ✅ /etc/bash.bashrc 로드 완료!"
fi

# 2순위: 사용자 환경변수 로드 (.bashrc, .profile 등)
if [ -f "$HOME/.bashrc" ]; then
  echo "   📂 ~/.bashrc에서 환경변수 로드 중..."
  source $HOME/.bashrc
  echo "   ✅ ~/.bashrc 로드 완료!"
elif [ -f "$HOME/.profile" ]; then
  echo "   📂 ~/.profile에서 환경변수 로드 중..."
  source $HOME/.profile
  echo "   ✅ ~/.profile 로드 완료!"
fi

# 3순위: /etc/environment (시스템 전역)
if [ -f "/etc/environment" ]; then
  echo "   📂 /etc/environment에서 환경변수 로드 중..."
  export $(cat /etc/environment | grep -v '^#' | xargs)
  echo "   ✅ /etc/environment 로드 완료!"
fi

# 2순위: .env 파일이 있으면 추가로 로드 (덮어쓰기)
if [ -f "$DEPLOY_PATH/.env" ]; then
  echo "   📂 .env 파일에서 환경변수 로드 중..."
  export $(cat $DEPLOY_PATH/.env | grep -v '^#' | xargs)
  echo "   ✅ .env 파일 로드 완료!"
fi

# 환경변수 확인 (디버깅)
echo "   🔍 주요 환경변수 확인:"
echo "      DB_HOST: ${DB_HOST:-(미설정)}"
echo "      DB_PORT: ${DB_PORT:-(미설정)}"
echo "      JWT_ACCESS_TOKEN_KEY: ${JWT_ACCESS_TOKEN_KEY:0:10}... (${#JWT_ACCESS_TOKEN_KEY}자)"

# 날짜와 시간이 포함된 로그 파일명 생성
LOG_FILE="geulnamu_$(date +%Y%m%d_%H%M%S).log"
echo "   📋 로그 파일: $LOG_FILE"

nohup java -Xms128m -Xmx384m -jar -Dspring.profiles.active=prod geulnamu-0.0.1-SNAPSHOT.jar > $LOG_FILE 2>&1 &

NEW_PID=$!
echo "   ✅ 새 애플리케이션 실행 완료! (PID: $NEW_PID)"

# 4️⃣ 프로세스 상태 확인 (10초 대기)
echo "4️⃣ 애플리케이션 시작 확인 중... (10초 대기)"
sleep 10

# 프로세스 상태 확인
if ps -p $NEW_PID > /dev/null; then
  echo "   ✅ 애플리케이션이 정상적으로 실행 중입니다!"
else
  echo "   ❌ 애플리케이션 실행 실패!"
  echo "   📋 최근 로그:"
  
  # 가장 최근 로그 파일 찾기
  LATEST_LOG=$(ls -t geulnamu_*.log 2>/dev/null | head -n 1)
  if [ -n "$LATEST_LOG" ]; then
    echo "   로그 파일: $LATEST_LOG"
    tail -n 20 $LATEST_LOG
  else
    echo "   로그 파일을 찾을 수 없습니다."
  fi
  
  exit 1
fi

echo "🎉 ============================================"
echo "✅ 백엔드 배포 완료!"
echo "============================================ 🎉"
