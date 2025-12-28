## 백엔드(Spring boot) (상세 구조)

```
geulnamu_backend/src/main/java/com/geulnamu/
├── 📂 controller/                    # REST API 계층
│   ├── login/                       # 인증 API
│   ├── member/                      # 회원 관리 API
│   ├── meeting/                     # 모임 CRUD API
│   ├── attendance/                  # 출석 관리 API
│   ├── bookQuestion/                # 발제문 API
│   ├── voc/                         # VoC(모임원의 소리) API
│   ├── fcm/                         # 푸시 알림 API
│   └── actionHistory/               # 액션 로그 조회 API
│
├── 📂 service/                       # 비즈니스 로직 계층
│   ├── login/
│   │   ├── LoginFacade              # 로그인 통합 처리
│   │   ├── KakaoOAuthService        # 카카오 OAuth
│   │   └── AuthTokenService         # JWT 토큰 관리
│   ├── meeting/
│   ├── attendance/
│   └── ...                          # 도메인별 서비스
│
├── 📂 repository/                    # 데이터 접근 계층 (CQRS)
│   └── {domain}/
│       ├── CommandRepository        # CUD 작업 (JPA)
│       ├── QueryRepository          # R 작업 (JPA)
│       ├── QueryRepositoryCustom    # QueryDSL 인터페이스
│       └── QueryRepositoryImpl      # QueryDSL 구현
│
├── 📂 domain/                        # 도메인 모델 계층
│   ├── member/
│   │   ├── Member                   # 회원 엔티티
│   │   ├── Gender                   # 성별 Enum
│   │   └── MemberStatus             # 회원 상태 Enum
│   ├── meeting/
│   │   ├── Meeting                  # 모임 엔티티
│   │   └── MeetingType              # 모임 유형 Enum
│   └── shared/
│       └── enums/                   # 공통 Enum
│           ├── Role                 # 역할 (6단계)
│           ├── Level                # 권한 레벨
│           └── ActionType           # 액션 타입
│
└── 📂 infrastructure/                # 횡단 관심사
├── annotation/                  # 커스텀 어노테이션
│   ├── @LogAction               # 액션 로깅
│   ├── @AccessLevel             # 권한 제어
│   └── @AuthMemberId            # 인증 사용자 ID
├── aspect/
│   └── ActionHistoryAspect      # AOP 로깅 처리
├── config/
│   ├── security/                # Spring Security 설정
│   ├── firebase/                # FCM 설정
│   └── async/                   # 비동기 처리 설정
├── jwt/                         # JWT 인증/인가
│   ├── JwtFilter                # JWT 필터
│   └── JwtUtil                  # JWT 유틸리티
├── exception/                   # 통합 예외 처리
│   └── GlobalExceptionHandler   # 전역 예외 핸들러
└── response/                    # 통일된 응답 구조
└── BaseResponse             # 공통 응답 래퍼
```

## 프론트엔드(Flutter PWA) (상세 구조)

```
geulnamu_frontend/lib/
├── 📂 core/                          # 핵심 시스템
│   ├── config/
│   │   ├── app_config               # 환경별 API URL
│   │   └── kakao_config             # 카카오 SDK 설정
│   ├── theme/
│   │   ├── colors                   # 색상 정의
│   │   └── theme                    # Material Theme
│   ├── utils/
│   │   ├── api_utils                # API 공통 처리
│   │   ├── date_utils               # 날짜 유틸
│   │   └── pwa_utils                # PWA 유틸
│   └── services/
│       ├── auth_service             # 인증 서비스
│       └── settings_service         # 설정 서비스
│
├── 📂 services/                      # 비즈니스 로직 (Singleton)
│   ├── home/
│   │   ├── home_service             # 홈 로직
│   │   └── home_route_service       # RouteAware 관리
│   ├── meeting/
│   │   └── meeting_service          # 모임 CRUD
│   ├── attendance/
│   │   ├── attendance_service       # 출석 관리
│   │   └── qr_service               # QR 처리
│   ├── discussion/
│   │   └── discussion_service       # 토론 그룹
│   └── notification/
│       └── fcm_service              # FCM 알림
│
├── 📂 providers/                     # 전역 상태 관리
│   ├── auth_provider                # 인증 상태 (Provider)
│   └── theme_provider               # 테마 상태 (Provider)
│
├── 📂 screens/                       # 화면별 구조
│   └── {screen}/
│       ├── {screen}_screen.dart     # UI + Mixin 조합
│       ├── mixins/                  # 화면별 로직 Mixin
│       │   └── {screen}_logic_mixin.dart
│       └── widgets/                 # 화면별 UI 위젯
│           └── {screen}_widgets.dart (Static)
│
├── 📂 widgets/                       # 공통 위젯
│   └── common/
│       ├── main_layout              # 공통 레이아웃
│       ├── app_header               # 상단바
│       └── app_drawer               # 사이드바
│
├── 📂 models/                        # 데이터 모델
│   └── {domain}/
│       ├── {domain}_model           # 도메인 모델
│       └── request/                 # API 요청 모델
│
└── 📂 routes/                        # 네비게이션
└── app_router                   # GoRouter 설정
```

## 아키텍쳐 특징

### Backend

- **계층형 아키텍처**: Controller → Service → Repository → Domain
- **CQRS 패턴**: Command/Query Repository 분리
- **DDD 스타일**: 비즈니스 로직을 Entity에 캡슐화
- **AOP 활용**: `@LogAction` 어노테이션으로 횡단 관심사 처리

### Frontend

- **하이브리드 아키텍처**: Service(Singleton) + Mixin + Static Widgets
- **중앙집중화 디자인**: 색상/테마 한 곳에서 관리
- **PWA 친화적**: GoRouter 기반 URL 동기화
- **완전 화면 분리**: 각 화면이 독립적인 폴더 구조
