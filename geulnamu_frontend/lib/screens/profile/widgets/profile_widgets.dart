import 'package:flutter/material.dart';
import '../../../models/profile/profile_model.dart';
import '../../../core/utils/date_utils.dart' as app_date_utils;

/// 프로필 화면 UI 위젯들 (Static Methods)
/// 
/// 제공 위젯:
/// - 프로필 이미지
/// - 기본 정보 섹션 (이름, 성별, 생년월일)
/// - 계정 정보 섹션 (닉네임, 권한)
/// - 수정 폼 위젯들
class ProfileWidgets {
  ProfileWidgets._(); // private constructor - static class

  /// 프로필 이미지 위젯
  /// 
  /// 기본 아이콘 사용, 추후 이미지 업로드 기능 확장 가능
  static Widget buildProfileImage(
    BuildContext context, {
    double size = 120,
    String? imageUrl, // 추후 확장용
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: imageUrl != null
          ? ClipOval(
              child: Image.network(
                imageUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultProfileIcon(context, size);
                },
              ),
            )
          : _buildDefaultProfileIcon(context, size),
    );
  }

  /// 기본 프로필 아이콘
  static Widget _buildDefaultProfileIcon(BuildContext context, double size) {
    return Icon(
      Icons.account_circle,
      size: size * 0.8,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  /// 기본 정보 섹션 (조회 모드)
  /// 
  /// 이름, 성별, 생년월일 표시 (수정 가능한 필드들)
  static Widget buildBasicInfoSection(
    BuildContext context,
    ProfileModel profile,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 섹션 제목
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '기본 정보',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface, // 🎯 다크모드 대비 개선
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 이름
            _buildInfoRow(
              context,
              label: '이름',
              value: profile.displayName,  // null 안전 getter 사용
              icon: Icons.badge,
            ),

            const SizedBox(height: 12),

            // 성별
            _buildInfoRow(
              context,
              label: '성별',
              value: profile.genderDisplayName,
              icon: Icons.wc,
            ),

            const SizedBox(height: 12),

            // 생년월일
            _buildInfoRow(
              context,
              label: '생년월일',
              value: profile.hasBirthDate 
                ? app_date_utils.DateUtils.formatDisplayDate(profile.birthDate!)
                : '생년월일 미입력',
              icon: Icons.cake,
              subtitle: profile.hasBirthDate 
                ? '(만 ${app_date_utils.DateUtils.calculateAge(profile.birthDate!)}세)'
                : null,
            ),
          ],
        ),
      ),
    );
  }

  // 🎯 관리자 모드 다이얼로그들

  /// 모임원 이름 수정 다이얼로그
  static Future<String?> showNameEditDialog(
    BuildContext context,
    String currentName,
  ) async {
    String newName = currentName;
    final controller = TextEditingController(text: currentName);
    String? errorText;

    return showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('이름 수정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: '새로운 이름',
                  errorText: errorText,
                  helperText: '2-10자, 특수문자 제외',
                  border: const OutlineInputBorder(),
                ),
                maxLength: 10,
                onChanged: (value) {
                  newName = value;
                  // 실시간 유효성 검증
                  setState(() {
                    if (value.trim().isEmpty) {
                      errorText = '이름을 입력해주세요.';
                    } else if (value.length < 2) {
                      errorText = '이름은 2자 이상이어야 합니다.';
                    } else if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                      errorText = '특수문자를 사용할 수 없습니다.';
                    } else {
                      errorText = null;
                    }
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: errorText == null && newName.trim().isNotEmpty
                  ? () => Navigator.pop(context, newName.trim())
                  : null,
              child: const Text('수정'),
            ),
          ],
        ),
      ),
    );
  }

  /// 모임원 권한 수정 다이얼로그
  static Future<String?> showRoleEditDialog(
    BuildContext context,
    String currentRole,
  ) async {
    String selectedRole = currentRole;
    
    final roleOptions = [
      {'value': 'MEMBER', 'label': '일반 회원'},
      {'value': 'VICE_STAFF', 'label': '준운영진'},
      {'value': 'STAFF', 'label': '운영진'},
      {'value': 'ADMIN', 'label': '관리자'},
      {'value': 'VICE_LEADER', 'label': '부모임장'},
      {'value': 'LEADER', 'label': '모임장'},
    ];

    return showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('권한 변경'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('새로운 권한을 선택해주세요.'),
              const SizedBox(height: 16),
              ...roleOptions.map((role) => RadioListTile<String>(
                title: Text(role['label']!),
                value: role['value']!,
                groupValue: selectedRole,
                onChanged: (value) {
                  setState(() {
                    selectedRole = value!;
                  });
                },
              )),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '권한 변경 시 해당 모임원은 재로그인이 필요합니다.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: selectedRole != currentRole
                  ? () => Navigator.pop(context, selectedRole)
                  : null,
              child: const Text('변경'),
            ),
          ],
        ),
      ),
    );
  }

  /// 계정 상태 변경 확인 다이얼로그
  static Future<bool?> showStatusToggleDialog(
    BuildContext context,
    ProfileModel profile,
    bool newStatus, // true: 활성화, false: 비활성화
  ) async {
    final actionText = newStatus ? '활성화' : '비활성화';
    final warningText = newStatus
        ? '이 계정이 다시 활성화되어 로그인 및 모임 참여가 가능해집니다.'
        : '이 계정이 비활성화되어 로그인 및 모임 참여가 제한됩니다.';

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$actionText 확인'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('모임원: ${profile.displayName}'),
            const SizedBox(height: 8),
            Text('현재 상태: ${profile.isActive ? "활성" : "비활성"}'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: newStatus
                    ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                    : Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    newStatus ? Icons.info_outline : Icons.warning_outlined,
                    size: 16,
                    color: newStatus
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      warningText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: newStatus
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.error,
              foregroundColor: newStatus
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onError,
            ),
            child: Text(actionText),
          ),
        ],
      ),
    );
  }

  /// 계정 정보 섹션 (읽기 전용)
  /// 
  /// 닉네임, 권한 표시 (수정 불가능한 필드들)
  static Widget buildAccountInfoSection(
    BuildContext context,
    ProfileModel profile,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 섹션 제목
            Row(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '계정 정보',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface, // 🎯 다크모드 대비 개선
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 닉네임
            _buildInfoRow(
              context,
              label: '닉네임',
              value: profile.nickname,
              icon: Icons.alternate_email,
              isReadOnly: true,
            ),

            const SizedBox(height: 12),

            // 권한
            _buildInfoRow(
              context,
              label: '권한',
              value: profile.roleDisplayName,
              icon: Icons.security,
              isReadOnly: true,
            ),
          ],
        ),
      ),
    );
  }

  /// 정보 행 위젯
  static Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    String? subtitle,
    bool isReadOnly = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 아이콘
        Icon(
          icon,
          size: 18,
          color: isReadOnly 
            ? Theme.of(context).colorScheme.outline
            : Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),

        // 라벨
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(width: 16),

        // 값
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isReadOnly 
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ],
          ),
        ),

        // 읽기 전용 표시
        if (isReadOnly)
          Icon(
            Icons.lock_outline,
            size: 16,
            color: Theme.of(context).colorScheme.outline,
          ),
      ],
    );
  }

  /// 기본 정보 수정 폼
  /// 
  /// 이름, 성별, 생년월일 입력 위젯들
  static Widget buildEditForm(
    BuildContext context, {
    required String name,
    required String gender,
    required DateTime? birthDate,
    required Function(String) onNameChanged,
    required Function(String) onGenderChanged,
    required Function(DateTime) onBirthDateChanged,
    required Map<String, String?> errors,
    TextEditingController? nameController, // 🎯 Controller 추가
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 섹션 제목
            Row(
              children: [
                Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '정보 수정',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface, // 🎯 다크모드 대비 개선
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 이름 입력
            TextField(
              decoration: InputDecoration(
                labelText: '이름',
                prefixIcon: const Icon(Icons.badge),
                errorText: errors['name'],
                helperText: '2-10자, 특수문자 제외',
                border: const OutlineInputBorder(),
              ),
              controller: nameController ?? TextEditingController(text: name), // 🎯 Controller 사용
              onChanged: onNameChanged,
              maxLength: 10,
            ),

            const SizedBox(height: 16),

            // 성별 선택
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '성별',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('남성'),
                        value: 'MALE',
                        groupValue: gender,
                        onChanged: (value) => onGenderChanged(value!),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('여성'),
                        value: 'FEMALE',
                        groupValue: gender,
                        onChanged: (value) => onGenderChanged(value!),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                if (errors['gender'] != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 4),
                    child: Text(
                      errors['gender']!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // 생년월일 선택
            InkWell(
              onTap: () => _showDatePicker(context, birthDate, onBirthDateChanged),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: '생년월일',
                  prefixIcon: const Icon(Icons.cake),
                  errorText: errors['birthDate'],
                  border: const OutlineInputBorder(),
                ),
                child: Text(
                  birthDate != null
                      ? app_date_utils.DateUtils.formatDisplayDate(
                          birthDate.toIso8601String().split('T')[0])
                      : '날짜를 선택해주세요',
                  style: birthDate != null
                      ? Theme.of(context).textTheme.bodyLarge
                      : Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 날짜 선택기 표시
  static Future<void> _showDatePicker(
    BuildContext context,
    DateTime? currentDate,
    Function(DateTime) onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime.now(),
      // 🎯 locale 제거 - 이미 앱 전체에서 설정됨
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }

  /// 액션 버튼들 (저장, 취소)
  static Widget buildActionButtons(
    BuildContext context, {
    required VoidCallback onSave,
    required VoidCallback onCancel,
    bool isLoading = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 취소 버튼
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : onCancel,
              child: const Text('취소'),
            ),
          ),

          const SizedBox(width: 16),

          // 저장 버튼
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading ? null : onSave,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('저장'),
            ),
          ),
        ],
      ),
    );
  }

  /// 로딩 위젯
  static Widget buildLoadingWidget(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('프로필 정보를 불러오는 중...'),
        ],
      ),
    );
  }

  /// 에러 위젯
  static Widget buildErrorWidget(
    BuildContext context,
    String message,
    VoidCallback onRetry,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '프로필 정보를 불러올 수 없습니다',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  // 🎯 관리자 모드 전용 위젯들

  /// 관리자용 계정 정보 섹션
  /// 
  /// 비활성화 계정 표시 및 인라인 수정 버튼 포함
  static Widget buildAdminAccountInfoSection(
    BuildContext context,
    ProfileModel profile, {
    required Function(String) onRoleEdit,
    required Function(String) onNameEdit,
    required Function(bool) onStatusToggle,
    bool isProcessing = false,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 섹션 제목
            Row(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '계정 관리',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 닉네임 (읽기 전용)
            _buildAdminInfoRow(
              context,
              label: '닉네임',
              value: profile.nickname,
              icon: Icons.alternate_email,
              isReadOnly: true,
            ),

            const SizedBox(height: 12),

            // 권한 (수정 가능)
            _buildAdminInfoRow(
              context,
              label: '권한',
              value: profile.roleDisplayName,
              icon: Icons.security,
              onEdit: () => onRoleEdit(profile.role),
              isProcessing: isProcessing,
            ),

            const SizedBox(height: 12),

            // 활성화 상태
            _buildStatusSection(
              context,
              profile: profile,
              onStatusToggle: onStatusToggle,
              isProcessing: isProcessing,
            ),
          ],
        ),
      ),
    );
  }

  /// 관리자용 기본 정보 섹션 (이름 수정 가능)
  static Widget buildAdminBasicInfoSection(
    BuildContext context,
    ProfileModel profile, {
    required Function(String) onNameEdit,
    bool isProcessing = false,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 섹션 제목
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '기본 정보',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 이름 (수정 가능)
            _buildAdminInfoRow(
              context,
              label: '이름',
              value: profile.displayName,
              icon: Icons.badge,
              onEdit: () => onNameEdit(profile.name ?? ''),
              isProcessing: isProcessing,
            ),

            const SizedBox(height: 12),

            // 성별 (읽기 전용)
            _buildAdminInfoRow(
              context,
              label: '성별',
              value: profile.genderDisplayName,
              icon: Icons.wc,
              isReadOnly: true,
            ),

            const SizedBox(height: 12),

            // 생년월일 (읽기 전용)
            _buildAdminInfoRow(
              context,
              label: '생년월일',
              value: profile.hasBirthDate 
                ? '${profile.displayBirthDate} (만 ${DateTime.now().year - int.parse(profile.birthDate!.substring(0, 4))}세)'
                : '생년월일 미입력',
              icon: Icons.cake,
              isReadOnly: true,
            ),
          ],
        ),
      ),
    );
  }

  /// 관리자용 정보 행
  static Widget _buildAdminInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    VoidCallback? onEdit,
    bool isReadOnly = false,
    bool isProcessing = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 아이콘
        Icon(
          icon,
          size: 18,
          color: isReadOnly 
            ? Theme.of(context).colorScheme.outline
            : Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),

        // 라벨
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(width: 16),

        // 값
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isReadOnly 
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),

        // 수정 버튼 또는 잠금 아이콘
        if (isReadOnly)
          Icon(
            Icons.lock_outline,
            size: 16,
            color: Theme.of(context).colorScheme.outline,
          )
        else if (onEdit != null)
          TextButton(
            onPressed: isProcessing ? null : onEdit,
            child: isProcessing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('수정'),
          ),
      ],
    );
  }

  /// 활성화 상태 섹션
  static Widget _buildStatusSection(
    BuildContext context, {
    required ProfileModel profile,
    required Function(bool) onStatusToggle,
    bool isProcessing = false,
  }) {
    final isActive = profile.isActive;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive 
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
          : Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive 
            ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
            : Theme.of(context).colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상태 표시
          Row(
            children: [
              Icon(
                isActive ? Icons.check_circle : Icons.warning,
                color: isActive 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isActive ? '활성 계정' : '비활성 계정',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isActive 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
          
          if (!isActive) ...[
            const SizedBox(height: 8),
            Text(
              '비활성화된 계정입니다. 이 계정은 로그인 및 모임 참여가 제한됩니다.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          
          // 토글 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isProcessing ? null : () => onStatusToggle(!isActive),
              icon: isProcessing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(isActive ? Icons.block : Icons.check_circle),
              label: Text(isActive ? '비활성화' : '활성화'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isActive 
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
                foregroundColor: isActive 
                  ? Theme.of(context).colorScheme.onError
                  : Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
