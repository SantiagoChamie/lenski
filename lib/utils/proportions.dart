import 'package:flutter/widgets.dart';

/// Class to calculate proportions of the screen
class Proportions {
  final BuildContext context;

  Proportions(this.context);

  double screenWidth() => MediaQuery.of(context).size.width;
  double screenHeight() => MediaQuery.of(context).size.height;

  double sidebarWidth() => 100; //screenWidth() * 0.0744;
  double sidebarButtonWidth() => 59;//screenWidth() * 0.0438;

  double standardPadding() => 20; //screenHeight() * 0.025;

  double createCourseHeight() => screenHeight() - 2 * standardPadding();
  double createCourseWidth() => screenWidth() - sidebarWidth() - 2 * standardPadding();
  double createCourseBottomHeight() => createCourseHeight()/6;
  double createCourseTopHeight() => createCourseHeight() - createCourseBottomHeight();

  double createCourseColumnWidth() => createCourseWidth()/3;
  double createCourseButtonHeight() => createCourseHeight()/12;
  double createCourseButtonWidth() => (createCourseColumnWidth()-4*standardPadding());

  // CourseButton height has parameter Quantity
  // with quantity = 3, being the maximum allowed
  double courseButtonHeight(quantity) {
    if (quantity <= 3) {
      return (screenHeight() - (3 + quantity - 1) * standardPadding() - sidebarButtonWidth()) / quantity;
    } else {
      return (screenHeight() - (3 + 3 - 1) * standardPadding() - sidebarButtonWidth()) / 3;
    }
  }
}