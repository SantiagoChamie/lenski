import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lenski/utils/colors.dart';
import 'package:lenski/utils/fonts.dart';

/// A widget that displays a loading overlay with progress indicator.
/// 
/// Shows a modal dialog with a lightbulb icon, progress indicator, and 
/// processing message to indicate background processing. Can include an
/// optional cancel button to abort the operation.
class LoadingOverlay extends StatelessWidget {
  /// Callback function when the cancel button is pressed
  final VoidCallback? onCancel;

  /// Creates a LoadingOverlay widget.
  /// 
  /// [onCancel] is the callback function to be called when the cancel button is pressed.
  /// If null, no cancel button will be shown.
  const LoadingOverlay({
    super.key,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lightbulb_outline, size: 48, color: AppColors.yellow),
            const SizedBox(height: 16),
            CircularProgressIndicator(color: AppColors.blue),
            const SizedBox(height: 16),
            Text(
              localizations.textProcessingMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontFamily: appFonts['Subtitle'],
              ),
            ),
            if (onCancel != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
                child: Text(
                  localizations.cancel,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: appFonts['Subtitle'],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}