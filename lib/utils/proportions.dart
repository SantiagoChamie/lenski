import 'package:flutter/widgets.dart';

/// Class to calculate proportions of the screen
class Proportions {
  final BuildContext context;

  Proportions(this.context);

  double screenWidth() => MediaQuery.of(context).size.width;
  double screenHeight() => MediaQuery.of(context).size.height;

  double width(double ratio) => screenWidth() * ratio;
  double height(double ratio) => screenHeight() * ratio;

  double sidebarWidth() => 100; //screenWidth() * 0.0744;
  double sidebarButtonWidth() => 59;//screenWidth() * 0.0438;

  double standardPadding() => 20; //screenHeight() * 0.025;
}