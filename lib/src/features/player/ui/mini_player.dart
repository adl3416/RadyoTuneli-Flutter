import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../favorites/data/favorites_provider.dart';
import '../../stations/ui/widgets/radio_logo.dart';
import '../data/player_provider.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateProvider);
    final palette = _PlayerPalette.fromTheme(Theme.of(context));
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    if (playerState.currentStation == null) {
      return Container(
        height: 74 + bottomInset,
        decoration: palette.containerDecoration,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.radio,
                color: palette.accent.withValues(alpha: 0.78),
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'Bir radyo seçin',
                style: TextStyle(
                  color: palette.muted,
                  fontSize: 14,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (playerState.currentStation == null) return const SizedBox.shrink();

    final station = playerState.currentStation!;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: 96 + bottomInset,
          decoration: palette.containerDecoration,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.zero,
            child: InkWell(
              borderRadius: BorderRadius.zero,
              onTap: () => _showFullScreenPlayer(context),
              child: Padding(
                padding: EdgeInsets.fromLTRB(14, 12, 14, 12 + bottomInset),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            palette.accent,
                            palette.accent.withValues(alpha: 0.8),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: palette.accent.withValues(alpha: 0.24),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: RadioLogo(
                        radioName: station.name,
                        logoUrl: station.logoUrl,
                        size: 50,
                        showBorder: false,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            station.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: palette.text,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15.5,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            playerState.isPlaying ? 'Çalıyor' : 'Duraklatıldı',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: palette.muted,
                                  fontSize: 12,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Consumer(
                      builder: (context, ref, child) {
                        final favorites = ref.watch(favoritesProvider);
                        final isFavorite = favorites.contains(station.id);

                        return IconButton(
                          key: ValueKey('fav_${station.id}_$isFavorite'),
                          style: IconButton.styleFrom(
                            fixedSize: const Size(42, 42),
                            backgroundColor: palette.secondaryButton,
                            foregroundColor:
                                isFavorite ? AppTheme.gradientPink : palette.text,
                            side: BorderSide(color: palette.secondaryBorder),
                          ),
                          onPressed: () {
                            HapticFeedback.heavyImpact();
                            ref.read(favoritesProvider.notifier).toggleFavorite(
                                  station.id,
                                );
                            Future.microtask(
                              () => ref.invalidate(favoritesProvider),
                            );
                          },
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_outline,
                            color: isFavorite ? AppTheme.gradientPink : palette.text,
                            size: 20,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    if (playerState.isLoading)
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: palette.secondaryButton,
                          borderRadius: BorderRadius.circular(23),
                          border: Border.all(
                            color: palette.secondaryBorder,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: _NeonSpinner(size: 30, color: palette.accent),
                        ),
                      )
                    else
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: palette.playButton,
                          borderRadius: BorderRadius.circular(23),
                          boxShadow: [
                            BoxShadow(
                              color: palette.playButton.withValues(alpha: 0.34),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: palette.playIcon,
                          ),
                          onPressed: () async {
                            if (playerState.isPlaying) {
                              await ref.read(playerStateProvider.notifier).pause();
                            } else {
                              await ref.read(playerStateProvider.notifier).resume();
                            }
                          },
                          icon: Icon(
                            playerState.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: palette.playIcon,
                            size: 26,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                  ],
                ),
              ),
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
        final palette = _PlayerPalette.fromTheme(Theme.of(context));
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.12,
          maxChildSize: 0.94,
          expand: false,
          snap: true,
          snapSizes: const [0.9],
          shouldCloseOnMinExtent: true,
          builder: (context, _) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [palette.background, palette.backgroundSoft],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: const FullScreenPlayer(),
            );
          },
        );
      },
    );
  }
}

class _PlayerPalette {
  final Color background;
  final Color backgroundSoft;
  final Color border;
  final Color text;
  final Color muted;
  final Color accent;
  final Color playButton;
  final Color playIcon;
  final Color secondaryButton;
  final Color secondaryBorder;

  const _PlayerPalette({
    required this.background,
    required this.backgroundSoft,
    required this.border,
    required this.text,
    required this.muted,
    required this.accent,
    required this.playButton,
    required this.playIcon,
    required this.secondaryButton,
    required this.secondaryBorder,
  });

  factory _PlayerPalette.fromTheme(ThemeData theme) {
    if (theme.brightness == Brightness.light) {
      return _PlayerPalette(
        background: const Color(0xFFFB8C00), // Koyu Turuncu
        backgroundSoft: const Color(0xFFF57C00),
        border: Colors.black.withValues(alpha: 0.08),
        text: Colors.white,
        muted: Colors.white.withValues(alpha: 0.8),
        accent: Colors.white,
        playButton: Colors.white,
        playIcon: const Color(0xFFFB8C00),
        secondaryButton: Colors.white.withValues(alpha: 0.1),
        secondaryBorder: Colors.white.withValues(alpha: 0.2),
      );
    }

    const background = Color(0xFF131525);
    const backgroundSoft = Color(0xFF0F1121);

    return _PlayerPalette(
      background: background,
      backgroundSoft: backgroundSoft,
      border: Colors.white.withValues(alpha: 0.08),
      text: Colors.white,
      muted: Colors.white.withValues(alpha: 0.64),
      accent: const Color(0xFFFB8C00),
      playButton: const Color(0xFFFB8C00),
      playIcon: Colors.white,
      secondaryButton: Colors.white.withValues(alpha: 0.10),
      secondaryBorder: Colors.white.withValues(alpha: 0.14),
    );
  }

