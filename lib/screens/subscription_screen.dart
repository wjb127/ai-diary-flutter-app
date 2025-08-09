import 'package:flutter/material.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '구독',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더 섹션
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF59E0B),
                      Color(0xFFEF4444),
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
                        Icons.star,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'AI 일기장 프리미엄',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '더 풍부한 AI 각색과 무제한 일기 작성',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // 현재 플랜
              const Text(
                '현재 플랜',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              
              const SizedBox(height: 12),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.free_breakfast,
                      color: Color(0xFF64748B),
                      size: 24,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '무료 플랜',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '월 5회 AI 각색 이용 가능',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      label: Text(
                        '현재 플랜',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: Color(0xFF10B981),
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // 프리미엄 플랜
              const Text(
                '프리미엄 플랜',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              
              const SizedBox(height: 12),
              
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Color(0xFF6366F1),
                            size: 28,
                          ),
                          SizedBox(width: 12),
                          Text(
                            '프리미엄',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '₩9,900',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '/월',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      ..._buildFeatureList([
                        '무제한 AI 일기 각색',
                        '고급 AI 모델 사용',
                        '일기 백업 및 동기화',
                        '테마 및 폰트 커스터마이징',
                        '데이터 내보내기',
                        '우선 고객 지원',
                      ]),
                      
                      const SizedBox(height: 24),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _showSubscriptionDialog(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '프리미엄 구독하기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // FAQ 섹션
              const Text(
                '자주 묻는 질문',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              
              const SizedBox(height: 12),
              
              _buildFAQItem(
                '구독을 취소할 수 있나요?',
                '언제든지 설정에서 구독을 취소할 수 있습니다. 구독 기간이 끝나면 자동으로 무료 플랜으로 전환됩니다.',
              ),
              
              const SizedBox(height: 12),
              
              _buildFAQItem(
                '결제는 어떻게 이루어지나요?',
                'App Store 또는 Google Play Store를 통해 안전하게 결제됩니다.',
              ),
              
              const SizedBox(height: 12),
              
              _buildFAQItem(
                '무료 체험이 있나요?',
                '첫 7일간 무료로 프리미엄 기능을 체험해보실 수 있습니다.',
              ),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFeatureList(List<String> features) {
    return features.map((feature) => Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF10B981),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    )).toList();
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '구독 기능',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            '구독 기능은 현재 개발 중입니다.\n실제 서비스에서는 In-App Purchase를 통해 구독할 수 있습니다.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
}