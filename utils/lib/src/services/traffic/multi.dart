import 'package:flutter/widgets.dart';

import 'traffic.dart';

/// Fait le proxy vers plusieurs gestionnaires d'audience
class MultiTrafficReport implements TrafficReport {
  final List<TrafficReport> _adapters;

  MultiTrafficReport(
      {Iterable<TrafficReport> adapters = const <TrafficReport>[]})
      : _adapters = adapters.toList();

  Future<void> _callAdapters(
          Future<void> Function(TrafficReport adapter) mapper) =>
      Future.wait(_adapters.map(mapper));

  @override
  Future<void> init() => _callAdapters((adapter) => adapter.init());

  @override
  Future<void> reconcileUserId(TrafficUserId userId) =>
      _callAdapters((adapter) => adapter.reconcileUserId(userId));

  @override
  Future<void> setUserId(TrafficUserId userId,
          {TrafficUserProperties properties = const {}}) =>
      _callAdapters(
          (adapter) => adapter.setUserId(userId, properties: properties));

  @override
  Future<void> setUserProperties(TrafficUserProperties properties) =>
      _callAdapters((adapter) => adapter.setUserProperties(properties));

  @override
  Future<void> removeUserProperties(
          Iterable<TrafficEventPropertyId> properties) =>
      _callAdapters((adapter) => adapter.removeUserProperties(properties));
  @override
  Future<void> incrementUserProperty(
          TrafficEventPropertyId propertyId, double by) =>
      _callAdapters((adapter) => adapter.incrementUserProperty(propertyId, by));

  @override
  Future<void> track(TrafficEventId eventId,
          {TrafficEventProperties properties = const {}}) =>
      _callAdapters(
          (adapter) => adapter.track(eventId, properties: properties));

  @override
  Future<void> flush() => _callAdapters((adapter) => adapter.flush());

  @override
  Future<void> forgetUser() => _callAdapters((adapter) => adapter.forgetUser());

  @override
  Future<bool> getEnabled() => _adapters.isEmpty
      ? Future.value(false)
      : Future.wait(_adapters.map((adapter) => adapter.getEnabled()))
          .then((result) => result.reduce((prev, cur) => prev && cur));

  @override
  Future<void> setEnabled(bool value) async {
    await _callAdapters((adapter) => adapter.setEnabled(value));
  }

  @override
  Iterable<NavigatorObserver> navigatorObservers() =>
      _adapters.expand((a) => a.navigatorObservers());
}
