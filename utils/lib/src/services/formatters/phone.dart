import 'package:flutter/services.dart';
import 'package:quiver/strings.dart';

class FrPhoneTextInputFormatter extends TextInputFormatter {
  final RegExp startWith;

  FrPhoneTextInputFormatter({required this.startWith});
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (isNotBlank(newValue.text) && !startWith.hasMatch(newValue.text)) {
      return oldValue;
    }

    final newTextLength = newValue.text.length;
    var selectionIndex = newValue.selection.end;
    var usedSubstringIndex = 0;
    final newText = StringBuffer();

    void addSpace(int from) {
      if (newTextLength >= from) {
        newText
          ..write(
              newValue.text.substring(from - 3, usedSubstringIndex = from - 1))
          ..write(' ');
        if (newValue.selection.end >= from - 1) selectionIndex++;
      }
    }

    [3, 5, 7, 9].forEach(addSpace);

    // Dump the rest.
    if (newTextLength >= usedSubstringIndex) {
      newText.write(newValue.text.substring(usedSubstringIndex));
    }
    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
