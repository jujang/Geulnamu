import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/common/main_layout.dart';
import '../../providers/auth_provider.dart';
import '../../services/home/home_service.dart'; // HomeService 추가
import 'mixins/meeting_create_logic_mixin.dart';
import 'widgets/meeting_create_widgets.dart';

/// 모임 만들기 화면
///
/// 기능:
/// - 모임 타입 선택 (정기/번개/특수)
/// - 모임 기본 정보 입력 (제목, 날짜/시간, 장소)
/// - 지각 기준 시간 설정 (자동 + 수동 조정)
/// - 모임 생성 API 호출
///
/// 접근 권한: STAFF 이상
class MeetingCreateScreen extends StatefulWidget {
  const MeetingCreateScreen({super.key});

  @override
  State<MeetingCreateScreen> createState() => _MeetingCreateScreenState();
}

class _MeetingCreateScreenState extends State<MeetingCreateScreen>
    with MeetingCreateLogicMixin {
  final HomeService _homeService = HomeService(); // HomeService 인스턴스

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // 권한 확인
        if (!authProvider.isStaffLevel) {
          return Scaffold(
            appBar: AppBar(title: const Text('접근 권한 없음')),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    '모임 만들기는 준운영진 이상만 이용할 수 있습니다.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return MainLayout(
          title: '모임 만들기',
          isHomePage: false, // 뒤로가기 버튼 표시
          onMenuTap: (menu) => _handleMenuTap(menu),
          onLogoutTap: () => _handleLogout(),
          body: Stack(
            children: [
              _buildBody(),
              // 🔄 로딩 오버레이
              if (isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          '모임을 생성하고 있습니다...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// 메인 바디 구성
  Widget _buildBody() {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 📋 안내 카드
          MeetingCreateWidgets.buildInfoCard(context),
          const SizedBox(height: 24),

          // 🎨 모임 타입 선택
          MeetingCreateWidgets.buildMeetingTypeSelector(
            context: context,
            selectedType: selectedMeetingType,
            onChanged: onMeetingTypeChanged,
          ),
          const SizedBox(height: 32), // 더 많은 간격
          // 📝 모임 제목
          MeetingCreateWidgets.buildMeetingNameField(
            context: context,
            controller: meetingNameController,
            validator: validateMeetingName,
            onChanged: revalidateForm, // 실시간 유효성 검사
          ),
          const SizedBox(height: 28), // 더 많은 간격
          // 📅 모임 날짜/시간
          MeetingCreateWidgets.buildDateTimeSelector(
            context: context,
            label: '모임 날짜 및 시간',
            dateController: meetingDateController,
            timeController: meetingTimeController,
            onDateTap: selectMeetingDate,
            onTimeTap: selectMeetingTime,
            isRequired: true,
          ),
          const SizedBox(height: 28), // 더 많은 간격
          // ⏰ 지각 기준 시간
          MeetingCreateWidgets.buildDateTimeSelector(
            context: context,
            label: '지각 기준 시간',
            dateController: lateDateController,
            timeController: lateTimeController,
            onDateTap: selectLateDate,
            onTimeTap: selectLateTime,
            isRequired: false,
          ),
          const SizedBox(height: 4),
          Text(
            '모임 시간 설정 시 자동으로 동일하게 설정됩니다. 필요 시 수정해주세요. (모임 시간보다 빠를 수 없습니다.)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          // 📍 모임 장소
          MeetingCreateWidgets.buildMeetingPlaceField(
            context: context,
            controller: meetingPlaceController,
            validator: validateMeetingPlace,
            onChanged: revalidateForm, // 실시간 유효성 검사
          ),
          const SizedBox(height: 28), // 더 많은 간격
          // 📄 상세 설명
          MeetingCreateWidgets.buildDescriptionField(
            context: context,
            controller: descriptionController,
          ),
          const SizedBox(height: 40), // 더 많은 간격
          // 🚀 생성 버튼
          MeetingCreateWidgets.buildCreateButton(
            context: context,
            onPressed: handleCreateMeeting,
            isLoading: isLoading,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// 메뉴 탭 처리
  void _handleMenuTap(String menu) {
    _homeService.handleMenuTap(context, menu);
  }

  /// 로그아웃 처리
  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await _homeService.handleLogout(context, authProvider);
  }
}
