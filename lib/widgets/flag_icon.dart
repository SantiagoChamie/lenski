import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lenski/utils/languages/language_flags.dart';
import 'package:lenski/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A circular widget that displays a flag image for a specified language.
/// 
/// The widget allows users to cycle through different flag options for each language
/// by tapping on it. The selected flag is persisted across app restarts using
/// SharedPreferences.
class FlagIcon extends StatefulWidget {
  /// Size of the flag icon in pixels (both width and height)
  final double size;
  
  /// Width of the border around the flag
  final double borderWidth;
  
  /// Language code (e.g. 'en', 'es', 'fr')
  final String language;
  
  /// Color of the border around the flag
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
  /// Current index of the selected flag variant for this language
  int currentIndex = 0;
  
  /// Shared preferences instance for persistent storage
  late SharedPreferences prefs;
  
  /// Tracks if the flag data has been loaded from preferences
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadSavedIndex();
  }

  /// Loads the saved flag index from SharedPreferences.
  ///
  /// If no index is saved for this language, defaults to 0.
  Future<void> _loadSavedIndex() async {
    prefs = await SharedPreferences.getInstance();
    if (mounted) { // Check if widget is still mounted
      setState(() {
        currentIndex = prefs.getInt('flag_${widget.language}') ?? 0;
        _isLoaded = true;
      });
    }
  }

  /// Cycles to the next available flag for the current language.
  ///
  /// Updates both the UI and persists the selection to SharedPreferences.
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
                  color: AppColors.lightGrey,
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
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
                    color: AppColors.lightGrey,
                    child: const Icon(
                      Icons.language, 
                      color: Colors.black54,
                      size: 24,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}