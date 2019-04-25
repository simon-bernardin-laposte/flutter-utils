import 'package:flutter/services.dart';

class UpperCaseInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
        text: newValue.text.toUpperCase(),
        composing: newValue.composing,
        selection: newValue.selection);
  }
}
