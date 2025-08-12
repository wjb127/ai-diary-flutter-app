import 'package:flutter/material.dart';

class NorthStarMetricsWidget extends StatelessWidget {
  final Map<String, dynamic> data;

  const NorthStarMetricsWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final northStarData = data['northStar'] ?? {};

    return Container(
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
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '북극성 지표',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '사용자 가치 창조의 핵심 지표',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 28),
          
          // 주요 북극성 지표
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      '🎯',
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        '주간 활성 일기 수',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${northStarData['weeklyActiveDiaries']?.toString() ?? '2,847'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '사용자가 실제로 가치를 느끼고 지속적으로 사용하는 핵심 지표',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 보조 지표들
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildMetricCard(
                '⏱️',
                '평균 세션 시간',
                northStarData['averageSessionTime']?.toString() ?? '8분 32초',
              ),
              _buildMetricCard(
                '💝',
                '사용자 만족도',
                '${northStarData['userEngagementScore']?.toString() ?? '87.5'}점',
              ),
              _buildMetricCard(
                '✨',
                '콘텐츠 품질',
                '${northStarData['contentQualityScore']?.toString() ?? '92.3'}점',
              ),
              _buildMetricCard(
                '📈',
                '7일 리텐션',
                '${northStarData['retentionDay7']?.toString() ?? '42.8'}%',
              ),
              _buildMetricCard(
                '🔄',
                '30일 리텐션',
                '${northStarData['retentionDay30']?.toString() ?? '18.5'}%',
              ),
              _buildMetricCard(
                '🎨',
                'AI 활용률',
                '89.3%',
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 인사이트 박스
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '💡 이번 주 인사이트',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '• 주간 활성 일기 수가 전주 대비 12.3% 증가\n• 신규 사용자의 첫 주 리텐션이 45.2%로 목표 달성\n• AI 생성 일기의 만족도가 92.1%로 매우 높음',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String emoji, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}