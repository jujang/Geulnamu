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
        decoration: BoxDecoration(
          gradient: GeulnamuColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 환영 메시지
                _buildWelcomeCard(),
                SizedBox(height: 24),
                
                // 주요 기능 버튼들
                Text(
                  '주요 기능',
                  style: GeulnamuTextStyles.heading3,
                ),
                SizedBox(height: 16),
                _buildMainFeatures(),
                SizedBox(height: 24),
                
                // PWA 설치 안내
                _buildInstallPrompt(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// 환영 카드
  Widget _buildWelcomeCard() {
    return Card(
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
  
  /// 주요 기능 버튼들
  Widget _buildMainFeatures() {
    final features = [
      {
        'icon': Icons.event_outlined,
        'title': '모임 참여',
        'subtitle': '예정된 모임 확인',
        'color': GeulnamuColors.primary,
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
      {
        'icon': Icons.people_outline,
        'title': '커뮤니티',
        'subtitle': '토론 참여 및 소통',
        'color': GeulnamuColors.info,
      },
    ];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return Card(
          child: InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${feature['title']} 기능은 추후 추가될 예정입니다'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (feature['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      feature['icon'] as IconData,
                      color: feature['color'] as Color,
                      size: 32,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    feature['title'] as String,
                    style: GeulnamuTextStyles.heading4,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    feature['subtitle'] as String,
                    style: GeulnamuTextStyles.caption,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// PWA 설치 안내
  Widget _buildInstallPrompt() {
    if (!kIsWeb) return SizedBox.shrink();
    
    return Card(
      color: GeulnamuColors.secondary,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.install_mobile,
              color: GeulnamuColors.primary,
              size: 32,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '앱으로 설치하기',
                    style: GeulnamuTextStyles.heading4,
                  ),
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
  }
  
  /// 설치 방법 안내
  void _showInstallInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('앱 설치 방법'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('크롬 브라우저 (추천)', style: GeulnamuTextStyles.bodyBold),
            Text('• 주소창 오른쪽 설치 버튼 클릭'),
            Text('• "홈 화면에 추가" 선택'),
            SizedBox(height: 12),
            Text('사파리 (아이폰)', style: GeulnamuTextStyles.bodyBold),
            Text('• 공유 버튼 클릭'),
            Text('• "홈 화면에 추가" 선택'),
          ],
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
