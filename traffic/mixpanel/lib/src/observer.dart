part of '../traffic.dart';

class MixPanelObserver extends NavigatorObserver {
  final TrafficReportMixPanel _mixPanel;

  final String screenEventId;
  final String screenPropertyName;
  final String screenPropertyEnter;

  final bool suffixEventScreenName;

  MixPanelObserver(this._mixPanel,
      {required this.screenEventId,
      required this.screenPropertyName,
      required this.screenPropertyEnter,
      required this.suffixEventScreenName});

  Future<void> track(String? screenName, {required bool enter, TrafficEventProperties properties = const {}}) async {
    var newScreenEventId = screenEventId;

    if (suffixEventScreenName && isNotBlank(screenName)) {
      newScreenEventId = '${newScreenEventId}_$screenName';
    }

    // Le nom d'écran peut être null
    if (isNotBlank(screenName)) {
      await _mixPanel.track(newScreenEventId, properties: {
        if (!suffixEventScreenName) screenPropertyName: screenName,
        screenPropertyEnter: enter,
        ...properties
      });
    }
  }

  Future<void> timeEvent(TrafficEventId? eventId) async {
    await _mixPanel.timeEvent(eventId);
  }

  Future<void> incrementUserProperty(TrafficEventPropertyId propertyId, double by) async {
    await _mixPanel.incrementUserProperty(propertyId, by);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    track(route.settings.name, enter: false);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    track(route.settings.name, enter: true);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (newRoute != null) {
      track(newRoute.settings.name, enter: true);
    }
  }
}
