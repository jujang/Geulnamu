# 글나무 서비스

**글나무 서비스**는 독서 토론 모임인 '글나무'의 모임 활동을 효율적으로 관리하기 위한 웹 기반 서비스입니다.  
운영진, 관리자, 일반 사용자 등 사용자 권한에 따라 다양한 모임 관련 기능과 관리 기능을 제공합니다.

---

## 🛠️ (백엔드) 주요 기능

### 📌 공통 기능 (일반 사용자)

- 로그인 관련
  - 로그인 (C)
  - 로그인 연장 (액세스 토큰 재발급) (C)
  - 로그아웃 (C)
- 계정 관련
  - 개인 정보 입력 여부 확인 (R)
  - 개인 정보 조회 (R)
  - 개인 정보 수정 (U)
- 모임 관련
  - 모임 목록 조회 (R)
  - 모임 상세 조회 (R)
  - 운영진 명단 조회 - 모임 필터링용 (R)
  - 모임별 개인 출석 이력 확인 (R)
- 출석 관련
  - 모임 출석 (C)
    - (추후 개발 기능) GPS 연동 출석 처리
  - 개인 출석 정보 조회 (R)
  - 모임별 모임원 참석 현황 조회 (R)
  - 출석 관련 비고 작성 (U)
  - 모임 토론 비희망 설정 (U)
  - 모임 토론 희망 재설정 (U)
- 토론 관련
  - 본인 토론 그룹 명단 조회 (R)
- 발제 관련
  - 발제문 작성 (C)
    - (추후 개발 기능) 발제문 내용 맞춤법 검사 (R)
  - 본인 발제문 리스트 조회 (R)
  - 본인 토론 그룹 발제문 리스트 조회 (R)
  - 모임 발제문 리스트 조회 (R)
  - 발제문 수정 (U)
  - 발제문 삭제 (D)
- VoC(모임원의 소리) 관련
  - 에러 보고 (C)
  - 기능 요청 (C)

### 🛡 운영진·준운영진

- 모임원 관련
  - 모임원 목록 조회 (운영진용) (R)
- 모임 관련
  - 모임 생성 (C)
  - 모임 상세 조회 (운영진용) (R)
  - 모임 수정 - 기본 (모임 생성자 또는 관리자급만 가능) (U)
  - 모임 수정 - 토론 관련 (모임 생성자 또는 관리자급만 가능) (U)
  - 모임 삭제 (모임 생성자 또는 관리자급만 가능) (D)
- 토론 관련
  - 토론 참여 희망 명단 조회 (R)
  - 모임별 토론 명단 조회 (R)
  - 토론 그룹 구성 (U)

### 👑 모임장·부모임장·관리자

- 모임원 관련
  - 모임원 조회 (R)
  - 모임원 등급 변경 (U)
  - 모임원 이름 변경 (U)
  - 모임원 활성화/비활성화 (U)
- 모임 관련
  - 지난 모임 비공개 처리 (U)
  - 비공개 모임 공개 처리 (U)
- 출석 관련
  - 출석 삭제 (D)
- 토론 관련
  - 토론 그룹 할당 - 개인 (U)
- VoC(모임원의 소리) 관련
  - 이슈 목록 조회 (R)
  - 이슈 상태 변경 (U)
- 로그 관련
  - 로그 목록 조회 (R)

---

## 🖥️ 화면 구성

- **메인 페이지**
  - '모임 소개 페이지' 이동 버튼
  - '오늘의 모임 페이지' 이동 버튼
  - '모임 출석 페이지' 이동 버튼 (=출석 체크)
  - '발제문 목록 페이지' 이동 버튼
- **우측 상단 구성(로그인 전)**
  - '로그인' 버튼
- **우측 사용자 메뉴 구성(로그인 후)**
  - '프로필 페이지' 이동 버튼
  - '설정 페이지' 이동 버튼
  - '로그아웃' 버튼
- **좌측 사이드바 구성**
  - '메인 페이지' 이동 버튼 (아이콘 사용)
  - '모임 출석 페이지' 이동 버튼 (아이콘 사용)
  - '오늘의 모임 페이지' 이동 버튼 (아이콘 사용)
  - '개인 정보 페이지' 이동 버튼
  - '모임 목록 페이지' 이동 버튼
  - '발제문 페이지' 이동 버튼
  - '모임원 목록 페이지' 이동 버튼 (운영진 전용 기능 - 다른 색 사용)
  - '모임 목록 페이지' 이동 버튼 (운영진 전용 기능 - 다른 색 사용)
  - '관리자 페이지' 이동 버튼 (관리자급 전용 기능 - 다른 색 사용)
  - '모임원의 소리 페이지' 이동 버튼
