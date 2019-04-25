import 'package:quiver/strings.dart';

String capitalize(String s) =>
    isBlank(s) ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

String makeOneLine(String s) => s.replaceAll(RegExp(r'\s'), '\u00A0');
