abstract class Warnings {
  static const fieldRequired = 'WarningFieldRequired';
}

class FieldWarningFormatter {
  const FieldWarningFormatter();
  String formatWarning(warning,
          {int? min, int? max, int? equals, Duration? duration}) =>
      warning;
}
