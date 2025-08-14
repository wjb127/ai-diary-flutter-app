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
    
    // 비밀번호 인증 화면
    if (!_isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('관리자 인증'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.admin_panel_settings,
                      size: 64,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '관리자 대시보드',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '관리자 비밀번호를 입력해주세요',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: '비밀번호',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      onSubmitted: (_) => _checkPassword(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _checkPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('로그인', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('관리자 대시보드'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              setState(() {
                _isAuthenticated = false;
                _passwordController.clear();
              });
            },
            tooltip: '로그아웃',
          ),
        ],
      ),
      body: Row(
        children: [
          // 사이드바
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('대시보드'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics),
                label: Text('퍼널 분석'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('사용자 관리'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // 메인 콘텐츠
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildFunnelAnalysis();
      case 2:
        return _buildUserManagement();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '대시보드 개요',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          // 통계 카드들
          Row(
            children: [
              _buildStatCard('전체 사용자', _totalUsers.toString(), Icons.people, Colors.blue),
              const SizedBox(width: 16),
              _buildStatCard('오늘 가입', _todayUsers.toString(), Icons.person_add, Colors.green),
              const SizedBox(width: 16),
              _buildStatCard('전체 일기', _totalDiaries.toString(), Icons.book, Colors.orange),
              const SizedBox(width: 16),
              _buildStatCard('오늘 일기', _todayDiaries.toString(), Icons.edit, Colors.purple),
            ],
          ),
          const SizedBox(height: 32),
          // 최근 사용자 목록
          const Text(
            '최근 가입 사용자',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: ListView.builder(
                itemCount: _recentUsers.length,
                itemBuilder: (context, index) {
                  final user = _recentUsers[index];
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(user['email'] ?? 'Unknown'),
                    subtitle: Text('가입일: ${user['created_at']}'),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
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
}