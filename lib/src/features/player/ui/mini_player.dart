import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../data/player_provider.dart';
import '../../stations/ui/widgets/radio_logo.dart';
import '../../favorites/data/favorites_provider.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateProvider);
    final primary = Theme.of(context).colorScheme.primary;

    if (playerState.currentStation == null) {
      return Container(
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(
            top: BorderSide(
              color: primary.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, -3),
            ),
            const BoxShadow(
              color: Color(0x66000000),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.radio, color: primary.withValues(alpha: 0.45), size: 22),
            const SizedBox(width: 10),
            Text(
              'Bir radyo seçin',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.38),
                fontSize: 14,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );
    }

    final station = playerState.currentStation!;

    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(
            color: primary.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
          const BoxShadow(
            color: Color(0x80000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: InkWell(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          onTap: () {
            _showFullScreenPlayer(context);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Station Logo with colorful initials
                RadioLogo(
                  radioName: station.name,
                  logoUrl: station.logoUrl,
                  size: 58,
                  showBorder: true,
                ),

                const SizedBox(width: 16),

                // Station Info with modern typography
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        playerState.isPlaying ? 'Çalıyor' : 'Duraklatıldı',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ),
                ),

                // Favorite Toggle Button
                Consumer(
                  builder: (context, ref, child) {
                    final favorites = ref.watch(favoritesProvider);
                    final isFavorite = favorites.contains(station.id);
                    
                    return IconButton(
                      key: ValueKey('fav_${station.id}_$isFavorite'), // UI'ın güncellenmesini zorla
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        ref.read(favoritesProvider.notifier).toggleFavorite(station.id);
                        // Force a zero-delay UI refresh hint
                        Future.microtask(() => ref.invalidate(favoritesProvider));
                      },
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.redAccent : Colors.white,
                        size: 26,
                      ),
                    );
                  },
                ),

                const SizedBox(width: 8),

                // Loading indicator or Play/Pause Button with modern styling
                if (playerState.isLoading)
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(27),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: _NeonSpinner(size: 36, color: primary),
                    ),
                  )
                else
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(27),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () async {
                        if (playerState.isPlaying) {
                          await ref.read(playerStateProvider.notifier).pause();
                        } else {
                          await ref.read(playerStateProvider.notifier).resume();
                        }
                      },
                      icon: Icon(
                        playerState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: primary,
                        size: 30,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),


              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFullScreenPlayer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final primary = Theme.of(context).colorScheme.primary;
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                HSLColor.fromColor(primary).withLightness(0.12).toColor(),
                HSLColor.fromColor(primary).withLightness(0.16).toColor(),
                HSLColor.fromColor(primary).withLightness(0.22).toColor(),
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: const FullScreenPlayer(),
        );
      },
    );
  }
}

// ─── Neon Spinner ───────────────────────────────────────────────────────────

class _NeonSpinner extends StatefulWidget {
  final double size;
  final Color color;
  const _NeonSpinner({required this.size, required this.color});

  @override
  State<_NeonSpinner> createState() => _NeonSpinnerState();
}

class _NeonSpinnerState extends State<_NeonSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _NeonRingPainter(progress: _ctrl.value, color: widget.color),
      ),
    );
  }
}

