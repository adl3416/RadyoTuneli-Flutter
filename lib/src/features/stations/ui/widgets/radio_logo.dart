import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/radio_avatar_helper.dart';

/// Radyo logosu widget'ı - Logo varsa gösterir, yoksa baş harf avatar'ı
class RadioLogo extends StatelessWidget {
  final String radioName;
  final String? logoUrl;
  final double size;
  final bool showBorder;

  const RadioLogo({
    Key? key,
    required this.radioName,
    this.logoUrl,
    this.size = 56,
    this.showBorder = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (logoUrl != null && logoUrl!.isNotEmpty) {
      if (logoUrl!.startsWith('assets/')) {
        return _buildAssetLogo();
      } else if (logoUrl!.startsWith('file://')) {
        return _buildFileLogo();
      } else if (logoUrl!.startsWith('http://') || logoUrl!.startsWith('https://')) {
        return _buildImageLogo();
      }
    }
    return _buildLetterAvatar();
  }

  /// Asset logo widget'ı (yerel dosya)
  Widget _buildAssetLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: showBorder ? Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 2,
        ) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          logoUrl!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildLetterAvatarContent();
          },
        ),
      ),
    );
  }

  /// Network logo widget'ı
  Widget _buildImageLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: showBorder ? Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 2,
        ) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          imageUrl: logoUrl!,
          fit: BoxFit.contain,
          placeholder: (context, url) => Center(
            child: SizedBox(
              width: size * 0.4,
              height: size * 0.4,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, url, error) {
            // Hata olursa baş harf avatar'ına geç
            return _buildLetterAvatarContent();
          },
        ),
      ),
    );
  }

  /// Local file:// logo widget'ı
  Widget _buildFileLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: showBorder ? Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 2,
        ) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          logoUrl!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildLetterAvatarContent();
          },
        ),
      ),
    );
  }

  /// Baş harf avatar widget'ı
  Widget _buildLetterAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: showBorder ? Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 2,
        ) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: _buildLetterAvatarContent(),
      ),
    );
  }

  /// Baş harf avatar içeriği
  Widget _buildLetterAvatarContent() {
    final color = RadioAvatarHelper.getColorForRadio(radioName);
    final lighterColor = RadioAvatarHelper.getLighterColor(color);
    final initial = RadioAvatarHelper.getInitial(radioName);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            lighterColor,
            color,
          ],
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: size * 0.45, // Harfin boyutu container'ın %45'i
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
