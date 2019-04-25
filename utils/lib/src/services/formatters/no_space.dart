import 'package:flutter/services.dart';

class NoSpaceInputFormatter extends FilteringTextInputFormatter {
  NoSpaceInputFormatter() : super(RegExp(r'[^\s]'), allow: true);
}