class _NeonRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  _NeonRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.width - 6) / 2;
    final rotation = progress * math.pi * 2 - math.pi / 2;

    // Track ring
    canvas.drawCircle(
      c, r,
      Paint()
        ..color = color.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Gradient arc with tail
    final rect = Rect.fromCircle(center: c, radius: r);
    final gradPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: [
          Colors.transparent,
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.35),
          color.withValues(alpha: 0.85),
          color,
        ],
        stops: const [0.0, 0.55, 0.75, 0.90, 1.0],
        transform: GradientRotation(rotation),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, r, gradPaint);

    // Outer glow
    final glowPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: [
          Colors.transparent,
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.25),
          color.withValues(alpha: 0.55),
        ],
        stops: const [0.0, 0.6, 0.85, 1.0],
        transform: GradientRotation(rotation),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(c, r, glowPaint);

    // Bright head dot
    final hx = c.dx + r * math.cos(rotation + math.pi / 2);
    final hy = c.dy + r * math.sin(rotation + math.pi / 2);
    canvas.drawCircle(
      Offset(hx, hy), 4.5,
      Paint()
        ..color = color.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawCircle(
      Offset(hx, hy), 2.2,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_NeonRingPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────

class FullScreenPlayer extends ConsumerWidget {
  const FullScreenPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateProvider);

    if (playerState.currentStation == null) {
      return const Center(
        child: Text(
          'İstasyon çalmıyor',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
    }

    final station = playerState.currentStation!;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16), // 24'ten 16'ya azaltıldı
        child: Column(
          children: [
            // Drag Handle with modern styling
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
  
            const SizedBox(height: 32),
  
            // Station Logo with modern styling
            Container(
              width: 200, // 220'den 200'e küçültüldü
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 8),
                    blurRadius: 24,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: RadioLogo(
                radioName: station.name,
                logoUrl: station.logoUrl,
                size: 200,
                showBorder: true,
              ),
            ),
  
            const SizedBox(height: 30), // 40'tan 30'a azaltıldı
  
            // Station Info with modern typography
            Text(
              station.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22, // 24'ten 22'ye küçültüldü
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
  
            const SizedBox(height: 8), // 12'den 8'e azaltıldı
  
            Text(
              station.artist,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white70,
                    fontSize: 16, // 18'den 16'ya küçültüldü
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
  
            const SizedBox(height: 30), // 40'tan 30'a azaltıldı
  
            // Control Buttons with modern styling
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Previous Button - now active
                Container(
                  width: 54, // 60'tan 54'e küçültüldü
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(27),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        print('🔄 Previous button tapped in FullScreenPlayer');
                        HapticFeedback.mediumImpact();
                        try {
                          await ref.read(playerStateProvider.notifier).previousStation();
                          print('✅ Previous station method completed');
                        } catch (e) {
                          print('❌ Error calling previousStation: $e');
                        }
                      },
                      borderRadius: BorderRadius.circular(27),
                      child: const Icon(
                        Icons.skip_previous,
                        size: 28, // 32'den 28'e küçültüldü
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
  
                // Play/Pause with enhanced styling
                Container(
                  width: 70, // 80'den 70'e küçültüldü
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(0, 4),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: playerState.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.headerPurple,
                            strokeWidth: 3,
                          ),
                        )
                      : IconButton(
                          onPressed: () async {
                            if (playerState.isPlaying) {
                              await ref
                                  .read(playerStateProvider.notifier)
                                  .pause();
                            } else {
                              await ref
                                  .read(playerStateProvider.notifier)
                                  .resume();
                            }
                          },
                          icon: Icon(
                            playerState.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: AppTheme.headerPurple,
                            size: 36, // 40'tan 36'ya küçültüldü
                          ),
                        ),
                ),
  
                // Next Button - now active
                Container(
                  width: 54, // 60'tan 54'e küçültüldü
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(27),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        print('🔄 Next button tapped in FullScreenPlayer');
                        HapticFeedback.mediumImpact();
                        try {
                          await ref.read(playerStateProvider.notifier).nextStation();
                          print('✅ Next station method completed');
                        } catch (e) {
                          print('❌ Error calling nextStation: $e');
                        }
                      },
                      borderRadius: BorderRadius.circular(27),
                      child: const Icon(
                        Icons.skip_next,
                        size: 28, // 32'den 28'e küçültüldü
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
  
            const SizedBox(height: 30), // 40'tan 30'a azaltıldı
  
            // Stop Button with modern styling
            SizedBox(
              width: double.infinity,
              height: 50, // 56'dan 50'ye küçültüldü
              child: ElevatedButton(
                onPressed: () async {
                  await ref.read(playerStateProvider.notifier).stop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: const Text(
                  'Durdur',
                  style: TextStyle(
                    fontSize: 16, // 18'den 16'ya küçültüldü
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
  
            const SizedBox(height: 16), // 8'den 16'ya artırıldı (alt boşluk için)
          ],
        ),
      ),
    );
  }
}