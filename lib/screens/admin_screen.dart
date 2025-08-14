import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/localization_service.dart';
import 'package:provider/provider.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _authService = AuthService();
  int _selectedIndex = 0;
  
  // 관리자 비밀번호 (실제 운영시 환경변수로 관리)
  static const String _adminPassword = 'admin1234';
  bool _isAuthenticated = false;
  final _passwordController = TextEditingController();
  
  // 통계 데이터
  int _totalUsers = 0;
  int _todayUsers = 0;
  int _totalDiaries = 0;
  int _todayDiaries = 0;
  List<Map<String, dynamic>> _recentUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
  }
  
  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _checkPassword() {
    if (_passwordController.text == _adminPassword) {
      setState(() {
        _isAuthenticated = true;
      });
      _loadDashboardData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 틀렸습니다')),
      );
    }
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      final supabase = Supabase.instance.client;
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      
      // 전체 사용자 수 (diary_entries에서 unique user_id 카운트)
      final allDiariesResult = await supabase
          .from('diary_entries')
          .select('user_id');
      final uniqueUsers = (allDiariesResult as List)
          .map((e) => e['user_id'])
          .toSet()
          .length;
      _totalUsers = uniqueUsers;
      
      // 오늘 새로운 사용자 수 (오늘 처음 일기 작성한 사용자)
      final todayDiariesResult = await supabase
          .from('diary_entries')
          .select('user_id, created_at')
          .gte('created_at', todayStart.toIso8601String());
      final todayUniqueUsers = (todayDiariesResult as List)
          .map((e) => e['user_id'])
          .toSet()
          .length;
      _todayUsers = todayUniqueUsers;
      
      // 전체 일기 수
      final totalDiariesResult = await supabase
          .from('diary_entries')
          .select('id');
      _totalDiaries = (totalDiariesResult as List).length;
      
      // 오늘 작성된 일기 수
      final todayAllDiariesResult = await supabase
          .from('diary_entries')
          .select('id')
          .gte('created_at', todayStart.toIso8601String());
      _todayDiaries = (todayAllDiariesResult as List).length;
      
      // 최근 작성된 일기 목록 (사용자 정보 포함)
      final recentDiariesResult = await supabase
          .from('diary_entries')
          .select('user_id, title, created_at')
          .order('created_at', ascending: false)
          .limit(10);
      _recentUsers = List<Map<String, dynamic>>.from(recentDiariesResult)
          .map((diary) => {
                'id': diary['user_id'],
                'email': 'User ${diary['user_id']?.substring(0, 8) ?? 'Unknown'}',
                'created_at': diary['created_at'],
                'title': diary['title'],
              })
          .toList();
      
    } catch (e) {
      debugPrint('대시보드 데이터 로드 실패: $e');
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 웹이 아닌 경우 접근 차단
    if (!kIsWeb) {
      return const Scaffold(
        body: Center(
          child: Text('관리자 대시보드는 웹에서만 사용 가능합니다'),
        ),
      );
    }
    
    // 비밀번호 인증 화면 (데스크탑 최적화)
    if (!_isAuthenticated) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1B2E),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A1B2E),
                Color(0xFF2D2E4A),
              ],
            ),
          ),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              margin: const EdgeInsets.all(32),
              child: Card(
                elevation: 20,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Container(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings,
                          size: 80,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'AI 일기장 관리자',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '관리자 비밀번호를 입력하여 대시보드에 접근하세요',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: '비밀번호',
                          hintText: '관리자 비밀번호 입력',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.lock_outline),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.05),
                        ),
                        onSubmitted: (_) => _checkPassword(),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _checkPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            '로그인',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          // 개선된 사이드바
          Container(
            width: 240,
            decoration: const BoxDecoration(
              color: Color(0xFF1A1B2E),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // 로고 영역
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings,
                          color: Colors.deepPurple,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI 일기장',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '관리자 대시보드',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white12, height: 1),
                // 네비게이션 메뉴
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    children: [
                      _buildNavItem(
                        icon: Icons.dashboard_outlined,
                        title: '대시보드',
                        subtitle: '전체 통계 개요',
                        index: 0,
                      ),
                      _buildNavItem(
                        icon: Icons.analytics_outlined,
                        title: '퍼널 분석',
                        subtitle: '사용자 행동 분석',
                        index: 1,
                      ),
                      _buildNavItem(
                        icon: Icons.people_outline,
                        title: '사용자 관리',
                        subtitle: '회원 정보 관리',
                        index: 2,
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white12, height: 1),
                      const SizedBox(height: 16),
                      _buildNavItem(
                        icon: Icons.book_outlined,
                        title: '일기 관리',
                        subtitle: '콘텐츠 모니터링',
                        index: 3,
                      ),
                      _buildNavItem(
                        icon: Icons.settings_outlined,
                        title: '설정',
                        subtitle: '시스템 설정',
                        index: 4,
                      ),
                    ],
                  ),
                ),
                // 로그아웃 버튼
                Container(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isAuthenticated = false;
                        _passwordController.clear();
                      });
                    },
                    icon: const Icon(Icons.logout, size: 20),
                    label: const Text('로그아웃'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 메인 콘텐츠
          Expanded(
            child: Column(
              children: [
                // 상단 헤더
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.black12, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _getPageTitle(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // 날짜/시간 표시
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 18,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getCurrentDate(),
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // 콘텐츠 영역
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper 메서드 추가
  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: isSelected ? Colors.deepPurple.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => setState(() => _selectedIndex = index),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.deepPurple : Colors.white60,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isSelected ? Colors.white60 : Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 4,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0:
        return '대시보드 개요';
      case 1:
        return '퍼널 분석';
      case 2:
        return '사용자 관리';
      case 3:
        return '일기 관리';
      case 4:
        return '설정';
      default:
        return '대시보드';
    }
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = ['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'];
    return '${now.year}년 ${months[now.month - 1]} ${now.day}일';
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildFunnelAnalysis();
      case 2:
        return _buildUserManagement();
      case 3:
        return _buildDiaryManagement();
      case 4:
        return _buildSettings();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.deepPurple),
            const SizedBox(height: 16),
            Text('데이터 로듩 중...', style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 통계 카드들 - Row로 한 줄에 배치
          SizedBox(
            height: 140,
            child: Row(
              children: [
                Expanded(
                  child: _buildModernStatCard(
                    title: '전체 사용자',
                    value: _totalUsers.toString(),
                    icon: Icons.people_outline,
                    color: const Color(0xFF6366F1),
                    trend: '+12%',
                    trendUp: true,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildModernStatCard(
                    title: '오늘 신규 가입',
                    value: _todayUsers.toString(),
                    icon: Icons.person_add_alt_outlined,
                    color: const Color(0xFF10B981),
                    trend: '+5%',
                    trendUp: true,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildModernStatCard(
                    title: '전체 일기',
                    value: _totalDiaries.toString(),
                    icon: Icons.auto_stories_outlined,
                    color: const Color(0xFFF59E0B),
                    trend: '+23%',
                    trendUp: true,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildModernStatCard(
                    title: '오늘 작성',
                    value: _todayDiaries.toString(),
                    icon: Icons.edit_note_outlined,
                    color: const Color(0xFF8B5CF6),
                    trend: '-2%',
                    trendUp: false,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // 차트와 테이블 영역
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 왼쪽: 차트 영역 (70%)
                Expanded(
                  flex: 7,
                  child: Column(
                    children: [
                      // 첫 번째 차트 행
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildChartCard(
                                title: '주간 활동 통계',
                                subtitle: '최근 7일',
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildChartCard(
                                title: '사용자 성장 추이',
                                subtitle: '월별 통계',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 두 번째 차트 행
                      Expanded(
                        child: _buildChartCard(
                          title: '일기 작성 패턴 분석',
                          subtitle: '시간대별 분포',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // 오른쪽: 최근 활동 목록 (30%)
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '최근 활동',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text('전체 보기'),
                            ),
                          ],
                        ),
                        const Divider(),
                        Expanded(
                          child: ListView.separated(
                            itemCount: _recentUsers.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final user = _recentUsers[index];
                              return _buildActivityItem(
                                title: user['title'] ?? '제목 없음',
                                subtitle: user['email'] ?? 'Unknown',
                                time: _formatDate(user['created_at']),
                                icon: Icons.edit_note,
                                color: Colors.deepPurple,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChartCard({
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
                color: Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Text(
                '차트 영역\n(구현 예정)',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityItem({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildFunnelAnalysis() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '퍼널 분석',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '사용자 여정 분석 기능이 곧 추가됩니다',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserManagement() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '사용자 관리',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '사용자 관리 기능이 곧 추가됩니다',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDiaryManagement() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '일기 관리',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '일기 콘텐츠 관리 기능이 곧 추가됩니다',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSettings() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '설정',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '시스템 설정 기능이 곧 추가됩니다',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildModernStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String trend,
    required bool trendUp,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trendUp ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      trendUp ? Icons.trending_up : Icons.trending_down,
                      color: trendUp ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trend,
                      style: TextStyle(
                        color: trendUp ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _formatDate(String? dateStr) {
    if (dateStr == null) return '알 수 없음';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      
      if (diff.inMinutes < 60) {
        return '${diff.inMinutes}분 전';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}시간 전';
      } else if (diff.inDays < 7) {
        return '${diff.inDays}일 전';
      } else {
        return '${date.month}월 ${date.day}일';
      }
    } catch (e) {
      return dateStr;
    }
  }
}