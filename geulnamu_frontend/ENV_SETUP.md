# 🔐 환경변수 설정 가이드

## 🚀 빠른 시작

### 1단계: .env 파일 생성
```bash
# 1. .env.example을 복사해서 .env 파일 생성
copy .env.example .env  # Windows
# 또는
cp .env.example .env    # Linux/Mac
```

### 2단계: 카카오 앱 키 입력
`.env` 파일을 열고 실제 카카오 앱 키들을 입력하세요:

```env
# 🔑 카카오 OAuth 키들 (프론트엔드용)
KAKAO_NATIVE_APP_KEY=여기에_실제_네이티브_앱키_입력
KAKAO_JAVASCRIPT_APP_KEY=여기에_실제_자바스크립트_키_입력
# REST_API_KEY는 백엔드에서 관리합니다
```

### 3단계: 백엔드 URL 설정
```env
# 🌐 백엔드 API 설정
API_BASE_URL=https://your-backend-domain.com/api
# 로컬 개발시: http://localhost:8080/api
```

---

## 📋 카카오 디벨로퍼스 콘솔에서 가져올 정보

### 프론트엔드에서 필요한 정보:
- **Native App Key**: 모바일 앱용 (안드로이드/iOS)
- **JavaScript Key**: 웹용 (PWA)

### 백엔드에서 관리하는 정보:
- **REST API Key**: 서버 통신용
- **Admin Key**: 관리용 (절대 클라이언트 사용 금지!)

---

## 🛡️ 보안 체크리스트

- [ ] `.env` 파일이 `.gitignore`에 포함되어 있는지 확인
- [ ] 카카오 Admin Key는 절대 클라이언트에서 사용하지 않기
- [ ] 운영 환경에서는 HTTPS 필수
- [ ] 리다이렉트 URI를 카카오 콘솔에 정확히 등록

---

## 🔧 문제 해결

### "카카오 앱 키가 설정되지 않았습니다" 오류
1. `.env` 파일이 존재하는지 확인
2. 키 값이 올바르게 입력되었는지 확인
3. 앱을 재시작해보세요

### 웹에서 카카오 로그인이 안될 때
1. JavaScript Key가 올바른지 확인
2. 도메인이 카카오 콘솔에 등록되어 있는지 확인
3. HTTPS 사용하고 있는지 확인

---

## 📱 플랫폼별 추가 설정

### Android
- 패키지명: `com.geulnamu.app`
- 키 해시 등록 필요

### iOS  
- 번들 ID: `com.geulnamu.app`
- URL Scheme 설정 필요

### Web
- 도메인: `https://geulnamu.com`
- JavaScript 도메인 등록 필요
