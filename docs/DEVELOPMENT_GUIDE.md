# 글나무 개발 가이드

> 신규 개발자를 위한 프로젝트 설정 및 개발 규칙 안내

**🔗 관련 문서**  
[프로젝트 소개](../README.md) | [포트폴리오](./PORTFOLIO.md) | [프로젝트 구조 상세](./PROJECT_STRUCTURE.md) | [API 문서](https://api.geulnamu.com/docs/index.html)

---

## 📋 목차

1. [개발 환경 설정](#-개발-환경-설정)
2. [로컬 실행 방법](#-로컬-실행-방법)
3. [API 문서 활용](#-api-문서-활용)
4. [개발 규칙](#-개발-규칙)
5. [기능 상세 명세](#-기능-상세-명세)
6. [화면 구성](#-화면-구성)
7. [문의](#-문의)

---

## 🚀 개발 환경 설정

### 필수 도구

- **Java 17+**
- **MySQL 8.0+**
- **IntelliJ IDEA** (Lombok, Spring Boot 플러그인 설치)
- **Flutter SDK** (프론트엔드 개발 시)
- **Git**

### 프로젝트 클론

```bash
git clone https://github.com/jujang/Geulnamu.git
cd Geulnamu
```

### 데이터베이스 설정

```sql
-- MySQL에서 데이터베이스 생성
CREATE DATABASE geulnamu_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 환경변수 설정 (필수)

시스템 환경변수 또는 IDE에서 다음 변수들을 설정하세요:

```bash
MYSQL_SERVER_PASSWORD=your_mysql_password
JWT_ACCESS_TOKEN_KEY=your_jwt_access_token_secret
JWT_REFRESH_TOKEN_KEY=your_jwt_refresh_token_secret
KAKAO_CLIENT_ID=your_kakao_oauth_client_id
```

---

## 🏃 로컬 실행 방법

### 백엔드 실행

```bash
cd geulnamu_backend

# QueryDSL Q클래스 생성 (최초 1회 또는 엔티티 변경 시)
./gradlew generateQuerydsl

# 서버 실행
./gradlew bootRun

# 서버 접속: http://localhost:8080
```

### 프론트엔드 실행

```bash
cd geulnamu_frontend

# 의존성 설치
flutter pub get

# 웹 서버 실행
flutter run -d chrome

# 또는 PWA 빌드
flutter build web
```

### 테스트 실행

```bash
# 백엔드 테스트 + API 문서 생성
cd geulnamu_backend
./gradlew test

# 테스트 결과: build/reports/tests/test/index.html
# API 문서: build/docs/asciidoc/index.html
```

---

## 📖 API 문서 활용

### 문서 확인 방법

#### 온라인 문서

- **개발 환경**: http://localhost:8080/docs/index.html
- **프로덕션 환경**: https://api.geulnamu.com/docs/index.html

#### 로컬에서 문서 생성

```bash
cd geulnamu_backend

# 테스트 실행 (문서 자동 생성)
./gradlew test

# 문서만 재생성
./gradlew asciidoctor

# 생성 위치: build/docs/asciidoc/
```

### 주요 API 문서

| 기능              | 문서 파일                       | 설명                       |
| ----------------- | ------------------------------- | -------------------------- |
| **통합 가이드**   | `index.html`                    | 전체 API 개요 및 인증 방식 |
| **로그인 API**    | `login-api-guide.html`          | 카카오 OAuth, 토큰 관리    |
| **모임원 API**    | `member-api-guide.html`         | 회원 정보 관리, 권한 설정  |
| **모임 API**      | `meeting-api-guide.html`        | 모임 생성/조회/수정/삭제   |
| **출석 API**      | `attendance-api-guide.html`     | QR 출석, 출석 현황 관리    |
| **토론 그룹 API** | `discussion-api-guide.html`     | 토론 그룹 편성 및 관리     |
| **발제 API**      | `book-question-api-guide.html`  | 발제문 작성/조회/수정/삭제 |
| **VoC API**       | `voc-api-guide.html`            | 건의사항 및 이슈 관리      |
| **활동 내역 API** | `action-history-api-guide.html` | 시스템 로그 조회           |

### 문서 특징

- **실시간 동기화**: 테스트 코드와 연동되어 API 변경 시 자동 업데이트
- **실제 예시**: 모든 요청/응답은 실제 테스트에서 생성된 데이터
- **개발자 친화적**: 권한 레벨, 에러 코드, 사용 가이드 포함

---

## 📐 개발 규칙

### Git Flow 브랜치 전략

```
prod (프로덕션 배포)
 │
dev (통합 개발)
 ├── feature/backend/기능명
 ├── feature/frontend/기능명
 ├── docs/문서명
 ├── chore/작업명
 └── hotfix/긴급수정명
```

#### 브랜치 설명

- **prod**: 프로덕션(배포) 브랜치
- **dev**: 통합 개발 브랜치
- **feature/backend/**: 백엔드 기능 개발
- **feature/frontend/**: 프론트엔드 기능 개발
- **docs/**: 문서 작업
- **chore/**: 빌드 설정, 패키지 관리, CI/CD 등
- **hotfix/**: 긴급 수정 (prod에서 분기)

#### 브랜치 네이밍 규칙

- 소문자 영문, 숫자, 하이픈(`-`)만 사용
- 한글, 공백, 특수문자 사용 금지

#### 작업 플로우

```bash
# dev 최신화
git switch dev && git pull origin dev

# 기능 브랜치 생성
git switch -c feature/backend/login

# 개발 → 커밋 → 푸시
git add .
git commit -m "feat(be): 로그인 기능 추가"
git push origin feature/backend/login

# GitHub에서 PR 생성 → dev로 Merge
```

---

### 커밋 컨벤션

#### 커밋 메시지 형식

```
<type>(<scope>): <subject>
```

#### 타입 (Type)

| 타입       | 설명                                |
| ---------- | ----------------------------------- |
| `feat`     | 새로운 기능 추가                    |
| `fix`      | 버그 수정                           |
| `docs`     | 문서 수정 (README 등)               |
| `refactor` | 리팩토링 (기능 변화 없이 코드 개선) |
| `test`     | 테스트 코드 추가 또는 수정          |
| `chore`    | 설정 파일 수정 등 기타 작업         |

#### 스코프 (Scope)

- `be` (backend): 백엔드 관련 변경
- `fe` (frontend): 프론트엔드 관련 변경
- `common`: 공통 문서·설정
- 생략 가능 (범위가 명확하지 않을 때)

#### 제목 (Subject)

- 명령형/현재 시제 사용
- 50자 이내
- 마침표 생략

#### 예시

```bash
feat(be): 로그인 기능 추가
fix(fe): 로그인 페이지 오류 수정
docs(common): 커밋 전략 README 업데이트
refactor(be): 회원 서비스 코드 개선
test(be): 모임 생성 API 테스트 추가
chore: CI 설정 정리
```

---

## 📋 기능 상세 명세

> 💡 **참고**: 전체 시스템 아키텍처 및 프로젝트 구조는 [PORTFOLIO.md](./PORTFOLIO.md)와 [PROJECT_STRUCTURE.md](./PROJECT_STRUCTURE.md)를 참조하세요.

### 공통 기능 (일반 사용자)

#### 로그인 관련

- 로그인 (카카오 OAuth 2.0)
- 로그인 연장 (액세스 토큰 재발급)
- 로그아웃

#### 계정 관련

- 개인 정보 입력 여부 확인
- 개인 정보 조회
- 개인 정보 수정

#### 모임 관련

- 모임 목록 조회
- 모임 상세 조회
- 운영진 명단 조회 (모임 필터링용)
- 모임별 개인 출석 이력 확인

#### 출석 관련

- QR 코드 모임 출석
- 개인 출석 정보 조회
- 모임별 모임원 참석 현황 조회
- 출석 관련 비고 작성
- 모임 토론 비희망 설정
- 모임 토론 희망 재설정

#### 토론 관련

- 본인 토론 그룹 명단 조회

#### 발제 관련

- 발제문 작성
- 본인 발제문 리스트 조회
- 본인 토론 그룹 발제문 리스트 조회
- 모임 발제문 리스트 조회
- 발제문 수정
- 발제문 삭제

#### VoC(모임원의 소리) 관련

- 에러 보고
- 기능 요청

---

### 운영진·준운영진 전용

#### 모임원 관련

- 모임원 목록 조회 (운영진용)

#### 모임 관련

- 모임 생성
- 모임 상세 조회 (운영진용)
- 모임 수정 - 기본 (생성자 또는 관리자급만)
- 모임 수정 - 토론 관련 (생성자 또는 관리자급만)
- 모임 삭제 (생성자 또는 관리자급만)

#### 토론 관련

- 토론 참여 희망 명단 조회
- 모임별 토론 명단 조회
- 토론 그룹 구성

---

### 모임장·부모임장·관리자 전용

#### 모임원 관련

- 모임원 조회
- 모임원 등급 변경
- 모임원 이름 변경
- 모임원 활성화/비활성화

#### 모임 관련

- 지난 모임 비공개 처리
- 비공개 모임 공개 처리

#### 출석 관련

- 출석 삭제

#### 토론 관련

- 토론 그룹 할당 (개인)

#### VoC 관련

- 이슈 목록 조회
- 이슈 상태 변경

#### 로그 관련

- 로그 목록 조회

---

## 🖥️ 화면 구성

> 💡 **참고**: 실제 화면 스크린샷은 [PORTFOLIO.md](./PORTFOLIO.md)를 참조하세요.

### 메인 페이지

- '모임 소개 페이지' 이동 버튼
- '오늘의 모임 페이지' 이동 버튼
- '모임 출석 페이지' 이동 버튼 (출석 체크)
- '발제문 목록 페이지' 이동 버튼

### 상단 우측 구성

**로그인 전:**

- '로그인' 버튼

**로그인 후 (사용자 메뉴):**

- '프로필 페이지' 이동 버튼
- '설정 페이지' 이동 버튼
- '로그아웃' 버튼

### 좌측 사이드바 구성

**공통:**

- '메인 페이지' 이동 (아이콘)
- '모임 출석 페이지' 이동 (아이콘)
- '오늘의 모임 페이지' 이동 (아이콘)
- '개인 정보 페이지' 이동
- '모임 목록 페이지' 이동
- '발제문 페이지' 이동
- '모임원의 소리 페이지' 이동

**운영진 전용 (다른 색상):**

- '모임원 목록 페이지' 이동
- '모임 목록 페이지' 이동 (운영진용)

**관리자급 전용 (다른 색상):**

- '관리자 페이지' 이동

---

### 주요 화면별 상세

#### 1. 로그인 페이지

- 카카오 OAuth 2.0 로그인

#### 2. 모임 출석 페이지

- QR 코드 인식 모임 출석
- 출석 후 '오늘의 모임' 페이지로 자동 이동

#### 3. 오늘의 모임 페이지

- 당일 모임 목록 표시
- 1개: 즉시 상세 조회
- 2개+: 선택 후 상세 조회
- 모임 정보, 본인 토론 조, 토론조 발제 리스트 확인

**주요 버튼:**

- '비고 작성'
- '독서만 할래요'
- '토론 할래요'
- '발제문 작성'
- '발제문 수정'
- '발제문 삭제'

#### 4. 개인 정보 페이지

- 개인 정보 확인 및 수정
- '정보 수정' 버튼

#### 5. 모임 목록 페이지

- 페이지네이션 적용
- '모임 상세보기' 버튼
- '출석 현황 확인' 버튼

#### 6. 발제문 페이지

- 모임 선택 → 발제문 목록 조회
- '발제문 조회'
- '발제문 수정'
- '발제문 삭제'

#### 7. 모임원 목록 페이지 (운영진)

- 페이지네이션 적용
- '모임원 상세보기' 버튼 (관리자급만)

#### 8. 모임 목록 페이지 (운영진)

- '모임 생성' 버튼
- '모임 상세보기' 버튼
- 토론 참여 희망 명단 및 토론 조 명단 함께 조회

**주요 버튼:**

- '모임 수정'
- '토론 조 구성'
- '토론 조 할당 - 개인' (관리자급만)
- '모임 비공개' (관리자급만)
- '비공개 모임 공개' (관리자급만)
- '모임 삭제'

#### 9. 관리자 페이지 (관리자)

- '활동내역 페이지' 이동 버튼
  - 페이지네이션 적용, 로그 목록 확인
- '모임원의 소리 조회 페이지' 이동 버튼
  - 페이지네이션 적용, 이슈 목록 확인
  - '이슈 상태 변경' 버튼

#### 10. 모임원의 소리 페이지

- '에러 보고' 버튼
- '기능 요청' 버튼

#### 11. 토론 참여 알림 팝업

- 토론 시간에 동작
- 알림 메시지 조회
- '본인 토론 조 확인' 버튼 ('오늘의 모임' 페이지로 이동)

---

## 🔧 개발 도구 권장사항

### IDE 및 플러그인

- **IntelliJ IDEA**: Lombok, Spring Boot, Database Tools 플러그인
- **VS Code**: Flutter 확장

### DB 클라이언트

- MySQL Workbench
- DBeaver
- DataGrip (IntelliJ 통합)

### API 테스트

- **권장**: 생성된 REST Docs 활용
- 대안: Postman, Insomnia

### 유용한 명령어

```bash
# 백엔드 빌드
./gradlew clean build

# 캐시 클리어 후 빌드
./gradlew clean build --refresh-dependencies

# QueryDSL Q클래스 재생성
./gradlew clean generateQuerydsl

# 프론트엔드 종속성 업데이트
flutter pub upgrade

# 플러터 캐시 클리어
flutter clean
```

---

## 📞 문의

### 개발 관련 문의

- **GitHub Issues**: [Geulnamu Issues](https://github.com/jujang/Geulnamu/issues)
- **이메일**: [jeongookjang@naver.com](mailto:jeongookjang@naver.com)

### 이슈 리포팅 가이드

**버그 신고 시 포함할 정보:**

- 재현 단계
- 예상 동작 vs 실제 동작
- 환경 정보 (OS, 브라우저, Java 버전 등)
- 에러 로그/스크린샷

**기능 요청 시 포함할 정보:**

- 필요한 기능 설명
- 사용 사례
- 우선순위 (선택)

### 응답 시간

- **긴급 이슈**: 이메일로 직접 연락
- **일반 문의**: GitHub Issues 활용
- **응답 시간**: 보통 1-3일 내 (개인 프로젝트 특성상 시간이 걸릴 수 있습니다)

### 참고사항

- 개인 프로젝트이므로 즉시 대응이 어려울 수 있습니다
- **상세한 재현 단계**와 **환경 정보**를 포함하면 대응이 빨라집니다
- **API 관련 문의**는 [API 문서](https://api.geulnamu.com/docs/index.html)를 먼저 확인해 주세요

---

**🌟 프로젝트에 기여해주셔서 감사합니다!**
