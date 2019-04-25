import 'package:flutter/services.dart';

class IntegerInputFormatter extends FilteringTextInputFormatter {
  IntegerInputFormatter() : super(RegExp(r'[\d]'), allow: true);
}
