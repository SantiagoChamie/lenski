import 'package:flutter/material.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/screens/course/books/reader/book_screen_scroll.dart';
import 'package:lenski/screens/home/courses.dart';
import 'package:lenski/screens/course/course_home.dart';
import 'package:lenski/screens/course/review_cards/review_screen.dart';
import 'package:lenski/models/book_model.dart';
import 'package:lenski/screens/settings/settings_screen.dart';
import 'package:lenski/screens/course/archive/archive_screen.dart';
import 'sidebar.dart';

/// A widget that handles navigation within the app.
class NavigationHandler extends StatefulWidget {
  const NavigationHandler({super.key});

  @override
  NavigationHandlerState createState() => NavigationHandlerState();
}

class NavigationHandlerState extends State<NavigationHandler> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  String _currentRoute = 'Home';

  /// Handles item selection from the sidebar.
  /// Navigates to the selected route if it is different from the current route.
  void _onItemSelected(String item) {
    if (item == 'Home') {
      // If the selected item is 'Home', pop all routes until the first route.
      if (_navigatorKey.currentState?.canPop() == true) {
        _navigatorKey.currentState?.popUntil((route) => route.isFirst);
      }
    } else if (_shouldNavigate(item)) {
      // Push the named route onto the navigator stack.
      _navigatorKey.currentState?.pushNamed(item).then((_) {
        // Reset the current route when the screen is popped
        if (_currentRoute == item) {
          setState(() {
            _currentRoute = 'Home'; // Default to 'Home' after pop
          });
        }
      });
    }
    setState(() {
      _currentRoute = item;
    });
  }

  /// Determines if navigation should occur based on the selected item.
  bool _shouldNavigate(String item) {
    return _currentRoute != item;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar widget for navigation.
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
                    builder = (BuildContext _) => BookScreenScroll(book: book, course: course);
                    break;
                  case 'Settings':
                    builder = (BuildContext _) => const SettingsScreen();
                    break;
                  case 'Archive':
                    final course = settings.arguments as Course;
                    builder = (BuildContext _) => ArchiveScreen(course: course);
                    break;
                  default:
                    builder = (BuildContext _) => const Courses();
                }
                return MaterialPageRoute(
                  builder: builder,
                  settings: settings,
                  maintainState: false,
                 );
              },
            ),
          ),
        ],
      ),
    );
  }
}