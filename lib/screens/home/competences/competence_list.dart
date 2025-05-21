import 'package:flutter/material.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/utils/colors.dart';
import '../../../models/course_model.dart';

/// A widget that displays a vertical list of competence indicators.
///
/// This component shows colorful dot indicators for each active competence in a course.
/// Each competence is represented by a small colored circle:
/// - Listening: purple dot
/// - Speaking: red dot
/// - Reading: orange dot
/// - Writing: yellow dot
///
/// The component is designed to be compact and is typically shown along the left side
/// of a course button to provide a quick visual indication of which competences are active.
class CompetenceList extends StatelessWidget {
  /// The course containing competence information
  final Course course;

  /// Creates a CompetenceList widget.
  /// 
  /// [course] is the course object containing competence active states.
  const CompetenceList({super.key, required this.course});

  /// Returns the appropriate color for a given competence type.
  ///
  /// @param type The competence type identifier ('listening', 'speaking', 'reading', 'writing')
  /// @return The color associated with the competence type
  Color _getColor(String type) {
    switch (type) {
      case 'listening':
        return AppColors.listening;
      case 'speaking':
        return AppColors.speaking;
      case 'reading':
        return AppColors.reading;
      case 'writing':
        return AppColors.writing;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    final dotSize = p.standardPadding() / 2; // Smaller size for dots

    return SizedBox(
      width: 40, // Fixed width container
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left
        children: [
          SizedBox(height: p.standardPadding()),
          if (course.listening) ...[
            Container(
              height: dotSize,
              width: dotSize,
              decoration: BoxDecoration(
                color: _getColor('listening'),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(height: p.standardPadding() / 4),
          ],
          if (course.speaking) ...[
            Container(
              height: dotSize,
              width: dotSize,
              decoration: BoxDecoration(
                color: _getColor('speaking'),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(height: p.standardPadding() / 4),
          ],
          if (course.reading) ...[
            Container(
              height: dotSize,
              width: dotSize,
              decoration: BoxDecoration(
                color: _getColor('reading'),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(height: p.standardPadding() / 4),
          ],
          if (course.writing) ...[
            Container(
              height: dotSize,
              width: dotSize,
              decoration: BoxDecoration(
                color: _getColor('writing'),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(height: p.standardPadding() / 4),
          ],
        ],
      ),
    );
  }
}