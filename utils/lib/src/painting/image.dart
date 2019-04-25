// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../services/cache.dart';

/// The dart:io implementation of [NetworkImage].
class NetworkDioCacheImage extends ImageProvider<NetworkImage>
    implements NetworkImage {
  /// Creates an object that fetches the image at the given URL.
  ///
  /// The arguments [url] and [scale] must not be null.
  NetworkDioCacheImage(this.url,
      {Dio? dio, this.category = 'image', this.scale = 1.0, this.headers})
      : _dio = dio ?? Dio();

  final _cacheManager = CacheManager();

  final Dio _dio;

  final String category;

  @override
  final String url;

  @override
  final double scale;

  @override
  final Map<String, String>? headers;

  @override
  Future<NetworkDioCacheImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<NetworkDioCacheImage>(this);
  }

  @override
  ImageStreamCompleter load(NetworkImage key, DecoderCallback decode) {
    // Ownership of this controller is handed off to [_loadAsync]; it is that
    // method's responsibility to close the controller's stream when the image
    // has been loaded or an error is thrown.
    final chunkEvents = StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key as NetworkDioCacheImage, chunkEvents, decode),
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
      debugLabel: key.url,
      informationCollector: () {
        return <DiagnosticsNode>[
          DiagnosticsProperty<ImageProvider>('Image provider', this),
          DiagnosticsProperty<NetworkDioCacheImage>('Image key', key),
        ];
      },
    );
  }

  Future<ui.Codec> _loadAsync(
    NetworkDioCacheImage key,
    StreamController<ImageChunkEvent> chunkEvents,
    DecoderCallback decode,
  ) async {
    final resolved = Uri.base.resolve(key.url);
    final uriStr = resolved.toString();

    try {
      assert(key == this);

      Uint8List bytes;

      try {
        chunkEvents.add(const ImageChunkEvent(
            cumulativeBytesLoaded: 0, expectedTotalBytes: 0));
        final file = await (_cacheManager.getElement(uriStr,
            category: category,
            fetcher: () => _dio.getUri(
                  resolved,
                  options: Options(
                      headers: headers, responseType: ResponseType.bytes),
                  onReceiveProgress: (count, total) {
                    chunkEvents.add(ImageChunkEvent(
                        cumulativeBytesLoaded: count,
                        expectedTotalBytes: total >= 0 ? total : null));
                  },
                ).then((response) => response.data)));
        bytes = await file.readAsBytes();
      } on DioError catch (error) {
        // The network may be only temporarily unavailable, or the file will be
        // added on the server later. Avoid having future calls to resolve
        // fail to check the network again.
        throw NetworkImageLoadException(
            statusCode:
                error.response?.statusCode ?? HttpStatus.internalServerError,
            uri: resolved);
      }

      if (bytes.lengthInBytes == 0) {
        throw Exception('NetworkDioCacheImage is an empty file: $resolved');
      }

      return await decode(bytes);
    } catch (e) {
      // Depending on where the exception was thrown, the image cache may not
      // have had a chance to track the key in the cache at all.
      // Schedule a microtask to give the cache a chance to add the key.

      scheduleMicrotask(() {
        _cacheManager.removeElement(uriStr, category: category);
        // @TODO: à remettre quand cela sera corrigé. Détecté en Flutter 2.2.1
        // PaintingBinding.instance!.imageCache!.evict(key);
      });

      chunkEvents.addError(e);
      rethrow;
    } finally {
      await chunkEvents.close();
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is NetworkDioCacheImage &&
        other.url == url &&
        other.scale == scale;
  }

  @override
  int get hashCode => ui.hashValues(url, scale);

  @override
  String toString() => '${objectRuntimeType(this, 'NetworkDioCacheImage')}'
      '("$url", scale: $scale)';
}
