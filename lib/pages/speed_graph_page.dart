import 'dart:math';
import 'package:flutter/material.dart';

class SpeedGraphPage extends StatelessWidget {
  final ColorScheme colorScheme;
  final List<double> downloadSpeeds;
  final List<double> uploadSpeeds;

  const SpeedGraphPage({
    super.key,
    required this.colorScheme,
    required this.downloadSpeeds,
    required this.uploadSpeeds,
  });

  @override
  Widget build(BuildContext context) {
    final double currentDown =
        downloadSpeeds.isNotEmpty ? downloadSpeeds.last : 0.0;
    final double currentUp =
        uploadSpeeds.isNotEmpty ? uploadSpeeds.last : 0.0;

    final double avgDown = downloadSpeeds.isNotEmpty
        ? downloadSpeeds.reduce((a, b) => a + b) / downloadSpeeds.length
        : 0.0;
    final double avgUp = uploadSpeeds.isNotEmpty
        ? uploadSpeeds.reduce((a, b) => a + b) / uploadSpeeds.length
        : 0.0;

    final double maxDown =
        downloadSpeeds.isNotEmpty ? downloadSpeeds.reduce(max) : 0.0;
    final double maxUp =
        uploadSpeeds.isNotEmpty ? uploadSpeeds.reduce(max) : 0.0;

    final bool hasData =
        downloadSpeeds.isNotEmpty || uploadSpeeds.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Card(
            color: const Color(0xFF10273F),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Icon(
                        Icons.show_chart,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Speed Monitor',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (hasData
                                  ? Colors.lightGreenAccent
                                  : colorScheme.outline)
                              .withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: hasData
                                    ? Colors.lightGreenAccent
                                    : colorScheme.outline,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              hasData ? 'LIVE' : 'IDLE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                                color: hasData
                                    ? Colors.lightGreenAccent
                                    : colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Realtime download & upload throughput over the last 60 seconds.',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 16),

                  // Metrics row
                  Row(
                    children: [
                      _buildMetricChip(
                        label: 'Download',
                        value:
                            '${currentDown.toStringAsFixed(2)} MB/s',
                        sub:
                            'avg ${avgDown.toStringAsFixed(2)} • max ${maxDown.toStringAsFixed(2)}',
                        icon: Icons.download_rounded,
                        color: Colors.lightGreenAccent,
                      ),
                      const SizedBox(width: 8),
                      _buildMetricChip(
                        label: 'Upload',
                        value: '${currentUp.toStringAsFixed(2)} MB/s',
                        sub:
                            'avg ${avgUp.toStringAsFixed(2)} • max ${maxUp.toStringAsFixed(2)}',
                        icon: Icons.upload_rounded,
                        color: const Color(0xFFFFA726),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Legend
                  Row(
                    children: const [
                      _LegendDot(
                        color: Colors.lightGreenAccent,
                        label: 'Download',
                      ),
                      SizedBox(width: 12),
                      _LegendDot(
                        color: Color(0xFFFFA726),
                        label: 'Upload',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Chart container
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B1B2B),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 18),
                    child: SizedBox(
                      height: 220,
                      child: CustomPaint(
                        painter: SpeedChartPainter(
                          downloadSpeeds,
                          uploadSpeeds,
                        ),
                        child: Container(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sample interval: 1s',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.outline,
                        ),
                      ),
                      Text(
                        !hasData
                            ? 'No samples yet'
                            : 'Samples: ${max(downloadSpeeds.length, uploadSpeeds.length)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip({
    required String label,
    required String value,
    required String sub,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: const TextStyle(
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }
}

class SpeedChartPainter extends CustomPainter {
  final List<double> downloadSpeeds;
  final List<double> uploadSpeeds;

  SpeedChartPainter(this.downloadSpeeds, this.uploadSpeeds);

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = const Color(0xFF0E2238)
      ..style = PaintingStyle.fill;

    // background
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(12),
      ),
      bgPaint,
    );

    final bool hasDown = downloadSpeeds.isNotEmpty;
    final bool hasUp = uploadSpeeds.isNotEmpty;

    if (!hasDown && !hasUp) {
      final textPainter = TextPainter(
        text: const TextSpan(
          text: 'No data yet',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width);

      final offset = Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      );
      textPainter.paint(canvas, offset);
      return;
    }

    const double leftPadding = 20;
    const double rightPadding = 12;
    const double topPadding = 16;
    const double bottomPadding = 22;

    final double chartWidth = size.width - leftPadding - rightPadding;
    final double chartHeight = size.height - topPadding - bottomPadding;

    if (chartWidth <= 0 || chartHeight <= 0) return;

    final maxDown =
        hasDown ? downloadSpeeds.reduce(max) : 0.0;
    final maxUp = hasUp ? uploadSpeeds.reduce(max) : 0.0;
    final double maxY =
        max(max(maxDown, maxUp), 0.0) == 0 ? 1.0 : max(maxDown, maxUp) * 1.1;

    // grid lines (0, 50%, 100%)
    final gridPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 0.5;

    final gridPaintLight = Paint()
      ..color = Colors.white24.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 2; i++) {
      final y = topPadding + chartHeight * (i / 2);
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );
    }

    // vertical grid (4 segmen)
    for (int i = 0; i <= 4; i++) {
      final x = leftPadding + chartWidth * (i / 4);
      canvas.drawLine(
        Offset(x, topPadding),
        Offset(x, topPadding + chartHeight),
        gridPaintLight,
      );
    }

    final int sampleCount =
        max(downloadSpeeds.length, uploadSpeeds.length);

    // helper untuk gambar 1 seri
    Path buildSeriesPath(List<double> data) {
      final path = Path();
      for (int i = 0; i < sampleCount; i++) {
        final t = sampleCount == 1 ? 0.0 : i / (sampleCount - 1);
        final x = leftPadding + t * chartWidth;

        final value = i < data.length ? data[i] : 0.0;
        final normalized = (value / maxY).clamp(0.0, 1.0);
        final y = topPadding + (1 - normalized) * chartHeight;

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      return path;
    }

    Path buildAreaPath(List<double> data) {
      final path = Path();
      for (int i = 0; i < sampleCount; i++) {
        final t = sampleCount == 1 ? 0.0 : i / (sampleCount - 1);
        final x = leftPadding + t * chartWidth;

        final value = i < data.length ? data[i] : 0.0;
        final normalized = (value / maxY).clamp(0.0, 1.0);
        final y = topPadding + (1 - normalized) * chartHeight;

        if (i == 0) {
          path.moveTo(x, topPadding + chartHeight);
          path.lineTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      final endX = leftPadding +
          chartWidth * ((sampleCount - 1) / max(sampleCount - 1, 1));
      path.lineTo(endX, topPadding + chartHeight);
      path.close();
      return path;
    }

    // Download (hijau)
    if (hasDown) {
      final linePaintDown = Paint()
        ..color = Colors.lightGreenAccent
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final areaPaintDown = Paint()
        ..color = Colors.lightGreenAccent.withValues(alpha: 0.18)
        ..style = PaintingStyle.fill;

      final pathDown = buildSeriesPath(downloadSpeeds);
      final areaDown = buildAreaPath(downloadSpeeds);

      canvas.drawPath(areaDown, areaPaintDown);
      canvas.drawPath(pathDown, linePaintDown);
    }

    // Upload (oranye)
    if (hasUp) {
      final uploadColor = const Color(0xFFFFA726);

      final linePaintUp = Paint()
        ..color = uploadColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final areaPaintUp = Paint()
        ..color = uploadColor.withValues(alpha: 0.18)
        ..style = PaintingStyle.fill;

      final pathUp = buildSeriesPath(uploadSpeeds);
      final areaUp = buildAreaPath(uploadSpeeds);

      canvas.drawPath(areaUp, areaPaintUp);
      canvas.drawPath(pathUp, linePaintUp);
    }

    // label max
    final labelPainter = TextPainter(
      text: TextSpan(
        text: 'max ${max(maxDown, maxUp).toStringAsFixed(2)} MB/s',
        style: const TextStyle(color: Colors.white70, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: chartWidth);

    labelPainter.paint(canvas, Offset(leftPadding, 4));
  }

  @override
  bool shouldRepaint(covariant SpeedChartPainter oldDelegate) {
    return true;
  }
}
