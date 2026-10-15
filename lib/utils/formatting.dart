import 'package:flutter/widgets.dart';

/// Makes sure titles and previews start with a capital letter.
String capitalizeFirst(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

/// Joins multi-line API text into one line for short previews.
String singleLine(String text) => text.replaceAll('\n', ' ');

const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Formats a date like "Oct 15, 2026".
String formatShortDate(DateTime date) {
  return '${_months[date.month - 1]} ${date.day}, ${date.year}';
}

/// Widest the reading column gets on tablets and the web.
const double maxContentWidth = 720;

/// Side padding that keeps content at a readable width on wide screens.
EdgeInsets readablePadding(
  BuildContext context, {
  double top = 0,
  double bottom = 0,
  double minSide = 16,
}) {
  final width = MediaQuery.sizeOf(context).width;
  final side = width > maxContentWidth + minSide * 2
      ? (width - maxContentWidth) / 2
      : minSide;
  return EdgeInsets.fromLTRB(side, top, side, bottom);
}
