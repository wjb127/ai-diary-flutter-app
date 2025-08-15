import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class AIDisclaimerScreen extends StatelessWidget {
  const AIDisclaimerScreen({super.key});

  Future<void> _acceptDisclaimer(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ai_disclaimer_accepted', true);
    
    if (context.mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Center(
                        child: Icon(
                          Icons.auto_awesome,
                          size: 64,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Center(
                        child: Text(
                          'AI 기능 안내',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Google Play Store 정책 준수 사항
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFDDD6FE),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Color(0xFF6366F1),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'AI 생성 콘텐츠 고지',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '이 앱은 AI(인공지능)를 사용하여 일기를 각색합니다:',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildBulletPoint('AI가 생성한 내용은 창작물이며 실제와 다를 수 있습니다'),
                            _buildBulletPoint('개인정보는 안전하게 처리되며 AI 학습에 사용되지 않습니다'),
                            _buildBulletPoint('생성된 내용은 사용자가 검토 후 저장할 수 있습니다'),
                            _buildBulletPoint('부적절한 내용이 생성될 경우 재생성하거나 수정 가능합니다'),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // 사용 제한 안내
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFCD34D),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  color: Color(0xFFF59E0B),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '일일 사용 제한',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildBulletPoint('하루 최대 10회까지 AI 일기 생성 가능'),
                            _buildBulletPoint('매일 자정에 사용 횟수가 초기화됩니다'),
                            _buildBulletPoint('프리미엄 구독 서비스는 준비 중입니다'),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // 의료 목적 아님 면책조항 (강조)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFCA5A5),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_outlined,
                                  color: Color(0xFFEF4444),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '중요 안내사항',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF991B1B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '이 앱은 의료 목적이 아닙니다',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF991B1B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildBulletPoint('개인 일기 작성 및 감정 기록용 앱입니다', Colors.red),
                            _buildBulletPoint('정신 건강 치료나 상담을 대체할 수 없습니다', Colors.red),
                            _buildBulletPoint('의료적 조언이나 진단을 제공하지 않습니다', Colors.red),
                            _buildBulletPoint('심각한 정신 건강 문제는 전문가와 상담하세요', Colors.red),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // 책임 제한
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  color: Color(0xFF6B7280),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '이용 안내',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '• AI 생성 콘텐츠는 참고용이며 정확성을 보장하지 않습니다\n'
                              '• 의료, 법률, 금융 조언으로 사용할 수 없습니다\n'
                              '• 13세 이상 사용을 권장합니다\n'
                              '• 저장된 일기는 사용자가 언제든 삭제할 수 있습니다',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 동의 버튼
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _acceptDisclaimer(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '이해했으며 동의합니다',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildBulletPoint(String text, [Color? color]) {
    final textColor = color ?? const Color(0xFF475569);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: TextStyle(
              fontSize: 14,
              color: textColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: textColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}