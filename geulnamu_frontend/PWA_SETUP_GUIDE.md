# 글나무 PWA 설정 완료 안내서

## 🎉 설정 완료 내역

글나무 프론트엔드 프로젝트에 PWA 기본 설정이 완료되었습니다!

### ✅ 완료된 작업들

1. **PWA Manifest 설정** (`web/manifest.json`)
2. **HTML 메타 태그 최적화** (`web/index.html`)
3. **기본 서비스 워커** (`web/sw.js`)
4. **글나무 브랜딩 테마** (`lib/core/`)
5. **의존성 패키지 추가** (`pubspec.yaml`)
6. **에셋 폴더 구조** (`assets/`)
7. **기본 홈 화면** (`lib/main.dart`)

---

## 📍 앱 이름 변경 위치

### 1. 앱 제목 (브라우저 탭, 앱 이름)

```json
// web/manifest.json
{
  "name": "글나무",
  "short_name": "글나무",
  "description": "독서 토론 모임을 위한..."
}
```

### 2. HTML 페이지 제목

```html
<!-- web/index.html -->
<title>글나무</title>
<meta name="description" content="독서 토론 모임을..." />
```

### 3. 앱 내부 제목

```dart
// lib/main.dart
MaterialApp(
  title: '글나무',
  ...
)
```

### 4. 앱바 제목

```dart
// lib/main.dart의 GeulnamuHomePage
AppBar(
  title: Row(
    children: [
      Icon(...),
      Text('글나무'),
    ],
  ),
)
```

---

## 🖼️ 로고/아이콘 교체 방법

### 준비해야 할 파일들

**필수 아이콘 사이즈:**

- `Icon-192.png` (192x192px)
- `Icon-512.png` (512x512px)
- `Icon-maskable-192.png` (192x192px, 마스케이블 버전)
- `Icon-maskable-512.png` (512x512px, 마스케이블 버전)
- `favicon.png` (32x32px 또는 16x16px)

### 파일 교체 위치

1. **PWA 아이콘들**

   ```
   web/icons/
   ├── Icon-192.png           ← 교체
   ├── Icon-512.png           ← 교체
   ├── Icon-maskable-192.png  ← 교체
   └── Icon-maskable-512.png  ← 교체
   ```

2. **파비콘**
   ```
   web/favicon.png  ← 교체
   ```

### 마스케이블 아이콘이란?

- **일반 아이콘**: 그대로 표시되는 아이콘
- **마스케이블 아이콘**: 다양한 기기에서 원형, 사각형 등으로 잘려서 표시되는 아이콘
- 마스케이블 아이콘은 중앙 80% 영역에 중요 요소를 배치해야 함

### 디자인 팁

1. **배경은 투명하게** (PNG 형식)
2. **단순하고 명확한 디자인**
3. **작은 크기에서도 알아볼 수 있도록**
4. **글나무 브랜딩 색상** 사용 (`#7DD3C0`)

---

## 🎨 브랜딩 색상 변경

### 메인 색상 변경

```dart
// lib/core/colors.dart
class GeulnamuColors {
  static const Color primary = Color(0xFF7DD3C0);  // ← 여기 수정
  // 다른 색상들도 필요시 수정
}
```

### 마니페스트 테마 색상 동기화

```json
// web/manifest.json
{
  "theme_color": "#7DD3C0", // ← 메인 색상과 맞춤
  "background_color": "#F8F8F8" // ← 배경 색상과 맞춤
}
```

---

## 🚀 테스트 방법

### 1. 개발 서버 실행

```bash
flutter pub get
flutter run -d chrome --web-port 8080
```

### 2. PWA 기능 확인

1. 크롬 개발자 도구 열기 (F12)
2. `Application` 탭 → `Manifest` 확인
3. `Service Workers` 확인
4. 주소창 오른쪽 "설치" 버튼 확인

### 3. 모바일 테스트

- 크롬 개발자 도구에서 모바일 뷰 확인
- 실제 모바일 기기에서 테스트

---

## 📱 PWA 고급 기능 추가 (나중에)

현재는 기본 PWA 설정만 완료되었습니다. 추후 추가할 수 있는 기능들:

### 2단계 기능들

- [ ] 오프라인 모드
- [ ] 백그라운드 동기화
- [ ] 푸시 알림
- [ ] GPS 출석 체크
- [ ] 고급 캐싱 전략

### 3단계 기능들

- [ ] 업데이트 알림 시스템
- [ ] A/B 테스트
- [ ] 성능 모니터링
- [ ] 앱 스토어 배포

---

## 🛠️ 빌드 및 배포

### 웹 빌드

```bash
flutter build web --release
```

### 배포 (geulnamu.com)

```bash
# 빌드 결과물이 build/web/ 폴더에 생성됨
# 이 폴더 내용을 geulnamu.com 서버에 업로드
```

---

## 🔧 문제 해결

### 자주 발생하는 문제들

1. **아이콘이 표시되지 않을 때**

   - 파일 경로 확인
   - 파일 이름 정확히 일치하는지 확인
   - 브라우저 캐시 삭제 후 재시도

2. **PWA 설치 버튼이 안 보일 때**

   - HTTPS 환경에서 테스트
   - manifest.json 문법 오류 확인
   - 서비스 워커 정상 등록 확인

3. **색상이 제대로 적용되지 않을 때**
   - `flutter pub get` 실행
   - Hot restart (핫 리로드가 아닌 재시작)

---

## 📞 도움이 필요한 경우

이 설정으로도 궁금한 점이나 문제가 있으면 언제든 문의해 주세요!

- 로고 파일 준비 도움
- 색상 조정
- 고급 PWA 기능 추가
- 배포 관련 문의

---

**🎯 다음 단계: 핵심 기능 개발 집중!**

이제 PWA 기본 설정은 완료되었으니, 로그인, 출석체크, 발제문 작성 등 핵심 기능 개발에 집중하시면 됩니다! 💪
