import 'package:flutter/widgets.dart';

abstract final class Breakpoints {
  static const double compact = 600;
  static const double medium = 840;
  static const double expanded = 1200;

  static double widthOf(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static bool isCompact(BuildContext context) => widthOf(context) < compact;

  static bool isMedium(BuildContext context) {
    final width = widthOf(context);
    return width >= compact && width < medium;
  }

  static bool isExpanded(BuildContext context) {
    final width = widthOf(context);
    return width >= medium && width < expanded;
  }

  static bool isLarge(BuildContext context) =>
      widthOf(context) >= expanded;

  static bool usesNavigationRail(BuildContext context) =>
      widthOf(context) >= medium;

  static bool usesNavigationRailLabels(BuildContext context) =>
      widthOf(context) >= expanded;
}
