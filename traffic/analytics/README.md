# lp_traffic_google_analytics

Ce plugin implémente l'usage TrafficReport avec Google Analytics

# Utilisation

Ajouter la dépendance dans `pubspec.yaml` :

```yaml
dependencies:
  lp_traffic_google_analytics:
    git:
      path: traffic/analytics
      ref: 1.0.0
      url: https://github.com/devobs/flutter-utils
```

Ensuite à l'initialisation de l'application :

```dart
main() async {
    final analytics = TrafficReportGoogleAnalytics('TOKEN_ID');

    await analytics.init();

    analytics.track('Démarrage application');
}
```