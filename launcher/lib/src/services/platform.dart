import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:quiver/strings.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Returns a URL that can be launched on the current platform
/// to open a maps application showing the result of a search query.
/// Returns `null` if the platform is not supported.
String? _createGeoQueryUrl(String query) {
  if (kIsWeb) {
    return Uri.encodeFull(
        'https://www.google.fr/maps/search/${query.split(' ').join('+')}');
  } else if (Platform.isAndroid) {
    return Uri.encodeFull('geo:0,0?q=$query');
  } else if (Platform.isIOS) {
    return Uri.encodeFull('https://maps.apple.com/?q=$query');
  }
  return null;
}

/// Returns a URL that can be launched on the current platform
/// to open a maps application showing coordinates ([latitude] and [longitude]).
/// Returns `null` if the platform is not supported.
String? _createGeoCoordinatesUrl(double latitude, double longitude,
    [String? label]) {
  if (kIsWeb) {
    return Uri.encodeFull('https://www.google.fr/maps/@$latitude,$longitude');
  } else if (Platform.isAndroid) {
    return Uri.encodeFull(
      'geo:0,0?q=$latitude,$longitude${label == null ? '' : '($label)'}',
    );
  } else if (Platform.isIOS) {
    if (label != null) {
      return Uri.encodeFull(
        'https://maps.apple.com/?q=$label&ll=$latitude,$longitude',
      );
    } else {
      return Uri.encodeFull('https://maps.apple.com/?sll=$latitude,$longitude');
    }
  }
  return null;
}

Future<bool> launchGeoQuery(String query) =>
    launchUrl(_createGeoQueryUrl(query)!);

Future<bool> launchGeoCoordinate(double latitude, double longitude,
        [String? label]) =>
    launchUrl(_createGeoCoordinatesUrl(latitude, longitude, label)!);

Future<bool> canLaunchGeoQuery(String query) =>
    canLaunchUrl(_createGeoQueryUrl(query)!);

Future<bool> canLaunchGeoCoordinate(double latitude, double longitude,
        [String? label]) =>
    canLaunchUrlString(_createGeoCoordinatesUrl(latitude, longitude, label)!);

String _preparePhonable(String phonable) =>
    Uri.encodeFull('tel:${phonable.replaceAll(' ', '')}');

Future<bool> launchCall(String phonable) =>
    launchUrlString(_preparePhonable(phonable));

Future<bool> canLaunchCall(String phonable) =>
    canLaunchUrlString(_preparePhonable(phonable));

Future<String> _prepareEmailUri(String email,
    {String? subject, String? body}) async {
  final sb = StringBuffer();
  sb
    ..write('mailto:')
    ..write(email);
  final other = {
    if (!isBlank(subject)) 'subject': subject,
    if (!isBlank(body)) 'body': body
  };

  if (other.isNotEmpty) {
    sb.write('?');
    sb.write(
        other.entries.map((entry) => '${entry.key}=${entry.value}').join('&'));
  }
  return Uri.encodeFull(sb.toString());
}

Future<bool> canLaunchEmail(String email,
        {String? subject, String? body}) async =>
    canLaunchUrlString(
        await _prepareEmailUri(email, subject: subject, body: body));

Future<bool> launchEmail(String email, {String? subject, String? body}) async {
  final uri = await _prepareEmailUri(email, subject: subject, body: body);
  if (await canLaunchUrlString(uri)) return launchUrlString(uri);
  return false;
}

///
/// Launch: simple url (https://xxxxx) in default web browser
///
Future<bool> canLaunchUrl(String url) async => canLaunchUrlString(url);
Future<bool> launchUrl(String url) async => launchUrlString(url);
