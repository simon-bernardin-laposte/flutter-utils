library lp_traffic_mixpanel;

import 'package:flutter/widgets.dart';
import 'package:lp_utils/services.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:quiver/strings.dart';

part 'src/observer.dart';

/// Implémentation de [TrafficReport] pour Mixpanel
class TrafficReportMixPanel implements TrafficReport {
  late Mixpanel _mixPanel;
  final String _token;

  /// L'identifiant de l'évènement changement de l'écran
  final String screenEventId;

  /// Le nom de l'écran de la propriété changement de l'écran.
  /// Inutilisé si [suffixEventScreenName] està vrai
  final String screenPropertyName;

  /// Le nom de la propriété en entrée/sortie de l'écran
  final String screenPropertyEnter;

  /// Ajoute le nom de l'évènement en suffix de l'identifiant d'évènement
  final bool suffixEventScreenName;

  static const _defaultScreenEventId = r'screen_view';
  static const _defaultScreenPropertyName = r'name';
  static const _defaultScreenPropertyEnter = r'enter';
  static const _defaultSuffixEventScreenName = false;

  TrafficReportMixPanel(
      {required String token,
      this.screenEventId = _defaultScreenEventId,
      this.screenPropertyName = _defaultScreenPropertyName,
      this.screenPropertyEnter = _defaultScreenPropertyEnter,
      this.suffixEventScreenName = _defaultSuffixEventScreenName})
      : _token = token;

  @override
  Future<void> init() async {
    _mixPanel = await Mixpanel.init(_token, optOutTrackingDefault: false, trackAutomaticEvents: true);
    _mixPanel.setServerURL('https://api-eu.mixpanel.com');
  }

  @override
  Future<void> reconcileUserId(TrafficUserId userId) async {
    final distintId = await _mixPanel.getDistinctId();
    _mixPanel.alias(userId, distintId);
  }

  Future<String> getDistinctId() {
    return _mixPanel.getDistinctId();
  }

  Future<void> timeEvent(TrafficEventId? eventId) async {
    eventId ??= screenEventId;
    _mixPanel.timeEvent(eventId);
  }

  @override
  Future<void> setUserId(TrafficUserId userId, {TrafficUserProperties properties = const {}}) async {
    _mixPanel.identify(userId);
    await setUserProperties(properties);
  }

  @override
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    final people = _mixPanel.getPeople();

    for (final property in properties.entries) {
      people.set(property.key, property.value?.toString());
    }
  }

  @override
  Future<void> removeUserProperties(Iterable<TrafficEventPropertyId> properties) async {
    final people = _mixPanel.getPeople();

    for (final property in properties) {
      people.unset(property);
    }
  }

  @override
  Future<void> incrementUserProperty(TrafficEventPropertyId propertyId, double by) async {
    final people = _mixPanel.getPeople();

    people.increment(propertyId, by);
  }

  @override
  Future<void> track(TrafficEventId eventId, {TrafficEventProperties properties = const {}}) async {
    _mixPanel.track(eventId, properties: properties);
  }

  @override
  Future<void> flush() async {
    _mixPanel.flush();
  }

  @override
  Future<void> forgetUser() async {
    _mixPanel.reset();
  }

  @override
  Future<bool> getEnabled() async => await _mixPanel.hasOptedOutTracking() != true;

  @override
  Future<void> setEnabled(bool enabled) async {
    if (enabled) {
      _mixPanel.optInTracking();
    } else {
      _mixPanel.optOutTracking();
    }
  }

  @override
  Iterable<NavigatorObserver> navigatorObservers() => [
        MixPanelObserver(this,
            screenEventId: screenEventId,
            screenPropertyName: screenPropertyName,
            screenPropertyEnter: screenPropertyEnter,
            suffixEventScreenName: suffixEventScreenName)
      ];
}
