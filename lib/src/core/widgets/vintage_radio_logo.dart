import 'package:flutter/material.dart';

class VintageRadioLogo extends StatelessWidget {
  final double size;
  final Color? primaryColor;
  final Color? accentColor;

  const VintageRadioLogo({
    super.key,
    this.size = 80,
    this.primaryColor,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final primary = primaryColor ?? const Color(0xFF8B5CF6);
    final accent = accentColor ?? const Color(0xFF9333EA);
    
    return Container(
      width: size,
      height: size,
      child: CustomPaint(
        painter: VintageRadioPainter(
          primaryColor: primary,
          accentColor: accent,
        ),
      ),
    );
  }
}

class VintageRadioPainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;

  VintageRadioPainter({
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Radyo gövdesi
    paint.color = const Color(0xFF4A4A4A);
    strokePaint.color = const Color(0xFF2A2A2A);
    
    final radioBody = RRect.fromLTRBR(
      size.width * 0.1,
      size.height * 0.25,
      size.width * 0.9,
      size.height * 0.85,
      const Radius.circular(8),
    );
    canvas.drawRRect(radioBody, paint);
    canvas.drawRRect(radioBody, strokePaint);

    // Ön panel
    paint.color = const Color(0xFF6B7280);
    final frontPanel = RRect.fromLTRBR(
      size.width * 0.15,
      size.height * 0.3,
      size.width * 0.85,
      size.height * 0.8,
      const Radius.circular(4),
    );
    canvas.drawRRect(frontPanel, paint);

    // Speaker mesh
    paint.color = const Color(0xFF374151);
    final speaker = RRect.fromLTRBR(
      size.width * 0.2,
      size.height * 0.35,
      size.width * 0.5,
      size.height * 0.55,
      const Radius.circular(2),
    );
    canvas.drawRRect(speaker, paint);

    // Speaker holes
    paint.color = const Color(0xFF1F2937);
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 6; col++) {
        final x = size.width * 0.25 + (col * size.width * 0.04);
        final y = size.height * 0.4 + (row * size.height * 0.03);
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }

    // Frekans paneli
    paint.color = const Color(0xFF1F2937);
    final freqPanel = RRect.fromLTRBR(
      size.width * 0.55,
      size.height * 0.35,
      size.width * 0.8,
      size.height * 0.5,
      const Radius.circular(2),
    );
    canvas.drawRRect(freqPanel, paint);

    // Frekans çizgileri
    strokePaint.color = primaryColor;
    strokePaint.strokeWidth = 1;
    for (int i = 0; i < 10; i++) {
      final x = size.width * 0.58 + (i * size.width * 0.02);
      final startY = size.height * 0.38;
      final endY = size.height * 0.47;
      canvas.drawLine(Offset(x, startY), Offset(x, endY), strokePaint);
    }

    // Frekans ibresi
    strokePaint.color = accentColor;
    strokePaint.strokeWidth = 2;
    canvas.drawLine(
      Offset(size.width * 0.67, size.height * 0.425),
      Offset(size.width * 0.72, size.height * 0.425),
      strokePaint,
    );
    
    paint.color = accentColor;
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.425),
      2,
      paint,
    );

    // Kontrol düğmeleri
    paint.color = const Color(0xFF374151);
    strokePaint.color = const Color(0xFF1F2937);
    strokePaint.strokeWidth = 2;
    
    // Sol düğme (Volume)
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.65), 8, paint);
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.65), 8, strokePaint);
    
    paint.color = const Color(0xFF4B5563);
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.65), 6, paint);
    
    strokePaint.color = primaryColor;
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.57),
      Offset(size.width * 0.25, size.height * 0.65),
      strokePaint,
    );

    // Sağ düğme (Tuning)
    paint.color = const Color(0xFF374151);
    strokePaint.color = const Color(0xFF1F2937);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.65), 8, paint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.65), 8, strokePaint);
    
    paint.color = const Color(0xFF4B5563);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.65), 6, paint);
    
    strokePaint.color = primaryColor;
    canvas.drawLine(
      Offset(size.width * 0.75, size.height * 0.57),
      Offset(size.width * 0.75, size.height * 0.65),
      strokePaint,
    );

    // Anten
    strokePaint.color = const Color(0xFF6B7280);
    strokePaint.strokeWidth = 3;
    canvas.drawLine(
      Offset(size.width * 0.8, size.height * 0.25),
      Offset(size.width * 0.8, size.height * 0.1),
      strokePaint,
    );
    
    strokePaint.strokeWidth = 2;
    canvas.drawLine(
      Offset(size.width * 0.8, size.height * 0.1),
      Offset(size.width * 0.7, size.height * 0.05),
      strokePaint,
    );
    
    strokePaint.color = primaryColor;
    canvas.drawLine(
      Offset(size.width * 0.8, size.height * 0.1),
      Offset(size.width * 0.9, size.height * 0.05),
      strokePaint,
    );

    // Radyo dalgaları
    strokePaint.style = PaintingStyle.stroke;
    strokePaint.strokeWidth = 1.5;
    
    final wave1 = Path();
    wave1.moveTo(size.width * 0.85, size.height * 0.2);
    wave1.quadraticBezierTo(
      size.width * 0.95, size.height * 0.15,
      size.width * 1.0, size.height * 0.1,
    );
    strokePaint.color = primaryColor.withOpacity(0.7);
    canvas.drawPath(wave1, strokePaint);

    final wave2 = Path();
    wave2.moveTo(size.width * 0.87, size.height * 0.23);
    wave2.quadraticBezierTo(
      size.width * 0.95, size.height * 0.2,
      size.width * 0.98, size.height * 0.15,
    );
    strokePaint.color = accentColor.withOpacity(0.5);
    canvas.drawPath(wave2, strokePaint);

    // Vintage detaylar
    paint.color = primaryColor;
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.32), 1, paint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.32), 1, paint);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.78), 1, paint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.78), 1, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}