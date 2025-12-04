import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../services/member/member_service.dart';
import '../../../models/member/member_list_model.dart';

/// 🎯 모임원 선택 다이얼로그 (FullScreen)
///
/// 기능:
/// - 무한 스크롤 페이지네이션
/// - 전체 선택/해제
/// - 이름 검색 필터 (로컬 필터링)
/// - 선택 인원 수 표시
class MemberSelectDialog extends StatefulWidget {
  final String accessToken;
  final Set<int> initialSelectedIds;

  const MemberSelectDialog({
    super.key,
    required this.accessToken,
    this.initialSelectedIds = const {},
  });

  /// 다이얼로그 표시 (반환: 선택된 멤버 ID Set, 취소 시 null)
  static Future<Set<int>?> show(
    BuildContext context, {
    required String accessToken,
    Set<int> initialSelectedIds = const {},
  }) {
    return showDialog<Set<int>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => MemberSelectDialog(
        accessToken: accessToken,
        initialSelectedIds: initialSelectedIds,
      ),
    );
  }

  @override
  State<MemberSelectDialog> createState() => _MemberSelectDialogState();
}

class _MemberSelectDialogState extends State<MemberSelectDialog> {
  final MemberService _memberService = MemberService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // 상태
  List<MemberListItem> _allMembers = []; // 전체 로드된 멤버
  List<MemberListItem> _filteredMembers = []; // 검색 필터링된 멤버
  Set<int> _selectedIds = {};
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String _searchQuery = '';
  String? _errorMessage;

  // 상수
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _selectedIds = Set.from(widget.initialSelectedIds);
    _scrollController.addListener(_onScroll);
    _loadMembers();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// 스크롤 리스너 (무한 스크롤)
  void _onScroll() {
    // 검색 중이 아닐 때만 무한 스크롤 작동
    if (_searchQuery.isEmpty &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      _loadMoreMembers();
    }
  }

  /// 초기 로딩
  Future<void> _loadMembers() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 1;
      _hasMore = true;
      _allMembers.clear();
    });

    try {
      final filter = MemberListFilter(
        page: 1,
        size: _pageSize,
        isDeleted: false, // 활성 멤버만
        sortBy: 'id', // memberId 기준 정렬
        isAsc: true,
      );

      final response = await _memberService.getMemberList(
        filter: filter,
        accessToken: widget.accessToken,
      );

      if (mounted) {
        setState(() {
          _allMembers = response.memberList;
          _filteredMembers = _filterBySearch(_allMembers);
          _hasMore = response.pagingResponse.pageNumber <
              response.pagingResponse.totalPages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '모임원 목록을 불러오는데 실패했습니다.';
          _isLoading = false;
        });
      }
      if (AppConfig.debugMode) {
        debugPrint('[모임원 선택] 로딩 실패: $e');
      }
    }
  }

  /// 추가 로딩 (무한 스크롤)
  Future<void> _loadMoreMembers() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final filter = MemberListFilter(
        page: nextPage,
        size: _pageSize,
        isDeleted: false,
        sortBy: 'id', // memberId 기준 정렬
        isAsc: true,
      );

      final response = await _memberService.getMemberList(
        filter: filter,
        accessToken: widget.accessToken,
      );

      if (mounted) {
        setState(() {
          _allMembers.addAll(response.memberList);
          _filteredMembers = _filterBySearch(_allMembers);
          _currentPage = nextPage;
          _hasMore = response.pagingResponse.pageNumber <
              response.pagingResponse.totalPages;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
      if (AppConfig.debugMode) {
        debugPrint('[모임원 선택] 추가 로딩 실패: $e');
      }
    }
  }

  /// 검색어로 필터링 (로컬)
  List<MemberListItem> _filterBySearch(List<MemberListItem> members) {
    if (_searchQuery.isEmpty) return List.from(members);

    final query = _searchQuery.toLowerCase();
    return members.where((member) {
      final name = member.name?.toLowerCase() ?? '';
      return name.contains(query);
    }).toList();
  }

  /// 검색 실행 (로컬 필터링만)
  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _filteredMembers = _filterBySearch(_allMembers);
    });
  }

  /// 전체 선택 (필터링된 목록 기준)
  void _selectAll() {
    setState(() {
      for (final member in _filteredMembers) {
        _selectedIds.add(member.memberId);
      }
    });
  }

  /// 전체 해제
  void _deselectAll() {
    setState(() {
      _selectedIds.clear();
    });
  }

  /// 개별 선택/해제
  void _toggleSelection(int memberId) {
    setState(() {
      if (_selectedIds.contains(memberId)) {
        _selectedIds.remove(memberId);
      } else {
        _selectedIds.add(memberId);
      }
    });
  }

  /// 선택 완료
  void _onConfirm() {
    Navigator.of(context).pop(_selectedIds);
  }

  /// 취소
  void _onCancel() {
    Navigator.of(context).pop(null);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text('모임원 선택 (${_selectedIds.length}명)'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _onCancel,
          ),
          actions: [
            TextButton(
              onPressed: _onCancel,
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: _selectedIds.isNotEmpty ? _onConfirm : null,
              child: const Text('선택 완료'),
            ),
          ],
        ),
        body: Column(
          children: [
            // 검색 + 전체 선택 버튼
            _buildHeader(context),
            
            // 구분선
            Divider(height: 1, color: colorScheme.outlineVariant),
            
            // 멤버 목록
            Expanded(
              child: _buildMemberList(context),
            ),
          ],
        ),
      ),
    );
  }

  /// 헤더 (검색 + 버튼)
  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 검색 필드
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '이름으로 검색...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 12),
          
          // 전체 선택/해제 버튼
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _filteredMembers.isNotEmpty ? _selectAll : null,
                icon: const Icon(Icons.check_box, size: 18),
                label: const Text('전체 선택'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _selectedIds.isNotEmpty ? _deselectAll : null,
                icon: const Icon(Icons.check_box_outline_blank, size: 18),
                label: const Text('전체 해제'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              const Spacer(),
              // 선택된 인원 수
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_selectedIds.length}명 선택',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 멤버 목록
  Widget _buildMemberList(BuildContext context) {
    // 로딩 중
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 에러
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMembers,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    // 빈 목록
    if (_filteredMembers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? '검색 결과가 없습니다.'
                  : '모임원이 없습니다.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // 무한 스크롤 표시 여부 (검색 중이 아닐 때만)
    final showLoadingMore = _isLoadingMore && _searchQuery.isEmpty;

    // 멤버 리스트
    return ListView.builder(
      controller: _scrollController,
      itemCount: _filteredMembers.length + (showLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        // 로딩 인디케이터
        if (index == _filteredMembers.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final member = _filteredMembers[index];
        final isSelected = _selectedIds.contains(member.memberId);

        return _buildMemberItem(context, member, isSelected);
      },
    );
  }

  /// 개별 멤버 아이템
  Widget _buildMemberItem(
    BuildContext context,
    MemberListItem member,
    bool isSelected,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isSelected
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest,
        child: Text(
          member.memberId.toString(),
          style: TextStyle(
            color: isSelected
                ? colorScheme.onPrimary
                : colorScheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      title: Text(
        member.displayName,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        member.roleDisplayName,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
      ),
      trailing: Checkbox(
        value: isSelected,
        onChanged: (_) => _toggleSelection(member.memberId),
        activeColor: colorScheme.primary,
      ),
      onTap: () => _toggleSelection(member.memberId),
      selected: isSelected,
      selectedTileColor: colorScheme.primaryContainer.withOpacity(0.3),
    );
  }
}
