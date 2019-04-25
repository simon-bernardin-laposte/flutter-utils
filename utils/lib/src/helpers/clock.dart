import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:quiver/time.dart';

late Clock _clock;
var _initialized = false;

/// Configure l'horloge (pour les tests par exemple). Si [force] est à false, il ne
/// le configure qu'au premier appel. Si [force] est à true, il reconfigure clock.
/// Si [timeFunc] ou [time] ne sont pas spéficiés, alors il prend l'heure courante
///
void initClock(
    {TimeFunction timeFunc = systemTime, DateTime? time, bool force = false}) {
  if (force || !_initialized) {
    _initialized = true;
    if (time != null) {
      _clock = Clock.fixed(time);
    } else {
      _clock = Clock(timeFunc);
    }
  }
}

Clock get clock {
  initClock();
  return _clock;
}

@visibleForTesting
Future<T> callWithClock<T>(
    {required FutureOr<T> Function() action,
    TimeFunction timeFunc = systemTime,
    DateTime? time}) async {
  var oldClock = clock;
  try {
    initClock(timeFunc: timeFunc, time: time, force: true);
    return await action();
  } finally {
    _clock = oldClock;
  }
}