- **로그인 페이지**  
  카카오 OAuth 2.0 로그인
- **모임 출석 페이지**  
  QR 인식 모임 출석 페이지, 출석 이후 '오늘의 모임' 페이지로 이동
- **오늘의 모임 페이지**  
  당일 존재하는 모임 조회 페이지 (모임 관련 정보 및 본인 토론 조, 토론조 발제 리스트 확인 가능)
  -> 당일 존재하는 모임이 1개일 경우, 바로 해당 모임 상세 조회  
  -> 당일 존재하는 모임이 2개 이상일 경우, 목록 중 선택 후 상세 조회 (모임 관련 정보 및 본인 토론 조 확인 가능)
  - '비고 작성' 버튼
  - '독서만 할래요' 버튼
  - '토론 할래요' 버튼
  - '발제문 작성' 버튼
  - '발제문 수정' 버튼
  - '발제문 삭제' 버튼
- **개인 정보 페이지**  
  개인 정보 확인 및 수정 페이지
  - '정보 수정' 버튼
- **모임 목록 페이지**  
  페이지네이션 적용된 모임 목록 조회 페이지
  - '모임 상세보기(모임 단일 조회)' 버튼
    - **모임 조회 페이지**  
      모임 단일 조회 페이지 (모임 관련 정보 및 본인 토론 조, 토론조 발제 리스트 확인 가능)
      - '비고 작성' 버튼
      - '독서만 할래요' 버튼
      - '토론 할래요' 버튼
  - '출석 현황 확인' 버튼
    - **출석 현황 페이지**  
      모임별 모임원 출석 현황 확인 페이지
- **발제문 페이지**  
  모임 목록이 조회되고 선택시 모임 단위의 발제문 목록이 조회되는 페이지
  - '발제문 조회'(모임 선택) 버튼
  - '발제문 수정' 버튼
  - '발제문 삭제' 버튼
- **모임원 목록 페이지 - 운영진**  
  페이지네이션 적용된 모임원 목록 조회 페이지
  - '모임원 상세보기' 버튼 (관리자급만 사용 가능)
    - **모임원 조회 페이지 - 관리자급**  
      모임원 조회 및 정보 수정, 활성화/비활성화 페이지
      - '모임원 이름 변경' 버튼
      - '모임원 등급 변경' 버튼
      - '모임원 비활성화' 버튼
- **모임 목록 페이지 - 운영진**  
  페이지네이션 적용된 모임 목록 조회 페이지
  - '모임 생성' 버튼
    - **모임 생성 페이지**  
      모임 정보 입력 및 모임 생성 페이지
  - '모임 상세보기' 버튼
    - **모임 조회 페이지**  
      모임 조회 및 수정 페이지 (토론 참여 희망 명단 및 토론 조 명단 함께 조회)
      - '모임 수정' 버튼
      - '토론 조 구성' 버튼
        - **토론 조 구성 페이지**  
          토론 조 구성 페이지 (토론 참여 희망 명단 함께 조회)
      - '토론 조 할당 - 개인' 버튼 (관리자급만 사용 가능)
      - '모임 비공개' 버튼 (관리자급만 사용 가능)
      - '비공개 모임 공개' 버튼 (관리자급만 사용 가능)
      - '모임 삭제' 버튼
  - '모임 삭제' 버튼
- **관리자 페이지 - 관리자**  
  시스템 관리용 기능 사용이 가능한 페이지
  - '활동내역 페이지'이동 버튼
    - **활동내역 페이지**  
      페이지네이션이 적용된 저장된 로그 목록 확인이 가능한 페이지
  - '모임원의 소리 조회 페이지' 이동 버튼
    - **모임원의 소리 페이지**  
      페이지네이션이 적용된 모임원의 소리(이슈) 목록 확인이 가능한 페이지
      - '이슈 상태 변경' 버튼
- **모임원의 소리 페이지**  
  건의사항 작성이 가능한 페이지 (2가지 유형의 건의사항 작성 가능)
  - '에러 보고' 버튼
  - '기능 요청' 버튼
