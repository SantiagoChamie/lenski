import 'package:flutter/material.dart';

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
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: size,
          height: size,
        ),
      ),
    );
  }
}