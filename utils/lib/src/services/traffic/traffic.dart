import 'package:flutter/widgets.dart';

typedef TrafficUserId = String;

typedef TrafficEventId = String;
typedef TrafficEventPropertyId = String;
typedef TrafficEventProperties = Map<TrafficEventPropertyId, dynamic>;
typedef TrafficUserProperties = Map<String, dynamic>;

/// Abstrait la gestion des audiences
/// Par défaut, le tracking est désactivé afin d'avoir
/// le consentement formel le l'utilisateur (opt-in).
abstract class TrafficReport {
  /// Initialisation
  Future<void> init();

  /// Assure la réconciliationde l'identifiant.
  /// Typiquement à utiliser au moment de l'enregistrement.
  Future<void> reconcileUserId(TrafficUserId userId);

  /// Associe pour les futurs appels un identifiant unique de l'utilisateur
  /// Le paramètre [properties] est un raccourci vers [setUserProperties]
  /// Au moment de l'enregistrement de l'utilisateur (signup), privilégier
  /// [reconcileUserId]
  Future<void> setUserId(TrafficUserId userId,
      {TrafficUserProperties properties = const {}});

  /// Ajoute ou remplace les propriétés de l'utilisateur qui est identifié.
  Future<void> setUserProperties(TrafficUserProperties properties);

  /// Supprime les propriétés de l'utilisateur qui est identifié.
  Future<void> removeUserProperties(
      Iterable<TrafficEventPropertyId> properties);

  Future<void> incrementUserProperty(
      TrafficEventPropertyId propertyId, double by);

  /// Trace un évènement dans la mesure d'audience
  Future<void> track(TrafficEventId eventId,
      {TrafficEventProperties properties = const {}});

  /// Force le transfère des évènements en cache vers le serveur.
  Future<void> flush();

  /// Correspond à une déconnexion de l'utilisateur.
  /// Les données d'identification sont donc supprimées.
  Future<void> forgetUser();

  /// Retourne vrai si le tracking est actif
  Future<bool> getEnabled();

  /// Active/désactive le tracking
  Future<void> setEnabled(bool value);

  /// Observateurs pour les évènements de navigation.
  /// À fournir en paramètre des [Navigator].
  /// Rq: utiliser une instance par navigateur.
  Iterable<NavigatorObserver> navigatorObservers();
}

/// Simulation d'audience pour les mock/tests.
class FakeTrafficReport implements TrafficReport {
  const FakeTrafficReport();

  @override
  Future<void> flush() async {}

  @override
  Future<bool> getEnabled() async => false;

  @override
  Future<void> init() async {}

  @override
  Future<void> setEnabled(bool value) async {}

  @override
  Future<void> reconcileUserId(TrafficUserId userId) async {}

  @override
  Future<void> setUserId(TrafficUserId userId,
      {TrafficUserProperties properties = const {}}) async {}

  @override
  Future<void> setUserProperties(Map<String, dynamic> properties) async {}

  @override
  Future<void> removeUserProperties(
      Iterable<TrafficEventPropertyId> properties) async {}

  @override
  Future<void> incrementUserProperty(
      TrafficEventPropertyId propertyId, double by) async {}

  @override
  Future<void> track(TrafficEventId eventId,
      {TrafficEventProperties properties = const {}}) async {}

  @override
  Future<void> forgetUser() async {}

  @override
  Iterable<NavigatorObserver> navigatorObservers() =>
      const <NavigatorObserver>[];
}