- **토론 참여 알림 팝업**  
  토론 시간에 동작하는 토론 참여 알림 팝업 (알림 메세지 조회 가능)
  - '본인 토론 조 확인' 버튼 ('오늘의 모임' 페이지로 이동)

---

## 🛠️ 기술 스택

### 💻 Backend

- **Java 17** + **Spring Boot 3.4.5**
- **MySQL 8.0** + **Spring Data JPA** + **QueryDSL**
- **Spring Security** + **JWT** + **카카오 OAuth 2.0**
- **Spring REST Docs** (API 문서 자동화)

### 📱 Frontend

- **Flutter** (모바일 웹앱, 개발 예정)

### ☁️ 배포

- **Firebase** (예정)

---

## 📁 프로젝트 구조

```
geulnamu/
├── 📂 geulnamu-backend/          # Spring Boot API 서버
│   ├── 📂 src/main/java/com/geulnamu/
│   │   ├── 📂 controller/        # REST API 컨트롤러
│   │   │   ├── login/           # 로그인 관련
│   │   │   ├── member/          # 회원 관리
│   │   │   ├── meeting/         # 모임 관리
│   │   │   ├── attendance/      # 출석 관리
│   │   │   ├── bookQuestion/    # 발제 관리
│   │   │   ├── voc/             # VoC(모임원의 소리)
│   │   │   └── actionHistory/   # 활동 내역
│   │   ├── 📂 service/          # 비즈니스 로직
│   │   ├── 📂 repository/       # 데이터 접근 (JPA + QueryDSL)
│   │   │   ├── CommandRepository.java  # CUD 작업
│   │   │   └── QueryRepository.java    # 조회 작업
│   │   ├── 📂 domain/           # 엔티티 및 도메인 모델
│   │   └── 📂 infrastructure/   # 설정, 보안, 유틸리티
│   │       ├── config/         # 설정 클래스
│   │       ├── security/       # JWT, OAuth 보안
│   │       ├── annotation/     # 커스텀 어노테이션
│   │       └── aspect/         # AOP (로깅 등)
│   ├── 📂 src/test/             # 테스트 코드 (REST Docs 포함)
│   └── 📂 build/docs/           # 생성된 API 문서
├── 📂 geulnamu-frontend/         # Flutter 모바일 앱
└── 📄 README.md
```

### 🏗️ 아키텍처 특징

- **도메인 중심 설계**: 각 기능별로 패키지 분리
- **계층형 아키텍처**: Controller → Service → Repository
- **CQRS 패턴**: Command/Query Repository 분리
- **JWT 기반 인증**: 액세스/리프레시 토큰 분리 관리
- **AOP 활용**: `@LogAction`, `@ErrorLogAction` 어노테이션으로 액션 히스토리 자동 기록
- **테스트 기반 문서화**: Spring REST Docs 활용

---

## 🛠️ 개발환경 설정

### 🚀 로컬 실행 방법

#### 1. 프로젝트 클론

```bash
git clone https://github.com/jujang/Geulnamu.git
cd Geulnamu/geulnamu-backend
```

#### 2. 데이터베이스 설정

```sql
-- MySQL에서 데이터베이스 생성
CREATE DATABASE geulnamu_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

#### 3. 환경변수 설정 (필수)

```bash
# 시스템 환경변수 또는 IDE에서 설정
MYSQL_SERVER_PASSWORD=your_mysql_password
JWT_ACCESS_TOKEN_KEY=your_jwt_access_token_secret
JWT_REFRESH_TOKEN_KEY=your_jwt_refresh_token_secret
KAKAO_CLIENT_ID=your_kakao_oauth_client_id
```

#### 4. 애플리케이션 실행

```bash
# QueryDSL Q클래스 생성 (최초 1회)
./gradlew generateQuerydsl

# 서버 실행
./gradlew bootRun
```

### 📖 API 문서 확인

- **서버 실행 후**: http://localhost:8080/docs/index.html
- **문서 재생성**: `./gradlew test asciidoctor`

### 🧪 테스트 실행

```bash
# 전체 테스트 + API 문서 생성
./gradlew test

