import 'package:flutter/material.dart';

class ConversionChartWidget extends StatelessWidget {
  final Map<String, dynamic> data;

  const ConversionChartWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final conversionData = data['conversionData'] as List<dynamic>? ?? [];
    
    return Container(
      height: 300,
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '월별 유료 전환율',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '12개월',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFF59E0B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: conversionData.isEmpty
                ? const Center(
                    child: Text(
                      '전환율 데이터를 불러오는 중...',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  )
                : _buildBarChart(conversionData),
          ),
          const SizedBox(height: 16),
          _buildMetricsSummary(conversionData),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<dynamic> data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = (constraints.maxWidth - 40) / data.length - 8;
        final maxConversion = data
            .map((item) => double.tryParse(item['conversion'].toString()) ?? 0)
            .reduce((a, b) => a > b ? a : b);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: data.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final conversion = double.tryParse(item['conversion'].toString()) ?? 0;
            final height = (conversion / maxConversion) * (constraints.maxHeight - 60);
            final isHighlight = conversion == maxConversion;

            return Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: barWidth,
                        height: height,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: isHighlight
                                ? [
                                    const Color(0xFFF59E0B),
                                    const Color(0xFFEAB308),
                                  ]
                                : [
                                    const Color(0xFFF59E0B).withOpacity(0.7),
                                    const Color(0xFFEAB308).withOpacity(0.7),
                                  ],
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                        child: Stack(
                          children: [
                            if (height > 30)
                              Positioned(
                                top: 8,
                                left: 0,
                                right: 0,
                                child: Text(
                                  '${conversion.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['month'],
                    style: TextStyle(
                      fontSize: 10,
                      color: isHighlight
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF64748B),
                      fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildMetricsSummary(List<dynamic> data) {
    if (data.isEmpty) return const SizedBox.shrink();

    final conversions = data
        .map((item) => double.tryParse(item['conversion'].toString()) ?? 0)
        .toList();

    final average = conversions.reduce((a, b) => a + b) / conversions.length;
    final max = conversions.reduce((a, b) => a > b ? a : b);
    final min = conversions.reduce((a, b) => a < b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem('평균', '${average.toStringAsFixed(1)}%', Icons.analytics),
          ),
          Container(
            width: 1,
            height: 30,
            color: const Color(0xFFE5E7EB),
          ),
          Expanded(
            child: _buildSummaryItem('최고', '${max.toStringAsFixed(1)}%', Icons.trending_up),
          ),
          Container(
            width: 1,
            height: 30,
            color: const Color(0xFFE5E7EB),
          ),
          Expanded(
            child: _buildSummaryItem('최저', '${min.toStringAsFixed(1)}%', Icons.trending_down),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFFF59E0B),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }
}