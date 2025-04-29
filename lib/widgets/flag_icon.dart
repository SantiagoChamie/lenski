import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lenski/utils/languages.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlagIcon extends StatefulWidget {
  final double size;
  final double borderWidth;
  final String language;
  final Color? borderColor;

  const FlagIcon({
    super.key,
    required this.size,
    required this.borderWidth,
    required this.language,
    this.borderColor,
  });

  @override
  State<FlagIcon> createState() => _FlagIconState();
}

class _FlagIconState extends State<FlagIcon> {
  int currentIndex = 0; // Initialize with default value
  late SharedPreferences prefs;
  bool _isLoaded = false; // Add loading state

  @override
  void initState() {
    super.initState();
    _loadSavedIndex();
  }

  Future<void> _loadSavedIndex() async {
    prefs = await SharedPreferences.getInstance();
    if (mounted) { // Check if widget is still mounted
      setState(() {
        currentIndex = prefs.getInt('flag_${widget.language}') ?? 0;
        _isLoaded = true;
      });
    }
  }

  Future<void> _cycleFlag() async {
    if (!_isLoaded) return; // Don't cycle if not loaded

    final flags = languageFlags[widget.language]!;
    final nextIndex = (currentIndex + 1) % flags.length;

    await prefs.setInt('flag_${widget.language}', nextIndex);

    setState(() {
      currentIndex = nextIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _cycleFlag,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: widget.borderColor ?? Colors.white, width: widget.borderWidth),
        ),
        child: ClipOval(
          child: !_isLoaded
              ? Container( // Show loading indicator
                  color: const Color(0xFFF5F0F6),
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                )
              : CachedNetworkImage(
                  imageUrl: languageFlags[widget.language]![currentIndex],
                  fit: BoxFit.cover,
                  width: widget.size,
                  height: widget.size,
                  fadeInCurve: Curves.linear,  // Remove fade animation
                  fadeOutCurve: Curves.linear,  // Remove fade animation
                  
                  fadeOutDuration: Duration.zero,  // Remove fade animation
                  placeholderFadeInDuration: Duration.zero,  // Remove fade animation
                  fadeInDuration: Duration.zero,  // Remove fade animation
                  errorWidget: (context, url, error) => Container(
                    color: const Color(0xFFF5F0F6),
                    child: const Icon(Icons.language, color: Colors.black54),
                  ),
                ),
        ),
      ),
    );
  }
}