# 테스트 결과: build/reports/tests/test/index.html
```

### 🔧 개발 도구 권장사항

- **IDE**: IntelliJ IDEA (Lombok, Spring Boot 플러그인 설치)
- **DB 클라이언트**: MySQL Workbench, DBeaver 등
- **API 테스트**: 생성된 REST Docs 활용

---

## 📖 API 문서

### 🌐 온라인 문서

- **개발 환경**: http://localhost:8080/docs/index.html
- **프로덕션 환경**: https://api.geulnamu.com/docs/index.html (배포 후)

### 📋 주요 API 문서

| 기능              | 문서                                                                                                  | 설명                       |
| ----------------- | ----------------------------------------------------------------------------------------------------- | -------------------------- |
| **통합 가이드**   | [index.html](./geulnamu-backend/build/docs/asciidoc/index.html)                                       | 전체 API 개요 및 인증 방식 |
| **로그인 API**    | [login-api-guide.html](./geulnamu-backend/build/docs/asciidoc/login-api-guide.html)                   | 카카오 OAuth, 토큰 관리    |
| **모임원 API**    | [member-api-guide.html](./geulnamu-backend/build/docs/asciidoc/member-api-guide.html)                 | 회원 정보 관리, 권한 설정  |
| **모임 API**      | [meeting-api-guide.html](./geulnamu-backend/build/docs/asciidoc/meeting-api-guide.html)               | 모임 생성/조회/수정/삭제   |
| **출석 API**      | [attendance-api-guide.html](./geulnamu-backend/build/docs/asciidoc/attendance-api-guide.html)         | QR 출석, 출석 현황 관리    |
| **토론 그룹 API** | [discussion-api-guide.html](./geulnamu-backend/build/docs/asciidoc/discussion-api-guide.html)         | 토론 그룹 편성 및 관리     |
| **발제 API**      | [book-question-api-guide.html](./geulnamu-backend/build/docs/asciidoc/book-question-api-guide.html)   | 발제문 작성/조회/수정/삭제 |
| **VoC API**       | [voc-api-guide.html](./geulnamu-backend/build/docs/asciidoc/voc-api-guide.html)                       | 건의사항 및 이슈 관리      |
| **활동 내역 API** | [action-history-api-guide.html](./geulnamu-backend/build/docs/asciidoc/action-history-api-guide.html) | 시스템 로그 조회           |

### 🛠️ 로컬에서 문서 확인하기

```bash
# 백엔드 디렉토리로 이동
cd geulnamu-backend

# 문서 생성
./gradlew asciidoctor

# 서버 실행 후 접속
./gradlew bootRun
# 브라우저에서 http://localhost:8080/docs/index.html 접속
```

### 📝 문서 특징

- **실시간 동기화**: 테스트 코드와 연동되어 API 변경 시 자동 업데이트
- **실제 예시**: 모든 요청/응답은 실제 테스트에서 생성된 데이터
- **포괄적 커버리지**: 모든 엔드포인트 대응
- **개발자 친화적**: 권한 레벨, 에러 코드, 사용 가이드 제공

---

## 📊 액션 로깅 시스템

시스템의 중요한 사용자 활동을 자동으로 추적하고 기록하는 로깅 시스템이 구축되어 있습니다.

### 주요 특징

- **자동 로깅**: `@LogAction` 어노테이션으로 메서드 실행 시 자동 기록
- **비동기 처리**: 메인 로직에 영향 없이 별도 스레드에서 로그 저장
- **보안 고려**: 비밀번호, 토큰 등 민감 정보 자동 마스킹

### 기록 정보

- 액션 타입 (로그인, 모임 생성/수정/삭제, 회원 관리 등)
- 요청자 정보, 대상 엔티티, 처리 결과 (성공/실패)
- 요청/응답 데이터, 처리 시간, IP 주소

### 사용법

```java
@LogAction(value = ActionType.MEMBER_LOGIN, actionDomain = "login")
public BaseResponse<LoginResponse> login() {
    // 비즈니스 로직
}
```

**용도**: 서비스 사용 패턴 분석, 문제 추적, 보안 모니터링

---

## 🧩 데이터베이스 스키마

본 프로젝트의 DB 설계는 아래 ERD를 기반으로 구성되어 있습니다.

🔗 [ERD 보기 (ERDCloud)](https://www.erdcloud.com/d/mgGNCamYYs28DYphr)

### 주요 테이블 요약

| 테이블          | 설명                          |
| --------------- | ----------------------------- |
| `Member`        | 회원 기본 정보 및 등급        |
| `Meeting`       | 모임 정보 (정기/번개/특수)    |
| `Attendance`    | 모임 회차별 출석 및 그룹 정보 |
| `BookQuestion`  | 발제 내용                     |
| `VoC`           | 모임원 건의사항               |
| `ActionHistory` | 모임원 활동 내역              |

> 상세한 컬럼 정보는 ERDCloud 링크를 통해 확인할 수 있습니다.

---

## 🌿 브랜치 전략 (Git Flow)

- **prod**: 프로덕션(배포) 브랜치
- **dev**: 통합 개발 브랜치
- **feature/backend/**: 백엔드 기능 개발 (dev → PR → dev Merge)
- **feature/frontend/**: 프론트엔드 기능 개발 (dev → PR → dev Merge)
- **docs/**: 모든 문서 작업 (README, API 문서 등)
- **chore/**: 빌드 설정, 패키지 관리, CI/CD 등
- **hotfix/**: 긴급 수정 (prod → PR → prod & prod Merge)

> **브랜치 네이밍 가이드라인**: 소문자 영문, 숫자, 하이픈(`-`)만 사용하고, 한글이나 공백, 특수문자 사용은 제한함.

### Quick Start

```bash
# dev 최신화
git switch dev && git pull origin dev

