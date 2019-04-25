import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

part 'mocked_response.dart';

const _defaultMockResponseDelay = Duration(milliseconds: 200);

/// Adaptateur pour créer un mock sur [l'api DIO](https://pub.dev/packages/dio)
abstract class BaseMockAdapter extends HttpClientAdapter {
  /// Les bouchons dans une map avec :
  /// * la clé : soit l'uri qui peut être au format expression régulière. On peut
  /// préciser le type de requête (get, post,...) avec le format 'type_requête:url'.
  /// * en valeur, la réponse : [MockedResponse]
  ///
  /// Exemple de bouchon en poste pour tous les utilisateurs avec un id avec un get :
  ///
  /// ```
  /// { 'get:users/.*': MockedResponseContent(data: '{ name: "John DOE"}') }
  /// ```
  Map<String, MockedResponse> get mocks;

  /// Simule un délai de réponse.
  final Duration mockResponseDelay;

  BaseMockAdapter({this.mockResponseDelay = _defaultMockResponseDelay});

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    await Future.delayed(mockResponseDelay);

    final mockEntries = mocks.entries;
    final response = _getMockedResponseWithOptions(mockEntries, options);

    return response._computeResponse(options);
  }

  /// Retourne une fonction prédicat basée sur [options] et [path].
  bool Function(MapEntry<String, MockedResponse> entry) _finderWith(
          RequestOptions options,
          {String? path}) =>
      (MapEntry<String, MockedResponse> e) {
        /// Cherche à savoir si il y a une commande http en préfixe (avant le :)
        final pathSplitted = e.key.split(':');
        String? eMethod, ePath;
        if (pathSplitted.length > 1) {
          eMethod = pathSplitted[0];
          ePath = pathSplitted[1];
        } else {
          ePath = pathSplitted[0];
        }

        final eMethodRegExp = RegExp(eMethod ?? r'.*', caseSensitive: false);
        final ePathRegExp = RegExp(ePath);

        return eMethodRegExp.hasMatch(options.method) &&
            ePathRegExp.hasMatch(path ?? options.path);
      };

  /// Cherche le bouchon.
  /// S'il ne trouve pas dans les mock la clé calculée sur [options],
  /// il cherche par défaut la clé 'NOTFOUND'
  MockedResponse _getMockedResponseWithOptions(
          Iterable<MapEntry<String, MockedResponse>> mockEntries,
          RequestOptions options) =>
      mockEntries
          .firstWhere(_finderWith(options),
              orElse: () => mockEntries.firstWhere(
                  _finderWith(options, path: MockedResponse.notFoundPath)))
          .value;

  @override
  void close({bool force = false}) {}
}

/// Implémentation basique du BaseMockAdapter
class MockAdapter extends BaseMockAdapter {
  @override
  final Map<String, MockedResponse> mocks;

  MockAdapter(this.mocks,
      {Duration mockResponseDelay = _defaultMockResponseDelay})
      : super(mockResponseDelay: mockResponseDelay);
}

/// Permet de gérer des groupes de bouchons pour plusieurs cas
/// d'authentification.
class MultiAuthMockAdapter<T> extends BaseMockAdapter {
  /// Les bouchons disponible sans authentification.
  /// Le contenu des réponses sont de type :
  ///   * soit [MockedResponseContent] : pour une réponse classique
  ///   * soit [MockedResponseAuthContent] : indique une authentification.
  /// Il va donc utiliser les bouchons correspondants dans [mapAuthIdMocks]
  final Map<String, MockedResponse> noAuthMocks;
  T? _currentAuthId;
  final Map<String, MockedResponse> Function(T id) _mapAuthMocks;
  final void Function()? onClear;

  @override
  Map<String, MockedResponse> get mocks {
    if (_currentAuthId == null) {
      return noAuthMocks;
    }
    return _mapAuthMocks(_currentAuthId as T);
  }

  void clear() {
    _currentAuthId = null;
    if (onClear != null) onClear!();
  }

  MultiAuthMockAdapter(
      {required this.noAuthMocks,
      required Map<String, MockedResponse> Function(T id) mapAuthIdMocks,
      this.onClear,
      Duration mockResponseDelay = _defaultMockResponseDelay})
      : _mapAuthMocks = mapAuthIdMocks,
        super(mockResponseDelay: mockResponseDelay);

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    if (_currentAuthId == null) {
      final mockedResponse =
          _getMockedResponseWithOptions(noAuthMocks.entries, options);
      final mockedResponseContent = mockedResponse.performRequest(options);

      if (mockedResponseContent.status == HttpStatus.ok) {
        if (mockedResponseContent is MockedResponseAuthContent<T>) {
          _currentAuthId = mockedResponseContent
              .responseToAuthId(mockedResponseContent.data);

          return mockedResponse._computeBodyFromContent(mockedResponseContent);
        }
      }
    }
    return super.fetch(options, requestStream, cancelFuture);
  }
}
