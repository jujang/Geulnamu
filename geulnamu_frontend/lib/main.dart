import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'core/theme.dart';
import 'core/colors.dart';
import 'core/text_styles.dart';

void main() {
  runApp(const GeulnamuApp());
}

class GeulnamuApp extends StatelessWidget {
  const GeulnamuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '글나무',
      debugShowCheckedModeBanner: false,

      // 글나무 테마 적용
      theme: GeulnamuTheme.lightTheme,
      // darkTheme: GeulnamuTheme.darkTheme, // 추후 구현

      // PWA 지원을 위한 라우터 설정
      home: const GeulnamuHomePage(),

      // 웹 환경에서만 실행되는 PWA 초기화
      builder: (context, child) {
        if (kIsWeb) {
          _initializePWA();
        }
        return child!;
      },
    );
  }

  /// PWA 기능 초기화
  void _initializePWA() {
    // 나중에 서비스 워커 등록 및 PWA 기능 초기화
    if (kDebugMode) {
      print('글나무 PWA 초기화 완료');
    }
  }
}

/// 글나무 메인 홈 페이지
class GeulnamuHomePage extends StatefulWidget {
  const GeulnamuHomePage({super.key});

  @override
  State<GeulnamuHomePage> createState() => _GeulnamuHomePageState();
}

