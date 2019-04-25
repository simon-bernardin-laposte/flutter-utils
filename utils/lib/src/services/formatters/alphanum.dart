import 'package:flutter/services.dart';

class AlphaNumInputFormatter extends FilteringTextInputFormatter {
  static final _regExp = RegExp(r'[a-zA-Z\d]');
  AlphaNumInputFormatter() : super(_regExp, allow: true);
}

class NoAccentAlphanumInputFormatter extends FilteringTextInputFormatter {
  NoAccentAlphanumInputFormatter(
      {bool hasNum = true, bool withSpace = false, String extra = ''})
      : super(
            RegExp(r'[A-Za-z' +
                (hasNum ? r'\d' : '') +
                (withSpace ? r'\s' : '') +
                extra +
                r']*'),
            allow: true);
}

class AlphanumWithSpaceInputFormatter extends FilteringTextInputFormatter {
  AlphanumWithSpaceInputFormatter(
      {bool hasNum = true, bool withSpace = true, String extra = ''})
      : super(
            RegExp(r'[A-Za-z\u00C0-\u024F' +
                (hasNum ? r'\d' : '') +
                (withSpace ? r'\s' : '') +
                extra +
                r']*'),
            allow: true);
}