  BoxDecoration get containerDecoration {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          background.withValues(alpha: 0.75),
          backgroundSoft.withValues(alpha: 0.65),
        ],
      ),
      borderRadius: BorderRadius.zero,
      border: Border(top: BorderSide(color: border.withValues(alpha: 0.1), width: 0.5)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, -4),
        ),
      ],
    );
  }
}

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

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = color.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

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

    final hx = c.dx + r * math.cos(rotation + math.pi / 2);
    final hy = c.dy + r * math.sin(rotation + math.pi / 2);
    canvas.drawCircle(
      Offset(hx, hy),
      4.5,
      Paint()
        ..color = color.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawCircle(
      Offset(hx, hy),
      2.2,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_NeonRingPainter old) => old.progress != progress;
}

class FullScreenPlayer extends ConsumerWidget {
  const FullScreenPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateProvider);
    final palette = _PlayerPalette.fromTheme(Theme.of(context));

    if (playerState.currentStation == null) {
      return Center(
        child: Text(
          'İstasyon çalmıyor',
          style: TextStyle(
            color: palette.text,
            fontSize: 16,
          ),
        ),
      );
    }

    final station = playerState.currentStation!;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _SheetDragHandle(color: palette.muted),
            const Spacer(),
            Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.30),
                    offset: const Offset(0, 8),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: RadioLogo(
                radioName: station.name,
                logoUrl: station.logoUrl,
                size: 190,
                showBorder: true,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              station.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: palette.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 18),
            _RhythmVisualizer(
              isPlaying: playerState.isPlaying,
              color: palette.accent,
              glowColor: palette.playButton,
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, _) {
                final favorites = ref.watch(favoritesProvider);
                final isFavorite = favorites.contains(station.id);
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(favoritesProvider.notifier).toggleFavorite(
                          station.id,
                        );
                    Future.microtask(() => ref.invalidate(favoritesProvider));
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey(isFavorite),
                      color:
                          isFavorite ? const Color(0xFFFB7185) : palette.muted,
                      size: 36,
                    ),
                  ),
                );
              },
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _GlassActionButton(
                  icon: Icons.skip_previous,
                  color: palette.text,
                  backgroundColor: palette.text.withValues(alpha: 0.10),
                  borderColor: palette.border,
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    await ref
                        .read(playerStateProvider.notifier)
                        .previousStation();
                  },
                ),
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: palette.playButton,
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: palette.playButton.withValues(alpha: 0.30),
                        offset: const Offset(0, 4),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: playerState.isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: palette.playIcon,
                            strokeWidth: 3,
                          ),
                        )
                      : IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: palette.playIcon,
                          ),
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
                            color: palette.playIcon,
                            size: 36,
                          ),
                        ),
                ),
                _GlassActionButton(
                  icon: Icons.skip_next,
                  color: palette.text,
                  backgroundColor: palette.text.withValues(alpha: 0.10),
                  borderColor: palette.border,
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    await ref.read(playerStateProvider.notifier).nextStation();
                  },
                ),
              ],
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  await ref.read(playerStateProvider.notifier).stop();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.text.withValues(alpha: 0.10),
                  foregroundColor: palette.text,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: BorderSide(
                      color: palette.border,
                      width: 1,
                    ),
                  ),
                ),
                child: const Text(
                  'Durdur',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _GlassActionButton extends StatelessWidget {
  final IconData icon;
  final Future<void> Function() onTap;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;

  const _GlassActionButton({
    required this.icon,
    required this.onTap,
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(27),
        border: Border.fromBorderSide(
          BorderSide(color: borderColor),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(27),
          child: Icon(
            icon,
            size: 28,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _RhythmVisualizer extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  final Color glowColor;

  const _RhythmVisualizer({
    required this.isPlaying,
    required this.color,
    required this.glowColor,
  });

  @override
  State<_RhythmVisualizer> createState() => _RhythmVisualizerState();
}

class _RhythmVisualizerState extends State<_RhythmVisualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  static const _barCount = 15;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _RhythmVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isPlaying && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final progress = _controller.value;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_barCount, (index) {
              final phase = (progress * math.pi * 2) + (index * 0.55);
              final wave = (math.sin(phase) + 1) / 2;
              final barHeight = widget.isPlaying
                  ? 10.0 + (wave * 34.0)
                  : 10.0 + ((index % 3) * 4.0);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 5,
                    height: barHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          widget.glowColor.withValues(
                            alpha: widget.isPlaying ? 0.95 : 0.40,
                          ),
                          widget.color.withValues(
                            alpha: widget.isPlaying ? 0.90 : 0.35,
                          ),
                        ],
                      ),
                      boxShadow: widget.isPlaying
                          ? [
                              BoxShadow(
                                color: widget.glowColor.withValues(alpha: 0.28),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _SheetDragHandle extends StatelessWidget {
  final Color color;

  const _SheetDragHandle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          width: 50,
          height: 5,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
