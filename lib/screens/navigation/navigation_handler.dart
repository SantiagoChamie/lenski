import 'package:flutter/material.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/screens/home/courses.dart';
import 'package:lenski/screens/course/course_home.dart';
import 'package:lenski/screens/course/review_cards/review_screen.dart';
import 'sidebar.dart';

class NavigationHandler extends StatefulWidget {
  const NavigationHandler({super.key});

  @override
  NavigationHandlerState createState() => NavigationHandlerState();
}

class NavigationHandlerState extends State<NavigationHandler> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

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
                switch (settings.name) {
                  case 'Home':
                    builder = (BuildContext _) => const Courses();
                    break;
                  case 'Course':
                    final course = settings.arguments as Course;
                    builder = (BuildContext _) => CourseHome(course: course);
                    break;
                  case 'Review':
                    final course = settings.arguments as Course;
                    builder = (BuildContext _) => ReviewScreen(course: course);
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