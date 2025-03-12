import 'package:flutter/material.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/screens/home/courses.dart';
import 'package:lenski/screens/course/course_home.dart';
import 'package:lenski/screens/course/review_cards/review_screen.dart';
import 'package:lenski/screens/course/books/book_screen.dart';
import 'package:lenski/models/book_model.dart';
import 'package:lenski/screens/settings/settings_screen.dart';
import 'sidebar.dart';

/// NavigationHandler widget that manages navigation within the app
class NavigationHandler extends StatefulWidget {
  const NavigationHandler({super.key});

  @override
  NavigationHandlerState createState() => NavigationHandlerState();
}

class NavigationHandlerState extends State<NavigationHandler> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  /// Handles item selection from the sidebar
  void _onItemSelected(String item) {
    if (item == 'Home') {
      if (_navigatorKey.currentState?.canPop() == true) {
        _navigatorKey.currentState?.popUntil((route) => route.isFirst);
      }
    } else {
      final currentRoute = ModalRoute.of(context)?.settings.name;
      if (currentRoute != item) {
        _navigatorKey.currentState?.pushNamed(item);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar widget for navigation
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
                  case 'Book':
                    final args = settings.arguments as Map<String, dynamic>;
                    final book = args['book'] as Book;
                    final course = args['course'] as Course;
                    builder = (BuildContext _) => BookScreen(book: book, course: course);
                    break;
                  case 'Settings':
                    builder = (BuildContext _) => const SettingsScreen();
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