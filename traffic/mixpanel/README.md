# lp_mixpanel

Ce plugin implémente l'usage TrafficReport avec MixPanel

# Utilisation

Ajouter la dépendance dans `pubspec.yaml` :

```yaml
dependencies:
  lp_traffic_mixpanel:
    git:
      path: traffic/mixpanel
      ref: 1.0.0
      url: https://github.com/devobs/flutter-utils
```

Ensuite à l'initialisation de l'application :

```dart
main() async {
    final mixpanel = TrafficReportMixPanel('TOKEN_ID');

    await mixpanel.init();

    mixpanel.track('Démarrage application');
}
```