import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../models/book_question/book_question_model.dart';

/// 발제문 상세 페이지용 포스트잇 위젯들
/// 
/// 기존 모임 상세 페이지의 포스트잇 스타일을 참고하여 제작
/// - 연한 노란색 배경 (#FFF59D)
/// - 그림자 효과
/// - 익명 표시 (작성자 이름 숨김)
/// - 관리자급만 수정/삭제 버튼 표시
class PostItWidgets {

  /// 📄 발제문 포스트잇 카드 (읽기 전용)
  static Widget buildPostItCard(
    BuildContext context,
    BookQuestionModel bookQuestion, {
    required bool canEdit, // 수정/삭제 권한 여부
    VoidCallback? onEdit,
    VoidCallback? onDelete,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // 🎨 다크모드에서도 라이트모드와 동일한 노란색 포스트잇 유지
    const Color postItColor = Color(0xFFFFF59D); // 밝은 노란색
    
    final Color shadowColor = isDarkMode
        ? Colors.black.withOpacity(0.4)  // 다크모드: 더 진한 그림자
        : Colors.black.withOpacity(0.15); // 라이트모드: 기존 그림자

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        height: 140,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: postItColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 발제문 내용
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 발제문 내용 (익명 표시 제거)
                  Expanded(
                    child: Text(
                      bookQuestion.content,
                      style: context.textStyles.bodyMedium?.copyWith(
                        fontSize: 13,
                        height: 1.3,
                        // 🎨 노란색 배경에 잘 보이는 진한 색상
                        color: const Color(0xFF2E2E2E),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 8, // 더 많은 줄 수 허용
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            
            // 수정/삭제 버튼 (관리자급만)
            if (canEdit)
              Positioned(
                top: 4,
                right: 4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 수정 버튼
                    GestureDetector(
                      onTap: onEdit,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.edit,
                          size: 14,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 4),
                    
                    // 삭제 버튼
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.delete,
                          size: 14,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 📝 수정용 포스트잇 다이얼로그
  static void showEditDialog(
    BuildContext context,
    BookQuestionModel bookQuestion, {
    required Function(String) onSave,
    VoidCallback? onCancel,
  }) {
    final TextEditingController controller = TextEditingController(
      text: bookQuestion.content,
    );
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF59D), // 포스트잇 색상
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.sticky_note_2,
                  size: 16,
                  color: Color(0xFF2E2E2E),
                ),
              ),
              const SizedBox(width: 8),
              const Text('발제문 수정'),
            ],
          ),
          content: Container(
            width: 400,
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF59D), // 포스트잇 색상
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: context.textStyles.bodyMedium?.copyWith(
                fontSize: 14,
                height: 1.4,
                color: const Color(0xFF2E2E2E),
              ),
              decoration: const InputDecoration(
                hintText: '발제문 내용을 입력하세요...',
                hintStyle: TextStyle(
                  color: Color(0xFF666666),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onCancel?.call();
              },
              child: Text(
                '취소',
                style: TextStyle(
                  color: context.colors.onSurface.withOpacity(0.7),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final newContent = controller.text.trim();
                if (newContent.isNotEmpty) {
                  Navigator.of(dialogContext).pop();
                  onSave(newContent);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('발제문 내용을 입력해주세요.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.onPrimary,
              ),
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

  /// 🗑️ 삭제 확인 다이얼로그 (포스트잇 스타일)
  static void showDeleteDialog(
    BuildContext context,
    BookQuestionModel bookQuestion, {
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.delete,
                  size: 16,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(width: 8),
              const Text('발제문 삭제'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '다음 발제문을 정말 삭제하시겠습니까?',
                style: TextStyle(fontSize: 16),
              ),
              
              const SizedBox(height: 16),
              
              // 삭제할 포스트잇 미리보기
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF59D).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Text(
                  bookQuestion.content.length > 100 
                    ? '${bookQuestion.content.substring(0, 100)}...'
                    : bookQuestion.content,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: const Color(0xFF2E2E2E),
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                '⚠️ 삭제된 발제문은 복구할 수 없습니다.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onCancel?.call();
              },
              child: Text(
                '취소',
                style: TextStyle(
                  color: context.colors.onSurface.withOpacity(0.7),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  /// 📋 빈 그룹 상태 위젯
  static Widget buildEmptyGroup(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.outline.withOpacity(0.3),
          style: BorderStyle.solid,
        ),
        color: context.colors.surface.withOpacity(0.3),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sticky_note_2_outlined,
              size: 48,
              color: context.colors.outline.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              '이 조에는 아직 발제문이 없습니다',
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.outline,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '조원들이 발제문을 작성하면 여기에 표시됩니다',
              style: context.textStyles.bodySmall?.copyWith(
                color: context.colors.outline.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📚 발제문 그리드 (포스트잇들을 격자로 배치)
  static Widget buildPostItGrid(
    BuildContext context,
    List<BookQuestionModel> bookQuestions, {
    required bool canEdit,
    required Function(BookQuestionModel) onEdit,
    required Function(BookQuestionModel) onDelete,
    VoidCallback? onPostItTap,
  }) {
    if (bookQuestions.isEmpty) {
      return buildEmptyGroup(context);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // 📱 반응형 그리드 설정
        int crossAxisCount;
        if (constraints.maxWidth < 600) {
          crossAxisCount = 1; // 모바일: 1개 (세로 스크롤)
        } else if (constraints.maxWidth < 900) {
          crossAxisCount = 2; // 태블릿: 2개
        } else if (constraints.maxWidth < 1200) {
          crossAxisCount = 3; // 데스크탑: 3개
        } else {
          crossAxisCount = 4; // 대형 화면: 4개
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 200 / 140, // 포스트잇 비율 (200x140)
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: bookQuestions.length,
          itemBuilder: (context, index) {
            final bookQuestion = bookQuestions[index];
            
            return buildPostItCard(
              context,
              bookQuestion,
              canEdit: canEdit,
              onEdit: () => onEdit(bookQuestion),
              onDelete: () => onDelete(bookQuestion),
              onTap: onPostItTap,
            );
          },
        );
      },
    );
  }
}
