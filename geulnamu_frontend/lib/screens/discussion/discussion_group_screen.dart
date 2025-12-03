import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/main_layout.dart';
import '../../widgets/common/loading_widgets.dart';
import '../../core/theme.dart';
import '../../core/config/app_config.dart';
import '../../services/home/home_service.dart';
import '../../services/discussion/discussion_service.dart';
import '../../models/discussion/discussion_group_model.dart';

/// 토론 조 구성 화면
///
/// 특정 모임의 토론 조 구성을 조회하고 표시하는 화면
/// - 조별 구성원 목록
/// - 조가 없는 경우 안내 메시지 표시
class DiscussionGroupScreen extends StatefulWidget {
  /// 모임 ID
  final int meetingId;

  /// 모임 제목 (선택사항, AppBar 제목 표시용)
  final String? meetingTitle;

  const DiscussionGroupScreen({
    super.key,
    required this.meetingId,
    this.meetingTitle,
  });

  @override
  State<DiscussionGroupScreen> createState() => _DiscussionGroupScreenState();
}

class _DiscussionGroupScreenState extends State<DiscussionGroupScreen> {
  final HomeService _homeService = HomeService();
  final DiscussionService _discussionService = DiscussionService();

  // 상태 변수들
  bool _isLoading = true;
  String? _errorMessage;
  DiscussionGroupListResponse? _groupListResponse;

  @override
  void initState() {
    super.initState();

    // 화면 로드 후 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDiscussionGroups();
    });
  }

  /// 토론 조 구성 데이터 로드
  Future<void> _loadDiscussionGroups() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final accessToken = await _getAccessToken();

      if (accessToken == null) {
        throw Exception('로그인이 필요합니다.');
      }

      if (AppConfig.debugMode) {
        print('🚀 [조 구성 화면] 데이터 로드 시작: meetingId=${widget.meetingId}');
      }

      final response = await _discussionService.getAllDiscussionGroupMemberList(
        meetingId: widget.meetingId,
        accessToken: accessToken,
      );

      if (!mounted) return;

      setState(() {
        _groupListResponse = response;
        _isLoading = false;
      });

      if (AppConfig.debugMode) {
        print('✅ [조 구성 화면] 데이터 로드 완료: ${response?.groupCount ?? 0}개 조');
      }
    } catch (e) {
      if (!mounted) return;

      if (AppConfig.debugMode) {
        print('❌ [조 구성 화면] 데이터 로드 실패: $e');
      }

      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  /// 새로고침
  Future<void> _refreshData() async {
    await _loadDiscussionGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeService>(
      builder: (context, homeService, child) {
        return LoadingWidgets.buildOverlayLoading(
          context,
          isLoading: homeService.isProcessing,
          loadingMessage: homeService.currentOperation,
          child: MainLayout(
            title: widget.meetingTitle != null
                ? '${widget.meetingTitle} - 토론 조'
                : '토론 조',
            isHomePage: false, // 서브 페이지이므로 뒤로가기 버튼 표시
            onMenuTap: (menu) => _homeService.handleMenuTap(context, menu),
            onLogoutTap: () => _handleLogout(),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refreshData,
                tooltip: '새로고침',
              ),
            ],
            body: _buildMainContent(),
          ),
        );
      },
    );
  }

  /// 메인 콘텐츠 빌드
  Widget _buildMainContent() {
    // 로딩 상태
    if (_isLoading) {
      return _buildLoading();
    }

    // 에러 상태
    if (_errorMessage != null) {
      return _buildError(_errorMessage!);
    }

    // 데이터 없음 또는 빈 목록
    if (_groupListResponse == null || _groupListResponse!.groups.isEmpty) {
      return _buildEmptyState();
    }

    // 정상 데이터 표시
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Column(
        children: [
          // 요약 정보
          _buildSummaryCard(),

          // 구분선
          Divider(height: 1, color: context.colors.outline.withOpacity(0.2)),

          // 조별 목록
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _groupListResponse!.groups.length,
              itemBuilder: (context, index) {
                final group = _groupListResponse!.groups[index];
                return _buildGroupCard(index + 1, group);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 로딩 위젯
  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: context.colors.primary),
          const SizedBox(height: 16),
          Text(
            '조 구성을 불러오는 중...',
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// 에러 위젯
  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: context.colors.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textStyles.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDiscussionGroups,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  /// 빈 상태 위젯
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 64,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              '아직 조가 구성되지 않았습니다',
              textAlign: TextAlign.center,
              style: context.textStyles.titleMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '운영진이 조를 구성하면 여기에 표시됩니다',
              textAlign: TextAlign.center,
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 요약 카드
  Widget _buildSummaryCard() {
    final groupCount = _groupListResponse?.groupCount ?? 0;
    final totalMembers = _groupListResponse?.totalMemberCount ?? 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 조 수
          _buildSummaryItem(
            icon: Icons.category,
            label: '조 수',
            value: '$groupCount개',
            color: context.colors.primary,
          ),
          
          // 구분선
          Container(
            width: 1,
            height: 40,
            color: context.colors.outline.withOpacity(0.3),
          ),

          // 총 참여 인원
          _buildSummaryItem(
            icon: Icons.groups,
            label: '참여 인원',
            value: '$totalMembers명',
            color: context.colors.primary,
          ),
        ],
      ),
    );
  }

  /// 요약 항목
  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: context.textStyles.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.textStyles.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// 조별 카드
  Widget _buildGroupCard(int groupNumber, DiscussionGroupModel group) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).brightness == Brightness.light
              ? context.colors.outline.withOpacity(0.2)
              : Colors.transparent,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 조 헤더
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.colors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$groupNumber조',
                    style: context.textStyles.titleSmall?.copyWith(
                      color: context.colors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${group.memberCount}명',
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 구성원 목록
            if (group.isEmpty)
              Text(
                '구성원 없음',
                style: context.textStyles.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: group.members.map((member) {
                  return Chip(
                    label: Text(member.memberName),
                    backgroundColor: context.colors.surfaceContainerHighest,
                    labelStyle: context.textStyles.bodyMedium?.copyWith(
                      color: context.colors.onSurface,
                    ),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  /// 로그아웃 처리
  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await _homeService.handleLogout(context, authProvider);
  }

  /// 액세스 토큰 가져오기
  Future<String?> _getAccessToken() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await authProvider.accessToken;
      return token;
    } catch (e) {
      if (AppConfig.debugMode) {
        print('❌ [조 구성 화면] 액세스 토큰 가져오기 실패: $e');
      }
      return null;
    }
  }
}
