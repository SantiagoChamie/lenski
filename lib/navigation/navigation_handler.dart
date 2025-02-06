import 'package:flutter/material.dart';
import 'package:lenski/courses.dart';
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
      _navigatorKey.currentState?.pushNamedAndRemoveUntil(item, (Route<dynamic> route) => false);
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

class Item1Widget extends StatelessWidget {
  const Item1Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child:  Text(
        'Content for Item 1',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class Item2Widget extends StatelessWidget {
  const Item2Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Content for Item 2',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class Item3Widget extends StatelessWidget {
  const Item3Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Content for Item 3',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class UnknownItemWidget extends StatelessWidget {
  const UnknownItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Unknown Item',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}