# 기능 브랜치 생성
git switch -c feature/backend/login

# 개발 → 커밋 → 푸시 → GitHub PR → dev Merge
```

---

## ✏️ 커밋 컨벤션

프로젝트에서는 다음과 같은 커밋 메시지 규칙을 사용합니다.

### ✅ 커밋 형식

```
<type>(<scope>): <subject>
```

- **type**: feat, fix, docs, refactor, test, chore
- **scope** (선택):
  - `be` (backend)
  - `fe` (frontend)
  - `common` (공통 문서·설정)
- **subject**: 명령형/현재 시제, 50자 이내, 마침표 생략

### ✅ 커밋 타입

| 타입       | 설명                                |
| ---------- | ----------------------------------- |
| `feat`     | 새로운 기능 추가                    |
| `fix`      | 버그 수정                           |
| `docs`     | 문서 수정 (README 등)               |
| `refactor` | 리팩토링 (기능 변화 없이 코드 개선) |
| `test`     | 테스트 코드 추가 또는 수정          |
| `chore`    | 설정 파일 수정 등 기타 작업         |

### ✅ 커밋 스코프

커밋 메시지에서 `scope`는 변경 대상 영역을 나타냅니다.

- `be` (backend): 백엔드 관련 변경
- `fe` (frontend): 프론트엔드 관련 변경
- `common`: 공통 문서·설정 등 프론트/백엔드 구분 없는 변경
- 생략 가능 (범위가 명확하지 않거나 전체에 영향이 있을 때)

### ✅ 커밋 메시지 예시

```bash
feat(be): 로그인 기능 추가
fix(fe): 로그인 페이지 오류 수정
docs(common): 커밋 전략 README 업데이트
chore: CI 설정 정리        # 범위가 따로 없을 때는 생략 가능
```

---

## 📞 지원 및 문의

### 👨‍💻 개발자 연락처

- **개발자**: 장정욱
- **이메일**: [jeongookjang@naver.com](mailto:jeongookjang@naver.com)
- **GitHub**: [@jujang](https://github.com/jujang)
- **프로젝트 저장소**: [Geulnamu Repository](https://github.com/jujang/Geulnamu)

### 🐛 이슈 리포팅

- **버그 신고 & 기능 요청**: [GitHub Issues](https://github.com/jujang/Geulnamu/issues) - 시스템 오류나 예상과 다른 동작 & 새로운 API 기능이나 개선 사항 제안

### ⚡ 문의 및 응답

- **긴급 이슈**: 이메일로 직접 연락
- **일반 문의**: GitHub Issues 활용
- **응답 시간**: 보통 1-3일 내 (개인 프로젝트 특성상 시간이 걸릴 수 있습니다)

### 📋 참고사항

- **개인 프로젝트**이므로 즉시 대응이 어려울 수 있습니다
- **상세한 재현 단계**와 **환경 정보**를 포함해서 이슈를 작성해주시면 대응이 더 빨라집니다!
- **API 관련 문의**는 [API 문서](./geulnamu-backend/build/docs/asciidoc/index.html)를 먼저 확인해 주세요

---

## 📎 기타

- 프론트는 범용성 및 향후 개발 스텍을 고려해 플러터를 사용해서, 서버는 사용량을 고려하여 firebase를 사용해서, 웹앱의 형태로 제작 예정입니다.