class _GeulnamuHomePageState extends State<GeulnamuHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 글나무 브랜딩 적용된 앱바
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 책 아이콘 (마스코트 대신 임시)
            Icon(
              Icons.menu_book_rounded,
              color: GeulnamuColors.textOnPrimary,
              size: 28,
            ),
            SizedBox(width: 8),
            Text('글나무'),
          ],
        ),
        centerTitle: true,
      ),

      body: Container(
        decoration: BoxDecoration(gradient: GeulnamuColors.backgroundGradient),
        child: SafeArea(
          child: Center(
            // 큰 화면에서 콘텐츠 중앙 정렬
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 800), // PC에서 최대 폭 제한
              child: SingleChildScrollView(
                // 🔥 스크롤 기능 추가!
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 환영 메시지
                    _buildWelcomeCard(),
                    SizedBox(height: 24),

                    // 주요 기능 버튼들
                    Text('주요 기능', style: GeulnamuTextStyles.heading3),
                    SizedBox(height: 16),
                    _buildMainFeatures(),
                    SizedBox(height: 24),

                    // PWA 설치 안내
                    _buildInstallPrompt(),

                    // 추가 여백 (스크롤의 끝부분을 위해)
                    SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 환영 카드
  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: GeulnamuColors.primaryWithOpacity10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.waving_hand,
                    color: GeulnamuColors.primary,
                    size: 32,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '글나무에 오신 것을 환영합니다!',
                        style: GeulnamuTextStyles.heading3,
                      ),
                      SizedBox(height: 4),
                      Text(
                        '독서 토론 모임 관리를 쉽게 해보세요',
                        style: GeulnamuTextStyles.body2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 주요 기능 버튼들 - 실제 화면 크기 기반 반응형
  Widget _buildMainFeatures() {
    final features = [
      {
        'icon': Icons.menu_book_rounded, // 책 아이콘
        'title': '모임 소개',
        'subtitle': '모임 정보 및 소개',
        'color': GeulnamuColors.primary,
      },
      {
        'icon': Icons.event_outlined, // 기존 '모임 참여' 아이콘 사용
        'title': '오늘의 모임',
        'subtitle': '예정된 모임 확인',
        'color': GeulnamuColors.info,
      },
      {
        'icon': Icons.qr_code_scanner_outlined,
        'title': '출석 체크',
        'subtitle': 'QR 코드로 간편 출석',
        'color': GeulnamuColors.success,
      },
      {
        'icon': Icons.edit_outlined,
        'title': '발제 작성',
        'subtitle': '독서 발제문 작성',
        'color': GeulnamuColors.warning,
      },
    ];

    return LayoutBuilder(
      // 실제 화면 크기에 따른 반응형 레이아웃
      builder: (context, constraints) {
        // 실제 화면 크기 기준으로 반응형 설정
        final screenWidth = MediaQuery.of(context).size.width;

        // 화면 크기에 따른 설정값 결정
        int crossAxisCount;
        double cardPadding;
        double iconSize;
        double titleFontSize;
        double subtitleFontSize;

        if (screenWidth >= 1024) {
          // PC/데스크톱 (1024px 이상)
          crossAxisCount = 2;
          cardPadding = 16.0;
          iconSize = 96;
          titleFontSize = 24;
          subtitleFontSize = 15;
        } else if (screenWidth >= 768) {
          // 태블릿 (768px ~ 1023px)
          crossAxisCount = 2;
          cardPadding = 14.0;
          iconSize = 78;
          titleFontSize = 20;
          subtitleFontSize = 14;
        } else if (screenWidth >= 480) {
          // 큰 모바일/작은 태블릿 (480px ~ 767px)
          crossAxisCount = 2;
          cardPadding = 12.0;
          iconSize = 60;
          titleFontSize = 17;
          subtitleFontSize = 13;
        } else {
          // 작은 모바일 (480px 미만)
          crossAxisCount = 2;
          cardPadding = 10.0;
          iconSize = 44;
          titleFontSize = 15;
          subtitleFontSize = 12;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount, // 동적 카드 개수
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.14,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return Card(
              elevation: 2,
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${feature['title']} 기능은 추후 추가될 예정입니다'),
                      duration: Duration(seconds: 2),
                      backgroundColor: GeulnamuColors.primary,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    cardPadding,
                    cardPadding,
                    cardPadding,
                    cardPadding / 2,
                  ), // 동적 패딩
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: (feature['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          feature['icon'] as IconData,
                          color: feature['color'] as Color,
                          size: iconSize, // 실제 화면 크기 기반 동적 아이콘 크기
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        feature['title'] as String,
                        style: GeulnamuTextStyles.heading4.copyWith(
                          fontSize: titleFontSize, // 실제 화면 크기 기반 동적 폰트 크기
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1),
                      Text(
                        feature['subtitle'] as String,
                        style: GeulnamuTextStyles.caption.copyWith(
                          fontSize: subtitleFontSize, // 실제 화면 크기 기반 동적 폰트 크기
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// PWA 설치 안내 - 실제 화면 크기 기반 반응형
  Widget _buildInstallPrompt() {
    // PWA는 모바일 브라우저에서도 설치 가능하므로 모든 웹 환경에서 표시
    if (!kIsWeb) return SizedBox.shrink(); // 네이티브 앱일 때만 숨김

    return LayoutBuilder(
      builder: (context, constraints) {
        // 실제 화면 크기 기준으로 패딩 조정
        final screenWidth = MediaQuery.of(context).size.width;
        double cardPadding = screenWidth >= 768 ? 20.0 : 16.0;
        double iconSize = screenWidth >= 768 ? 36.0 : 32.0;

        return Card(
          color: GeulnamuColors.secondary,
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Row(
              children: [
                Icon(
                  Icons.install_mobile,
                  color: GeulnamuColors.primary,
                  size: iconSize,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('앱으로 설치하기', style: GeulnamuTextStyles.heading4),
                      Text(
                        '홈 화면에 추가하여 더 빠른 접근을 해보세요!',
                        style: GeulnamuTextStyles.body2,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _showInstallInstructions();
                  },
                  child: Text('설치 방법'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 설치 방법 안내 - 모든 플랫폼 대응
  void _showInstallInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('앱 설치 방법'),
        content: SingleChildScrollView(
          // 다이얼로그도 스크롤 가능하게
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PC 브라우저
              Text('💻 PC 브라우저', style: GeulnamuTextStyles.bodyBold),
              Text('• 크롬: 주소창 오른쪽 설치 버튼 클릭'),
              Text('• 엣지: 주소창 오른쪽 앱 설치 버튼'),
              SizedBox(height: 12),

              // 안드로이드 모바일
              Text('📱 안드로이드', style: GeulnamuTextStyles.bodyBold),
              Text('• 크롬: 메뉴(⋮) → "홈 화면에 추가"'),
              Text('• 삼성 브라우저: 메뉴 → "홈 화면에 추가"'),
              SizedBox(height: 12),

              // 아이폰
              Text('🍎 아이폰 (iOS)', style: GeulnamuTextStyles.bodyBold),
              Text('• 사파리: 공유버튼(↑) → "홈 화면에 추가"'),
              Text('• 크롬: 메뉴(⋮) → "홈 화면에 추가"'),
              SizedBox(height: 12),

              // 추가 안내
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: GeulnamuColors.primaryWithOpacity10,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('💡 팁:', style: GeulnamuTextStyles.bodyBold),
                    Text('설치 후 홈 화면에서 일반 앱처럼 사용할 수 있어요!'),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }
}
