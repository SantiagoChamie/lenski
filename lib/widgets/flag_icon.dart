import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// A circular flag icon with a border
class FlagIcon extends StatelessWidget {
  final double size;
  final double borderWidth;
  final String imageUrl;
  final Color? borderColor;

  /// Creates a FlagIcon widget.
  /// 
  /// [size] is the diameter of the circular icon.
  /// [borderWidth] is the width of the border around the icon.
  /// [imageUrl] is the URL of the image to be displayed inside the icon.
  /// [borderColor] is the color of the border around the icon. If not provided, defaults to white.
  const FlagIcon({
    super.key,
    required this.size,
    required this.borderWidth,
    required this.imageUrl,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor ?? Colors.white, width: borderWidth),
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          width: size,
          height: size,
          placeholder: (context, url) => Container(
            color: const Color(0xFFF5F0F6),
            child: const Icon(Icons.language, color: Colors.black54),
          ),
          errorWidget: (context, url, error) => Container(
            color: const Color(0xFFF5F0F6),
            child: const Icon(Icons.language, color: Colors.black54),
          ),
        ),
      ),
    );
  }
}