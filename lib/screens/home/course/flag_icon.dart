import 'package:flutter/material.dart';

/// A circular flag icon with a border
class FlagIcon extends StatelessWidget {
  final double size;
  final double borderWidth;
  final String imageUrl;

  const FlagIcon({
    super.key,
    required this.size,
    required this.borderWidth,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: borderWidth),
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