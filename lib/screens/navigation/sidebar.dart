import 'package:flutter/material.dart';
import 'package:lenski/utils/colors.dart';
import 'package:lenski/utils/proportions.dart';

/// A sidebar navigation component that provides access to main app sections.
///
/// The sidebar displays a vertical column of navigation buttons and the app logo.
/// It handles navigation through callbacks to the parent widget.
///
/// Features:
/// - App logo that navigates to home when clicked
/// - Navigation buttons with customizable icons and destinations
/// - Responsive sizing based on screen dimensions
class Sidebar extends StatelessWidget {
  /// Callback function triggered when a navigation item is selected
  final Function(String) onItemSelected;

  /// Key for the navigator state to manage navigation
  final GlobalKey<NavigatorState> navigatorKey;

  /// Creates a sidebar navigation component
  ///
  /// Requires [onItemSelected] callback to handle navigation events
  /// and [navigatorKey] for navigation state management
  const Sidebar({
    required this.onItemSelected,
    required this.navigatorKey,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);

    return Container(
      width: p.sidebarWidth(),
      color: AppColors.lightGrey,
      child: Column(
        children: [
          // Logo at the top, now clickable
          GestureDetector(
            onTap: () => onItemSelected('Home'),
            child: const SizedBox(
              height: 100,
              child: Center(
                child: Image(
                  image: AssetImage('assets/icon.png'),
                  width: 33,
                  height: 33,
                ),
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
                _buildMenuButton(
                  p,
                  'Settings',
                  Icons.settings_rounded,
                  context,
                ),
                const SizedBox(height: 20), // Add some space between buttons
                _buildMenuButton(
                  p,
                  'Home',
                  Icons.home_rounded,
                  context,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a menu button for the sidebar with consistent styling.
  ///
  /// @param p The proportions object for responsive sizing
  /// @param title The title/identifier of the navigation destination
  /// @param icon The icon to display on the button
  /// @param context The build context for localizations
  /// @return A styled IconButton widget
  Widget _buildMenuButton(Proportions p, String title, IconData icon, BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: AppColors.black,
        size: p.sidebarButtonWidth() / 2,
      ),
      onPressed: () {
        onItemSelected(title);
      },
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        fixedSize: Size(p.sidebarButtonWidth(), p.sidebarButtonWidth()),
      ),
    );
  }
}