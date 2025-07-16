import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// 🌿 글나무 소개 페이지
/// 책갈피 컨셉과 브랜딩을 반영한 풍부한 UI 디자인
class IntroductionScreen extends StatelessWidget {
  const IntroductionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 🎨 헤더 섹션 - 책갈피 컨셉의 그라데이션 배경
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: context.colors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false, // 🎯 제목을 왼쪽 정렬로 변경
              titlePadding: const EdgeInsets.only(
                left: 44,
                bottom: 16,
              ), // 🎯 뒤로가기 버튼 간격 고려
              title: Text(
                '글나무 소개',
                style: context.textStyles.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(gradient: context.primaryGradient),
                child: Stack(
                  children: [
                    // 🌿 배경 패턴 (책갈피 모티브)
                    Positioned(
                      top: 80,
                      right: -20,
                      child: Opacity(
                        opacity: 0.1,
                        child: Icon(
                          Icons.bookmark_rounded,
                          size: 120,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 60,
                      left: -30,
                      child: Opacity(
                        opacity: 0.08,
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 100,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // 📖 중앙 아이콘
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.groups_rounded,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '독서 토론 모임 - 글나무',
                            style: context.textStyles.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 📝 콘텐츠 섹션
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🎯 주제 카드
                  _buildInfoCard(
                    context: context,
                    icon: Icons.lightbulb_rounded,
                    iconColor: context.colors.primary,
                    title: '모임 주제',
                    content:
                        '함께 읽고, 함께 생각하는 독서의 즐거움을 나누는 모임입니다. '
                        '매주 선정된 도서를 함께 읽고 다양한 관점에서 토론하며 '
                        '새로운 인사이트를 얻어가는 시간을 갖습니다.',
                    backgroundColor: context.colors.primary.withOpacity(0.05),
                  ),

                  const SizedBox(height: 20),

                  // 💌 메시지 카드
                  _buildInfoCard(
                    context: context,
                    icon: Icons.favorite_rounded,
                    iconColor: context.errorColor,
                    title: '모임 메시지',
                    content:
                        '책을 통해 만나는 특별한 인연을 소중히 여기며, '
                        '서로의 생각을 존중하고 배려하는 따뜻한 모임 문화를 만들어가요. '
                        '함께 성장하고 함께 나누는 기쁨을 경험해보세요!',
                    backgroundColor: context.errorColor.withOpacity(0.05),
                  ),

                  const SizedBox(height: 30),

                  // 📊 정기 모임 정보
                  _buildScheduleInfoSection(context),

                  const SizedBox(height: 30),

                  // 📚 커리큘럼
                  _buildCurriculumSection(context),

                  const SizedBox(height: 30),

                  // 📖 독서벙
                  _buildBookClubSection(context),

                  const SizedBox(height: 30),

                  // ⚖️ 규율
                  _buildRulesSection(context),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📋 정보 카드 위젯
  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    required Color backgroundColor,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: backgroundColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 타이틀 섹션
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: context.textStyles.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 내용
            Text(
              content,
              style: context.textStyles.bodyLarge?.copyWith(
                height: 1.6,
                color: context.colors.onSurface.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📊 정기 모임 스케줄 정보 섹션 (메서드명 변경)
  Widget _buildScheduleInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '정기 모임 정보',
          style: context.textStyles.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildInfoDetailRow(
                  context: context,
                  icon: Icons.schedule_rounded,
                  title: '정기모임',
                  content: '매주 토 10시 30분 (주 1회)',
                ),

                const SizedBox(height: 16),

                _buildInfoDetailRow(
                  context: context,
                  icon: Icons.location_on_rounded,
                  title: '장소',
                  content: '합정 근처 카페 (*필요시 대관)',
                ),

                const SizedBox(height: 16),

                _buildInfoDetailRow(
                  context: context,
                  icon: Icons.groups_rounded,
                  title: '참여방법',
                  content: '투표하고 시간 맞춰 참여 (투표한 확인)',
                ),

                const SizedBox(height: 16),

                _buildInfoDetailRow(
                  context: context,
                  icon: Icons.access_time_rounded,
                  title: '투표 마감',
                  content: '금요일 저녁 20시\n(놓쳤다면 댓글에 \'당일 참석\' 달아주세요!)',
                ),

                const SizedBox(height: 16),

                _buildInfoDetailRow(
                  context: context,
                  icon: Icons.book_outlined,
                  title: '준비물',
                  content: '각자 읽을 책, 노트 및 필기도구',
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: context.warningColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: context.warningColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '당일 취소 자제 부탁드리고 노쇼 2번은 강퇴입니다\n본위기를 흐리거나 다른 목적으로 가입하신 분들, 운영진 회의 하에 강퇴입니다 (무통보 강제퇴장)',
                          style: context.textStyles.bodySmall?.copyWith(
                            color: context.warningColor,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 정보 상세 행 위젯 (메서드명 변경)
  Widget _buildInfoDetailRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: context.colors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textStyles.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: context.textStyles.bodyMedium?.copyWith(height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 📚 커리큘럼 섹션 (깔끔한 타임라인 디자인)
  Widget _buildCurriculumSection(BuildContext context) {
    final curriculumItems = [
      {
        'time': '10:30 ~ 10:45',
        'title': '안부인사 및 독서시작',
        'subtitle': '*원하는 자리에 앉아서 바로 독서 시작하시면 됩니다',
        'icon': Icons.waving_hand_rounded,
      },
      {
        'time': '10:45 ~ 12:00',
        'title': '각자 원하는 책 1시간 15분 독서 및 생각정리',
        'subtitle': '*독서만 하고 가셔도 좋습니다!',
        'icon': Icons.menu_book_rounded,
      },
      {
        'time': '12:00 ~ 12:20',
        'title': '책 소개',
        'subtitle': '',
        'icon': Icons.campaign_rounded,
      },
      {
        'time': '12:20 ~ 13:20',
        'title': '의미있는 대화',
        'subtitle': '*너무 가벼운 이야기는 지양',
        'icon': Icons.forum_rounded,
      },
      {
        'time': '13:20 ~ 13:30',
        'title': '마무리',
        'subtitle': '',
        'icon': Icons.check_circle_rounded,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.schedule_outlined,
              color: context.colors.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              '커리큘럼',
              style: context.textStyles.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.primary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: curriculumItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isLast = index == curriculumItems.length - 1;

                return Column(
                  children: [
                    _buildTimelineItem(
                      context: context,
                      time: item['time'] as String,
                      title: item['title'] as String,
                      subtitle: item['subtitle'] as String,
                      icon: item['icon'] as IconData,
                      isLast: isLast,
                    ),
                    if (!isLast) const SizedBox(height: 20),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// 타임라인 아이템 위젯
  Widget _buildTimelineItem({
    required BuildContext context,
    required String time,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 시간 표시
        SizedBox(
          width: 80,
          child: Text(
            time,
            style: context.textStyles.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.primary,
            ),
          ),
        ),

        const SizedBox(width: 16),

        // 타임라인 라인과 아이콘
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: context.colors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: context.colors.primary.withOpacity(0.3),
                margin: const EdgeInsets.only(top: 8),
              ),
          ],
        ),

        const SizedBox(width: 16),

        // 내용
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textStyles.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// 📖 독서벙 섹션
  Widget _buildBookClubSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.flash_on_rounded,
              color: context.colors.secondary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              '독서벙',
              style: context.textStyles.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.secondary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Card(
          elevation: 2,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.colors.secondary.withOpacity(0.1),
                  context.colors.secondary.withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBookClubDetailRow(
                  context: context,
                  icon: Icons.schedule_rounded,
                  title: '일시',
                  content: '평일 18:30 랜덤 요일',
                ),

                const SizedBox(height: 12),

                _buildBookClubDetailRow(
                  context: context,
                  icon: Icons.menu_book_rounded,
                  title: '내용',
                  content: '독서 및 담소',
                ),

                const SizedBox(height: 12),

                _buildBookClubDetailRow(
                  context: context,
                  icon: Icons.groups_rounded,
                  title: '참여방법',
                  content: '투표한 확인 후 투표 및 참석',
                ),

                const SizedBox(height: 12),

                _buildBookClubDetailRow(
                  context: context,
                  icon: Icons.access_time_rounded,
                  title: '특이사항',
                  content: '참석 시간 자유 (편한 시간에 와서 가고 싶을 때 가셔도 됩니다)',
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.infoColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: context.infoColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_rounded,
                        color: context.infoColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '현재 독서벙 개설은 운영진(혹은 운영진과 협의가 된 자)에 한 해서 열리고 있습니다',
                          style: context.textStyles.bodySmall?.copyWith(
                            color: context.infoColor,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 독서벙 상세 정보 행 위젯 (메서드명 변경)
  Widget _buildBookClubDetailRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: context.colors.secondary, size: 18),
        const SizedBox(width: 8),
        Text(
          '$title: ',
          style: context.textStyles.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.secondary,
          ),
        ),
        Expanded(
          child: Text(
            content,
            style: context.textStyles.bodyMedium?.copyWith(height: 1.4),
          ),
        ),
      ],
    );
  }

  /// ⚖️ 규율 섹션 (엄격하고 중요한 느낌)
  Widget _buildRulesSection(BuildContext context) {
    final rules = [
      '노쇼는 2회시 무통보 강퇴입니다.',
      '당일 취소 및 당일 참여: 08시 30분 전 댓글에 \'당일 참석\'을 달고 참여하시면 됩니다. 취소는 사유와 함께 취소 여부를 댓글로 남겨주세요.\n(당일 취소 최대한 자제해주세요. 운영진 자체 평가 후 무통보 강퇴처리 될 수 있습니다)',
      '지각이 잦을 시에, 운영진 면담을 진행합니다. 그 후 여전히 변화 의지가 없다면 강퇴처리 하겠습니다\n(10시 45분까지는 지각이 아닙니다.)',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.gavel_rounded, color: context.errorColor, size: 24),
            const SizedBox(width: 8),
            Text(
              '규율',
              style: context.textStyles.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.errorColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Card(
          elevation: 3,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.errorColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: context.errorColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '모임의 원활한 운영을 위해 다음 규율을 준수해주세요',
                          style: context.textStyles.bodyMedium?.copyWith(
                            color: context.errorColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                ...rules.asMap().entries.map((entry) {
                  final index = entry.key;
                  final rule = entry.value;

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < rules.length - 1 ? 16 : 0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            color: context.errorColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: context.textStyles.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            rule,
                            style: context.textStyles.bodyMedium?.copyWith(
                              height: 1.5,
                              color: context.colors.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
