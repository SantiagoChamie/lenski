import 'package:flutter/material.dart';
import 'package:lenski/screens/home/add_course/add_course_button.dart';
import 'package:lenski/screens/home/add_course/add_course_screen.dart';
import 'package:lenski/utils/proportions.dart';

const int animationDuration = 300;

class AddCourseNavigator extends StatefulWidget {
  final VoidCallback onToggle;
  final bool isExpanded;

  const AddCourseNavigator({
    super.key,
    required this.onToggle,
    required this.isExpanded,
  });

  @override
  _AddCourseNavigatorState createState() => _AddCourseNavigatorState();
}

class _AddCourseNavigatorState extends State<AddCourseNavigator> {
  bool _isAddCourseScreenVisible = false;

  void _toggleAddCourseScreen() {
    setState(() {
      _isAddCourseScreenVisible = !_isAddCourseScreenVisible;
      widget.onToggle();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: animationDuration),
      height: widget.isExpanded ? p.createCourseHeight() : p.sidebarButtonWidth(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedSwitcher(
            // Set the duration to be slightly less than the parent container to avoid clipping issue
            duration: Duration(milliseconds: (animationDuration-1).floor()),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _isAddCourseScreenVisible
                ? AddCourseScreen(key: const ValueKey(1), onBack: _toggleAddCourseScreen)
                : AddCourseButton(key: const ValueKey(2), onPressed: _toggleAddCourseScreen),
          );
        },
      ),
    );
  }
}