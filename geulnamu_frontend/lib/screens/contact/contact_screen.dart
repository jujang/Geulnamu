import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/home/home_service.dart';
import '../../widgets/common/main_layout.dart';
import 'mixins/contact_logic_mixin.dart';
import 'widgets/contact_widgets.dart';

/// 문의하기 화면
///
/// 기능:
/// - 에러 보고와 기능 요청 선택 UI
/// - BottomSheet로 문의 양식 표시
/// - MainLayout 적용으로 일관된 UI
/// - ContactLogicMixin으로 비즈니스 로직 처리
class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> 
    with ContactLogicMixin {
  final HomeService _homeService = HomeService();

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, HomeService>(
      builder: (context, authProvider, homeService, child) {
        return MainLayout(
          showDrawerButton: true, // 🍔 햄버거 버튼 표시
          // isRootPage: false (기본값) - 시스템 뒤로가기 허용
          title: '문의하기',
          onMenuTap: (menu) => _homeService.handleMenuTap(context, menu), // 🔥 메뉴 탭 처리 추가
          onLogoutTap: authProvider.isAuthenticated
              ? () => homeService.handleLogout(context, authProvider) // 🔑 로그아웃 기능 연결
              : null,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // 메인 헤더
                ContactWidgets.buildHeader(context),
                
                const SizedBox(height: 20),
                
                // 선택 카드들
                ContactWidgets.buildSelectionCards(
                  context,
                  onErrorReportTap: showErrorReportBottomSheet,
                  onFeatureRequestTap: showFeatureRequestBottomSheet,
                ),
                
                // 하단 정보
                ContactWidgets.buildFooterInfo(context),
                
                // 하단 여백
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
