import 'package:flutter/material.dart';

import 'clock.dart';

/// Retourn le jour de la date passée en paramètre [datetime].
/// Si le paramètre [datetime] est omis, il prend la date du jour.
DateTime getDate([DateTime? datetime]) {
  datetime ??= clock.now();
  return DateTime(datetime.year, datetime.month, datetime.day);
}

TimeOfDay computeTimeOfDay(TimeOfDay time, int timeStep) {
  return TimeOfDay(
      hour: time.hour, minute: (time.minute ~/ timeStep) * timeStep);
}
