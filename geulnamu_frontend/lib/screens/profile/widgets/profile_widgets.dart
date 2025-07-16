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
}
