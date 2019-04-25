library lp_traffic_google_analytics;

import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';
import 'package:lp_utils/services.dart';
import 'package:quiver/strings.dart';

/// Implémentation de [TrafficReport] pour Google Analytics
class TrafficReportGoogleAnalytics implements TrafficReport {
  final String incrementUserEventPrefixName;
  final String incrementUserPropertyName;
  late final _analytics = FirebaseAnalytics.instance;

  bool _enabled;

  TrafficReportGoogleAnalytics(
      {this.incrementUserEventPrefixName = 'increment_',
      this.incrementUserPropertyName = 'value',
      bool enabled = false})
      : _enabled = enabled;

  @override
  Future<void> flush() async {}

  @override
  Future<void> forgetUser() async {
    await _analytics.resetAnalyticsData();
  }

  @override
  Future<bool> getEnabled() async => _enabled;

  @override
  Future<void> init() async {
    await setEnabled(_enabled);
  }

  @override
  Iterable<NavigatorObserver> navigatorObservers() =>
      [FirebaseAnalyticsObserver(analytics: _analytics)];

  /// Enlève les caractères spéciaux incompatibles avec Google Analytics.
  /// Utile si on combine avec une autre mesure d'audience comme MixPanel qui
  /// peut en avoir besoin.
  String _normalizePropertyKey(String key) => key.replaceAll(RegExp(r'\W'), '');

  @override
  Future<void> reconcileUserId(TrafficUserId userId) async {
    await _analytics.setUserId(id: userId);
  }

  @override
  Future<void> removeUserProperties(
      Iterable<TrafficEventPropertyId> properties) async {
    await Future.wait(properties.map(
      (property) => _analytics.setUserProperty(
          name: _normalizePropertyKey(property), value: null),
    ));
  }

  @override
  Future<void> incrementUserProperty(
      TrafficEventPropertyId propertyId, double by) async {
    await track(
        [
          if (isNotBlank(incrementUserEventPrefixName))
            incrementUserEventPrefixName,
          propertyId
        ].join('_'),
        properties: {incrementUserPropertyName: by});
  }

  @override
  Future<void> setEnabled(bool value) async {
    _enabled = value;
    await _analytics.setConsent(
        adStorageConsentGranted: false, analyticsStorageConsentGranted: value);
  }

  @override
  Future<void> setUserId(TrafficUserId userId,
      {TrafficUserProperties properties = const {}}) async {
    await _analytics.setUserId(id: userId);
    await setUserProperties(properties);
  }

  @override
  Future<void> setUserProperties(TrafficUserProperties properties) async {
    await Future.wait(properties.entries.map((property) =>
        _analytics.setUserProperty(
            name: _normalizePropertyKey(property.key),
            value: property.value?.toString())));
  }

  @override
  Future<void> track(TrafficEventId eventId,
      {TrafficEventProperties properties = const {}}) async {
    if (_enabled) {
      properties = Map.fromEntries(properties.entries.map((e) =>
          MapEntry<String, dynamic>(_normalizePropertyKey(e.key), e.value)));
      await _analytics.logEvent(name: eventId, parameters: properties);
    }
  }
}
