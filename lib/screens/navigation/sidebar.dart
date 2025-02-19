import 'package:flutter/material.dart';
import 'package:lenski/utils/proportions.dart';

/// Sidebar widget
class Sidebar extends StatelessWidget {
  final Function(String) onItemSelected;
  final GlobalKey<NavigatorState> navigatorKey;

  const Sidebar({required this.onItemSelected, required this.navigatorKey, super.key});

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);

    return Container(
      width: p.sidebarWidth(),
      color: const Color(0xFFF5F0F6),
      child: Column(
        children: [
          // Logo at the top
          const SizedBox(
            height: 100,
            child: Center(
              child: Image(
                image: AssetImage('assets/icon.png'),
                width: 33,
                height: 33,
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.all(p.standardPadding()),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, 
              // Sidebar buttons
              children: [
                _buildMenuButton(p, 'Home', Icons.home_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Button for the sidebar
  Widget _buildMenuButton(Proportions p, String title, IconData icon) {
    return IconButton(
      icon: Icon(icon, color: Colors.black, size: p.sidebarButtonWidth() / 2),
      onPressed: () {
        onItemSelected(title);
      },
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFD9D0DB), // Button color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Square appearance
        ),
        fixedSize: Size(p.sidebarButtonWidth(), p.sidebarButtonWidth()), // Ensure the button is square
      ),
    );
  }
}