import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '프로필',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // 프로필 헤더
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '사용자님',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                      Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '무료 플랜',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // 통계 카드
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.edit,
                      title: '작성한 일기',
                      count: '0',
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.auto_awesome,
                      title: 'AI 각색',
                      count: '0',
                      color: const Color(0xFF6366F1),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // 메뉴 리스트
              _buildMenuSection('계정', [
                _buildMenuItem(
                  icon: Icons.person_outline,
                  title: '프로필 수정',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.notifications_outlined,
                  title: '알림 설정',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.lock_outline,
                  title: '개인정보 보호',
                  onTap: () {},
                ),
              ]),
              
              const SizedBox(height: 20),
              
              _buildMenuSection('일기', [
                _buildMenuItem(
                  icon: Icons.backup_outlined,
                  title: '일기 백업',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.download_outlined,
                  title: '일기 내보내기',
                  onTap: () {},
                ),
              ]),
              
              const SizedBox(height: 20),
              
              _buildMenuSection('지원', [
                _buildMenuItem(
                  icon: Icons.help_outline,
                  title: '도움말',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.contact_support_outlined,
                  title: '문의하기',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.star_outline,
                  title: '앱 평가하기',
                  onTap: () {},
                ),
              ]),
              
              const SizedBox(height: 30),
              
              // 로그아웃 버튼
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    final auth = AuthService();
                    try {
                      await auth.signOut();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('로그아웃 되었습니다.')),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('로그아웃 실패: $e')),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '로그아웃',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            count,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFF64748B),
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF1E293B),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFF64748B),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}