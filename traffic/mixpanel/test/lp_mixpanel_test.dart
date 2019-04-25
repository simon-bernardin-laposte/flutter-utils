import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lp_traffic_mixpanel/traffic.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mixpanel = TrafficReportMixPanel(token: 'TEST');

  const MethodChannel('mixpanel_flutter')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    // ignore: avoid_print
    print(methodCall.method);
  });

  setUpAll(() async {
    await mixpanel.init();
  });

  test('Envoi d\'un évènement', () async {
    expect(() => mixpanel.track('event_id'), prints('track\n'));
  });
}
