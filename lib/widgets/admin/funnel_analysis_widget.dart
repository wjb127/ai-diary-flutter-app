import 'package:flutter/material.dart';

class FunnelAnalysisWidget extends StatelessWidget {
  final Map<String, dynamic> data;

  const FunnelAnalysisWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final visitors = data['funnelVisitors'] ?? 10000;
    final signups = data['funnelSignups'] ?? 1500;
    final firstDiary = data['funnelFirstDiary'] ?? 975;
    final activeUsers = data['funnelActiveUsers'] ?? 439;
    final premium = data['funnelPremium'] ?? 35;

    final funnelSteps = [
      FunnelStep('방문자', visitors, visitors, const Color(0xFF8B5CF6)),
      FunnelStep('회원가입', signups, visitors, const Color(0xFF6366F1)),
      FunnelStep('첫 일기 작성', firstDiary, visitors, const Color(0xFF3B82F6)),
      FunnelStep('활성 사용자', activeUsers, visitors, const Color(0xFF10B981)),
      FunnelStep('프리미엄 전환', premium, visitors, const Color(0xFFF59E0B)),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '사용자 퍼널 분석',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 20),
          ...funnelSteps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isLast = index == funnelSteps.length - 1;
            
            return Column(
              children: [
                _buildFunnelStep(step, index == 0),
                if (!isLast) ...[
                  const SizedBox(height: 8),
                  _buildDropOffIndicator(
                    funnelSteps[index].count,
                    funnelSteps[index + 1].count,
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFunnelStep(FunnelStep step, bool isFirst) {
    final percentage = isFirst ? 100.0 : (step.count / step.total * 100);
    final conversionRate = isFirst ? 100.0 : percentage;

    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: step.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: step.color.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          // 진행률 바
          Container(
            width: double.infinity * (percentage / 100),
            height: 60,
            decoration: BoxDecoration(
              color: step.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          // 텍스트 정보
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        step.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: step.color,
                        ),
                      ),
                      Text(
                        '${step.count.toStringAsFixed(0)}명',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${conversionRate.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: step.color,
                      ),
                    ),
                    if (!isFirst)
                      Text(
                        '전환율',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF64748B),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropOffIndicator(double from, double to) {
    final dropOffRate = ((from - to) / from * 100);
    final dropOffCount = from - to;

    return Row(
      children: [
        const SizedBox(width: 16),
        Container(
          width: 2,
          height: 20,
          color: const Color(0xFFEF4444).withOpacity(0.3),
        ),
        const SizedBox(width: 8),
        Text(
          '이탈: ${dropOffCount.toStringAsFixed(0)}명 (${dropOffRate.toStringAsFixed(1)}%)',
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFFEF4444),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class FunnelStep {
  final String name;
  final double count;
  final double total;
  final Color color;

  FunnelStep(this.name, this.count, this.total, this.color);
}