import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lenski/screens/home/add_course/add_course_button.dart';
import 'package:lenski/screens/home/add_course/add_course_screen.dart';
import 'package:lenski/utils/proportions.dart';

/// The duration of the animation in milliseconds when toggling between views.
const int animationDuration = 300;

/// A widget that manages navigation between the add course button and the add course screen.
///
/// This component handles the transition animation and state management when:
/// - Expanding from a simple add button to the full course creation interface
/// - Collapsing back to the add button when creation is complete or canceled
///
/// Features:
/// - Smooth animated transitions between states
/// - Keyboard shortcut support (space bar or 'n' key to toggle)
/// - Responsive sizing based on parent container constraints
/// - Synchronization with parent expansion state
class AddCourseNavigator extends StatefulWidget {
  /// Callback function triggered when the add course screen is toggled
  final VoidCallback onToggle;
  
  /// Whether the navigator is currently expanded to show the add course screen
  final bool isExpanded;

  /// Creates an AddCourseNavigator widget.
  /// 
  /// [onToggle] is the callback function to be called when the add course screen is toggled.
  /// [isExpanded] indicates whether the add course screen is expanded or not.
  const AddCourseNavigator({
    super.key,
    required this.onToggle,
    required this.isExpanded,
  });

  @override
  _AddCourseNavigatorState createState() => _AddCourseNavigatorState();
}

class _AddCourseNavigatorState extends State<AddCourseNavigator> {
  /// Whether the add course screen is currently visible
  bool _isAddCourseScreenVisible = false;
  
  /// Focus node for capturing keyboard events
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    
    // Request focus when widget initializes to enable keyboard shortcuts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyboardFocusNode.requestFocus();
    });
  }
  
  @override
  void dispose() {
    _keyboardFocusNode.dispose(); // Clean up resources when widget is removed
    super.dispose();
  }

  @override
  void didUpdateWidget(AddCourseNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If parent widget collapsed but we're still showing the add course screen,
    // update our local state to match the parent state
    if (!widget.isExpanded && _isAddCourseScreenVisible) {
      setState(() {
        _isAddCourseScreenVisible = false;
      });
    }
  }

  /// Toggles the visibility of the add course screen.
  /// 
  /// This method:
  /// 1. Updates the local visibility state
  /// 2. Notifies the parent through the onToggle callback
  /// 3. Triggers the animation between the two states
  void _toggleAddCourseScreen() {
    setState(() {
      _isAddCourseScreenVisible = !_isAddCourseScreenVisible;
      widget.onToggle();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    
    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      onKeyEvent: (KeyEvent event) {
        // Only process key down events to avoid duplicate triggers
        if (event is KeyDownEvent) {
          // Make sure no text field is currently focused to avoid
          // interference with typing in input fields
          final currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild == null) {
            // Toggle on space bar press
            if (event.logicalKey == LogicalKeyboardKey.space) {
              _toggleAddCourseScreen();
            }
            // Toggle on 'n' key press (mnemonic for "new course")
            else if (event.logicalKey == LogicalKeyboardKey.keyN) {
              _toggleAddCourseScreen();
            }
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: animationDuration),
        height: widget.isExpanded ? p.createCourseHeight() : p.sidebarButtonWidth(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return AnimatedSwitcher(
              // Set the duration slightly less than the parent container to avoid clipping
              duration: Duration(milliseconds: (animationDuration - 1).floor()),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _isAddCourseScreenVisible
                  ? AddCourseScreen(key: const ValueKey(1), onBack: _toggleAddCourseScreen)
                  : AddCourseButton(
                      key: const ValueKey(2),
                      onPressed: _toggleAddCourseScreen,
                    ),
            );
          },
        ),
      ),
    );
  }
}