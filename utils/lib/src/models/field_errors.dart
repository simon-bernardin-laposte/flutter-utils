abstract class Errors {
  static const fieldRequired = 'errorFieldRequired';
  static const fieldMinLength = 'errorFieldMinLength';
  static const fieldExactLength = 'errorFieldExactLength';
  static const fieldMaxLength = 'errorFieldMaxLength';
  static const fieldMinValue = 'errorFieldMinValue';
  static const fieldMaxValue = 'errorFieldMaxValue';
  static const fieldBadFormat = 'errorFieldBadFormat';
  static const fieldOnlyAlphanum = 'errorFieldOnlyAlphaNum';
}

class FieldErrorFormatter {
  const FieldErrorFormatter();
  String formatFieldError(error,
          {int? min, int? max, int? equals, Duration? duration}) =>
      error;
}
