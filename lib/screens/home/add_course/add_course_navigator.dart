import 'package:flutter/material.dart';
import 'package:lenski/screens/home/add_course/add_course_button.dart';
import 'package:lenski/screens/home/add_course/add_course_screen.dart';

const int animationDuration = 300;

class AddCourseNavigator extends StatefulWidget {
  final VoidCallback onToggle;

  const AddCourseNavigator({super.key, required this.onToggle});

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
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: animationDuration),
          curve: Curves.easeInOut,
          height: _isAddCourseScreenVisible ? constraints.maxHeight - 50.0 : 50.0, // Adjust the height as needed
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: (animationDuration/2).floor()),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _isAddCourseScreenVisible
                ? AddCourseScreen(key: const ValueKey(1), onBack: _toggleAddCourseScreen)
                : AddCourseButton(key: const ValueKey(2), onPressed: _toggleAddCourseScreen),
          ),
        );
      },
    );
  }
}