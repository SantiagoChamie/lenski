import 'package:flutter/widgets.dart';

/// Class to calculate proportions of the screen
class Proportions {
  final BuildContext context;

  Proportions(this.context);

  /// Returns the width of the screen.
  double screenWidth() => MediaQuery.of(context).size.width;

  /// Returns the height of the screen.
  double screenHeight() => MediaQuery.of(context).size.height;

  /// Returns the width of the main screen excluding the sidebar.
  double mainScreenWidth() => screenWidth() - sidebarWidth();

  /// Returns the width of the sidebar.
  double sidebarWidth() => 100; // Fixed width for the sidebar

  /// Returns the width of the sidebar button.
  double sidebarButtonWidth() => 59; // Fixed width for the sidebar button

  /// Returns the standard padding value.
  double standardPadding() => 20; // Fixed padding value

  /// Returns the height of the create course screen.
  double createCourseHeight() => screenHeight() - 2 * standardPadding();

  /// Returns the width of the create course screen.
  double createCourseWidth() => screenWidth() - sidebarWidth() - 2 * standardPadding();

  /// Returns the height of the bottom section of the create course screen.
  double createCourseBottomHeight() => createCourseHeight() / 6;

  /// Returns the height of the top section of the create course screen.
  double createCourseTopHeight() => createCourseHeight() - createCourseBottomHeight();

  /// Returns the width of a column in the create course screen.
  double createCourseColumnWidth() => createCourseWidth() / 3;

  /// Returns the height of a button in the create course screen.
  double createCourseButtonHeight() => createCourseHeight() / 12;

  /// Returns the width of a button in the create course screen.
  double createCourseButtonWidth() => createCourseColumnWidth() - 4 * standardPadding();

  /// Returns the height of the library screen.
  double libraryHeight() => screenHeight() - 2 * standardPadding() - 100;

  /// Returns the width of the library screen.
  double libraryWidth() => (mainScreenWidth() - 2 * standardPadding() - sidebarWidth()) / 2;

  /// Returns the width of a book in the library screen.
  double bookWidth() => libraryWidth() / 3 - 4 * standardPadding();

  /// Returns the width of the reading widget in the book screen.
  double textWidth() => createCourseWidth()*0.75; // Fixed width for the text

  /// Returns the height of a course button based on the quantity.
  /// The maximum allowed quantity is 3.
  double courseButtonHeight(int quantity) {
    if (quantity <= 3) {
      return (screenHeight() - (3 + quantity - 1) * standardPadding() - sidebarButtonWidth()) / quantity;
    } else {
      return (screenHeight() - (3 + 3 - 1) * standardPadding() - sidebarButtonWidth()) / 3;
    }
  }
}