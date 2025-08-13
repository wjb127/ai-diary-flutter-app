import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/admin_user_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final AdminUserService _userService = AdminUserService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _users = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  int _currentPage = 1;
  final int _limit = 20;
  String _sortBy = 'created_at';
  bool _ascending = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final users = await _userService.getAllUsers(
        page: _currentPage,
        limit: _limit,
        searchQuery: _searchController.text,
        sortBy: _sortBy,
        ascending: _ascending,
      );
      
      final stats = await _userService.getUserStats();
      
      setState(() {
        _users = users;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터 로드 실패: $e')),
        );
      }
    }
  }

  void _onSearch() {
    setState(() {
      _currentPage = 1;
    });
    _loadData();
  }

  void _onSort(String sortBy) {
    setState(() {
      if (_sortBy == sortBy) {
        _ascending = !_ascending;
      } else {
        _sortBy = sortBy;
        _ascending = false;
      }
      _currentPage = 1;
    });
    _loadData();
  }

  Future<void> _showUserDetails(Map<String, dynamic> user) async {
    showDialog(
      context: context,
      builder: (context) => UserDetailsDialog(
        userId: user['id'],
        userService: _userService,
        onUserUpdated: _loadData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          '👥 사용자 관리',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: '새로고침',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // 통계 카드
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: _buildStatsCards(),
          ),
          
          const Divider(height: 1),
          
          // 검색 및 필터
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '이메일이나 전화번호로 검색...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _onSearch(),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _onSearch,
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text('검색'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // 사용자 목록
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildUserTable(),
          ),
          
          // 페이징
          if (!_isLoading && _users.isNotEmpty) _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final stats = [
      {
        'title': '전체 사용자',
        'value': _stats['total_users']?.toString() ?? '0',
        'icon': Icons.people,
        'color': const Color(0xFF6366F1),
      },
      {
        'title': '이번 달 가입',
        'value': _stats['this_month_users']?.toString() ?? '0',
        'icon': Icons.person_add,
        'color': const Color(0xFF10B981),
      },
      {
        'title': '활성 사용자',
        'value': _stats['active_users']?.toString() ?? '0',
        'icon': Icons.trending_up,
        'color': const Color(0xFFF59E0B),
      },
      {
        'title': '인증 완료',
        'value': _stats['verified_users']?.toString() ?? '0',
        'icon': Icons.verified,
        'color': const Color(0xFF8B5CF6),
      },
    ];

    return Row(
      children: stats.map((stat) => Expanded(
        child: Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (stat['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: (stat['color'] as Color).withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    stat['icon'] as IconData,
                    color: stat['color'] as Color,
                    size: 20,
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                stat['value'] as String,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stat['title'] as String,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildUserTable() {
    if (_users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Color(0xFF94A3B8)),
            SizedBox(height: 16),
            Text(
              '사용자가 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
          columns: [
            DataColumn(
              label: const Text('이메일'),
              onSort: (_, __) => _onSort('email'),
            ),
            const DataColumn(label: Text('가입일')),
            const DataColumn(label: Text('마지막 로그인')),
            const DataColumn(label: Text('인증 상태')),
            const DataColumn(label: Text('작업')),
          ],
          rows: _users.map((user) => DataRow(
            cells: [
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user['email'] ?? '이메일 없음',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (user['phone'] != null)
                      Text(
                        user['phone'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                  ],
                ),
              ),
              DataCell(
                Text(
                  user['created_at'] != null
                      ? DateFormat('yyyy-MM-dd').format(DateTime.parse(user['created_at']))
                      : '-',
                ),
              ),
              DataCell(
                Text(
                  user['last_sign_in_at'] != null
                      ? DateFormat('MM-dd HH:mm').format(DateTime.parse(user['last_sign_in_at']))
                      : '로그인 기록 없음',
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: user['email_confirmed_at'] != null
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    user['email_confirmed_at'] != null ? '인증됨' : '미인증',
                    style: TextStyle(
                      fontSize: 12,
                      color: user['email_confirmed_at'] != null
                          ? Colors.green[700]
                          : Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility, size: 18),
                      onPressed: () => _showUserDetails(user),
                      tooltip: '상세보기',
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, size: 18),
                      onPressed: () => _showUserActions(user),
                      tooltip: '더보기',
                    ),
                  ],
                ),
              ),
            ],
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            '페이지 $_currentPage',
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
          const Spacer(),
          Row(
            children: [
              IconButton(
                onPressed: _currentPage > 1
                    ? () {
                        setState(() => _currentPage--);
                        _loadData();
                      }
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              IconButton(
                onPressed: _users.length == _limit
                    ? () {
                        setState(() => _currentPage++);
                        _loadData();
                      }
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showUserActions(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('사용자 상세보기'),
              onTap: () {
                Navigator.pop(context);
                _showUserDetails(user);
              },
            ),
            ListTile(
              leading: Icon(
                user['raw_user_meta_data']?['is_active'] == false
                    ? Icons.person
                    : Icons.person_off,
              ),
              title: Text(
                user['raw_user_meta_data']?['is_active'] == false
                    ? '계정 활성화'
                    : '계정 비활성화',
              ),
              onTap: () {
                Navigator.pop(context);
                _toggleUserStatus(user);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleUserStatus(Map<String, dynamic> user) async {
    final isActive = user['raw_user_meta_data']?['is_active'] != false;
    final action = isActive ? '비활성화' : '활성화';
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('계정 $action'),
        content: Text('정말 이 사용자 계정을 ${action}하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('$action하기'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = isActive
          ? await _userService.deactivateUser(user['id'])
          : await _userService.activateUser(user['id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? '계정이 성공적으로 ${action}되었습니다'
                : '계정 $action에 실패했습니다'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );

        if (success) {
          _loadData();
        }
      }
    }
  }
}

class UserDetailsDialog extends StatefulWidget {
  final String userId;
  final AdminUserService userService;
  final VoidCallback onUserUpdated;

  const UserDetailsDialog({
    super.key,
    required this.userId,
    required this.userService,
    required this.onUserUpdated,
  });

  @override
  State<UserDetailsDialog> createState() => _UserDetailsDialogState();
}

class _UserDetailsDialogState extends State<UserDetailsDialog> {
  Map<String, dynamic>? _userDetails;
  List<Map<String, dynamic>> _userDiaries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    setState(() => _isLoading = true);

    try {
      final details = await widget.userService.getUserDetails(widget.userId);
      final diaries = await widget.userService.getUserDiaries(widget.userId);

      setState(() {
        _userDetails = details;
        _userDiaries = diaries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사용자 정보 로드 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _userDetails == null
                ? const Center(child: Text('사용자 정보를 불러올 수 없습니다'))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 헤더
                      Row(
                        children: [
                          const Text(
                            '사용자 상세 정보',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // 사용자 기본 정보
                      _buildUserInfo(),
                      
                      const SizedBox(height: 24),
                      
                      // 일기 통계
                      _buildDiaryStats(),
                      
                      const SizedBox(height: 24),
                      
                      // 최근 일기 목록
                      const Text(
                        '최근 일기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(child: _buildDiaryList()),
                    ],
                  ),
      ),
    );
  }

  Widget _buildUserInfo() {
    final user = _userDetails!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('이메일', user['email'] ?? '없음'),
          _buildInfoRow('전화번호', user['phone'] ?? '없음'),
          _buildInfoRow('가입일', user['created_at'] != null
              ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(user['created_at']))
              : '없음'),
          _buildInfoRow('마지막 로그인', user['last_sign_in_at'] != null
              ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(user['last_sign_in_at']))
              : '없음'),
          _buildInfoRow('이메일 인증', user['email_confirmed_at'] != null ? '완료' : '미완료'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryStats() {
    final stats = _userDetails!['diary_stats'];
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '총 일기 수',
            stats['total_entries'].toString(),
            Icons.book,
            const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '최근 7일',
            stats['recent_entries'].toString(),
            Icons.edit,
            const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryList() {
    if (_userDiaries.isEmpty) {
      return const Center(
        child: Text(
          '작성된 일기가 없습니다',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      );
    }

    return ListView.builder(
      itemCount: _userDiaries.length,
      itemBuilder: (context, index) {
        final diary = _userDiaries[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      diary['title'] ?? '제목 없음',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      diary['date'] != null
                          ? DateFormat('yyyy-MM-dd').format(DateTime.parse(diary['date']))
                          : '날짜 없음',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}