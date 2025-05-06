import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final VoidCallback? onCancel;

  const LoadingOverlay({
    super.key,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lightbulb_outline, size: 48, color: Color(0xFFEE9A1D)),
            const SizedBox(height: 16),
            const CircularProgressIndicator(color: Color(0xFF2C73DE)),
            const SizedBox(height: 16),
            const Text(
              'Your text is being processed,\nplease be patient',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontFamily: "Telex",
              ),
            ),
            if (onCancel != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "Telex",
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