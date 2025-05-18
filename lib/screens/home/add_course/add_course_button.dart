import 'package:flutter/material.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/utils/colors.dart';

/// A button widget for adding a new course.
///
/// This component displays a simple add button (+) that triggers the course creation flow.
/// It's designed to appear at the bottom of the course list and uses consistent styling
/// with the rest of the application.
///
/// Features:
/// - Responsive sizing based on screen proportions
/// - Consistent styling with app's color palette
/// - Full width container for better touch target
class AddCourseButton extends StatelessWidget {
  /// Callback function triggered when the button is pressed
  final VoidCallback onPressed;

  /// Creates an AddCourseButton widget.
  /// 
  /// [onPressed] is the callback function to be called when the button is pressed.
  /// This function typically triggers the expansion of the add course interface.
  const AddCourseButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: p.sidebarButtonWidth(),
          child: Container(
            constraints: const BoxConstraints.expand(width: double.infinity),
            child: IconButton(
              icon: const Icon(
                Icons.add,
                color: AppColors.black,
                size: 30,
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.grey, // Using app's color palette
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(33),
                ),
              ),
              onPressed: onPressed,
            ),
          ),
        ),
      ],
    );
  }
}