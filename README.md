# 글나무 (Geulnamu)

> 독서 토론 모임 관리 플랫폼

## 🎯 프로젝트 소개

독서 모임 '글나무'의 운영 효율화 및 자동화를 위한 웹 기반 서비스입니다.

**주요 성과**

- 📈 API 응답 속도 **50% 개선** (Redis 캐싱)
- 🔔 **실시간 에러 모니터링** (Slack 웹훅, AOP 로깅)
- 🚀 **3분 내 자동 배포** (GitHub Actions)
- 💰 월 운영 비용 **$0**

---

## 📚 문서

| 문서              | 설명                          | 링크                                                              |
| ----------------- | ----------------------------- | ----------------------------------------------------------------- |
| **🎨 포트폴리오** | 기술적 챌린지, 성과, 아키텍처 | [PORTFOLIO.md](./docs/PORTFOLIO.md)                               |
| **🛠️ 기술 문서**  | 설치, 실행, 개발 가이드       | [DEVELOPMENT_GUIDE.md](./docs/DEVELOPMENT_GUIDE.md.md)            |
| **📖 API 문서**   | REST API 명세                 | [api.geulnamu.com/docs](https://api.geulnamu.com/docs/index.html) |
| **🗄️ ERD**        | 데이터베이스 구조             | [ERDCloud](https://www.erdcloud.com/d/mgGNCamYYs28DYphr)          |

---

## 🚀 Quick Start

### 서비스 체험

- 🌐 **웹 서비스**: https://geulnamu.com
- 📱 **모바일 PWA**: 홈 화면에 추가 가능

### 로컬 실행

```bash
# 1. 환경 변수 설정 (필수)
export MYSQL_SERVER_PASSWORD=your_password
export JWT_ACCESS_TOKEN_KEY=your_jwt_secret
export KAKAO_CLIENT_ID=your_kakao_client_id

# 2. 실행
cd geulnamu_backend
./gradlew bootRun

# 3. API 문서 확인
# http://localhost:8080/docs/index.html
```

**상세 설치 가이드**: [DEVELOPMENT_GUIDE.md](./docs/DEVELOPMENT_GUIDE.md)

---

## 🛠️ 기술 스택

**Backend**

- Spring Boot 3.4, Java 17
- MySQL 8.0, QueryDSL, Redis
- OAuth 2.0, JWT, FCM

**Frontend**

- Flutter PWA (반응형)
- AI-assisted (Claude)

**Infrastructure**

- Oracle Cloud (Backend)
- Vercel (Frontend)
- GitHub Actions (CI/CD)

---

## 👥 Contact

**개발자**: 장정욱  
**이메일**: jeongookjang@naver.com  
**GitHub**: [@jujang](https://github.com/jujang)

**버그 신고 & 기능 요청**: [GitHub Issues](https://github.com/jujang/Geulnamu/issues)

---

**더 자세한 내용은 [포트폴리오 문서](./docs/PORTFOLIO.md)를 확인해주세요!** 🎨
