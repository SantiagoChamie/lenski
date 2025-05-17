import 'package:flutter/material.dart';
import 'dart:async';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/models/book_model.dart';
import 'package:lenski/screens/course/books/reader/book_screen_scroll.dart';
import 'package:lenski/screens/home/courses.dart';
import 'package:lenski/screens/course/course_home.dart';
import 'package:lenski/screens/course/review_cards/review_screen.dart';
import 'package:lenski/screens/settings/settings_screen.dart';
import 'package:lenski/screens/course/archive/archive_screen.dart';
import 'sidebar.dart';

/// A widget that handles navigation within the app.
///
/// This component is responsible for managing the app's navigation structure,
/// including the sidebar and the main content area. It uses a navigator to
/// handle pushing and popping routes, and maintains state about the current
/// navigation context.
///
/// Features:
/// - Sidebar navigation with route handling
/// - Dynamic content area with route-based rendering
/// - Stream-based home navigation events for inter-component communication
/// - Support for deep-linking to specific screens
class NavigationHandler extends StatefulWidget {
  const NavigationHandler({super.key});

  @override
  NavigationHandlerState createState() => NavigationHandlerState();
}

class NavigationHandlerState extends State<NavigationHandler> {
  /// Key for the navigator to control navigation programmatically
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  
  /// The currently active route name
  String _currentRoute = 'Home';
  
  /// Stream controller for broadcasting home navigation events
  ///
  /// This controller emits events when the user navigates to the home screen,
  /// allowing other components to react to these navigation changes.
  static final StreamController<void> homeNavigationController = 
      StreamController<void>.broadcast();
  
  /// Stream of home navigation events
  ///
  /// Listen to this stream to be notified when the user navigates to the home screen.
  static Stream<void> get onHomeNavigation => homeNavigationController.stream;

  @override
  void dispose() {
    // Clean up resources when the widget is disposed
    // Note: Since this is a static controller used across the app,
    // be cautious about closing it if other parts of the app might still use it
    super.dispose();
  }

  /// Handles item selection from the sidebar.
  ///
  /// When a navigation item is selected, this method determines whether to:
  /// - Navigate to a new route
  /// - Pop back to the home screen
  /// - Broadcast a home navigation event
  ///
  /// @param item The identifier of the selected navigation item
  void _onItemSelected(String item) {
    
    if (item == 'Home') {
      // If navigating to Home, emit an event through the stream
      homeNavigationController.add(null);
      
      // If the selected item is Home, pop all routes until the first route
      if (_navigatorKey.currentState?.canPop() == true) {
        _navigatorKey.currentState?.popUntil((route) => route.isFirst);
      }
    } else if (_shouldNavigate(item)) {
      // Push the named route onto the navigator stack
      _navigatorKey.currentState?.pushNamed(item).then((_) {
        // Reset the current route when the screen is popped
        if (_currentRoute == item) {
          setState(() {
            _currentRoute = 'Home'; // Default to Home after pop
          });
        }
      });
    }
    
    setState(() {
      _currentRoute = item;
    });
  }

  /// Determines if navigation should occur based on the selected item.
  ///
  /// Navigation should only occur if the selected item is different from the current route.
  ///
  /// @param item The identifier of the selected navigation item
  /// @return True if navigation should occur, false otherwise
  bool _shouldNavigate(String item) {
    return _currentRoute != item;
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Row(
        children: [
          // Sidebar widget for navigation
          Sidebar(onItemSelected: _onItemSelected, navigatorKey: _navigatorKey),
          
          // Main content area with navigator
          Expanded(
            child: Navigator(
              key: _navigatorKey,
              onGenerateRoute: (RouteSettings settings) {
                WidgetBuilder builder;
                
                // Handle route generation based on settings name
                switch (settings.name) {
                  case 'Home':
                    builder = (BuildContext _) => const Courses();
                    break;
                    
                  case 'Course':
                    final course = settings.arguments as Course;
                    builder = (BuildContext _) => CourseHome(course: course);
                    break;
                    
                  case 'Review':
                    // Support both new map format and old direct course format
                    if (settings.arguments is Map<String, dynamic>) {
                      final args = settings.arguments as Map<String, dynamic>;
                      final course = args['course'] as Course;
                      final firstWord = args['firstWord'] as String?;
                      builder = (BuildContext _) => ReviewScreen(
                        course: course,
                        firstWord: firstWord,
                      );
                    } else {
                      // Backward compatibility for existing code
                      final course = settings.arguments as Course;
                      builder = (BuildContext _) => ReviewScreen(course: course);
                    }
                    break;
                    
                  case 'Book':
                    final args = settings.arguments as Map<String, dynamic>;
                    final book = args['book'] as Book;
                    final course = args['course'] as Course;
                    builder = (BuildContext _) => BookScreenScroll(
                      book: book,
                      course: course,
                    );
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