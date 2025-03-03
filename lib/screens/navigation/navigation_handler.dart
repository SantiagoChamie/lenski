import 'package:flutter/material.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/screens/home/courses.dart';
import 'package:lenski/screens/course/course_home.dart';
import 'sidebar.dart';

/// This is the main widget that handles the navigation of the app.
/// It contains a [Sidebar] and a [Navigator] widget.
/// The [Sidebar] is used to navigate between the different screens of the app.
/// The [Navigator] is used to display the content of the selected screen.

class NavigationHandler extends StatefulWidget {
  const NavigationHandler({super.key});

  @override
  NavigationHandlerState createState() => NavigationHandlerState();
}

class NavigationHandlerState extends State<NavigationHandler> {
  // Create a GlobalKey for the Navigator widget
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  // This function is called when an item is selected in the Sidebar
  void _onItemSelected(String item) {
    if (item == 'Home') {
      if (_navigatorKey.currentState?.canPop() == true) {
        _navigatorKey.currentState?.popUntil((route) => route.isFirst);
      }
    } else {
      _navigatorKey.currentState?.pushNamed(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(onItemSelected: _onItemSelected, navigatorKey: _navigatorKey),
          Expanded(
            child: Navigator(
              key: _navigatorKey,
              onGenerateRoute: (RouteSettings settings) {
                WidgetBuilder builder;
                // Check the name of the route and return the corresponding widget
                switch (settings.name) {
                  case 'Home':
                    builder = (BuildContext _) => const Courses();
                    break;
                  case 'Course':
                    final course = settings.arguments as Course;
                    builder = (BuildContext _) => CourseHome(course: course);
                    break;
                  default:
                    builder = (BuildContext _) => const Courses();
                }
                return MaterialPageRoute(builder: builder, settings: settings);
              },
            ),
          ),
        ],
      ),
    );
  }
}