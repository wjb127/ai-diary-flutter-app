import 'package:flutter/material.dart';

class RetentionChartWidget extends StatelessWidget {
  final Map<String, dynamic> data;

  const RetentionChartWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final retentionData = data['retentionData'] as List<dynamic>? ?? [];
    
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
                '사용자 리텐션 곡선',
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
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '30일 추적',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: retentionData.isEmpty
                ? const Center(
                    child: Text(
                      '리텐션 데이터를 불러오는 중...',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  )
                : CustomPaint(
                    size: Size.infinite,
                    painter: RetentionChartPainter(retentionData),
                  ),
          ),
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _buildLegendItem('Day 1', '100%', const Color(0xFF6366F1)),
        const SizedBox(width: 20),
        _buildLegendItem('Day 7', '42.8%', const Color(0xFF10B981)),
        const SizedBox(width: 20),
        _buildLegendItem('Day 30', '18.5%', const Color(0xFFF59E0B)),
      ],
    );
  }

  Widget _buildLegendItem(String day, String retention, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$day: $retention',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class RetentionChartPainter extends CustomPainter {
  final List<dynamic> data;

  RetentionChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6366F1)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = const Color(0xFF6366F1).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;

    final textStyle = const TextStyle(
      color: Color(0xFF64748B),
      fontSize: 12,
    );

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // 격자 그리기
    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );

      // Y축 라벨
      final percentage = (100 - i * 25).toString();
      textPainter.text = TextSpan(text: '$percentage%', style: textStyle);
      textPainter.layout();
      textPainter.paint(canvas, Offset(-30, y - 6));
    }

    if (data.isEmpty) return;

    final path = Path();
    final fillPath = Path();
    final points = <Offset>[];

    // 데이터 포인트 계산
    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final day = item['day'] as int;
      final retention = double.tryParse(item['retention'].toString()) ?? 0;

      final x = (day - 1) * size.width / (data.length - 1);
      final y = size.height * (1 - retention / 100);

      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // 채우기 영역 완성
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    // 채우기 그리기
    canvas.drawPath(fillPath, fillPaint);

    // 선 그리기
    canvas.drawPath(path, paint);

    // 포인트 그리기
    final pointPaint = Paint()
      ..color = const Color(0xFF6366F1)
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
      canvas.drawCircle(
        point,
        4,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(point, 2, pointPaint);
    }

    // X축 라벨 (주요 일자만)
    final majorDays = [1, 7, 14, 21, 30];
    for (final day in majorDays) {
      if (day <= data.length) {
        final x = (day - 1) * size.width / (data.length - 1);
        textPainter.text = TextSpan(text: 'D$day', style: textStyle);
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - 8, size.height + 8));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}