import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lp_traffic_google_analytics/traffic.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final analytics = TrafficReportGoogleAnalytics();

  const MethodChannel('plugins.flutter.io/firebase_analytics')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    // ignore: avoid_print
    print(methodCall.method);
  });

  // @TODO : dans la version 9.0.4, impossible de tester, le plugin ne gère
  // pas de version mockée
  setUpAll(() async {
    await analytics.init();
    await analytics.setEnabled(true);
  });

  test('Envoi d\'un évènement', () {
    expect(() => analytics.track('event_id'), prints('logEvent\n'));
  });
}
