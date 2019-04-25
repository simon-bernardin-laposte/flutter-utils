part of 'mock.dart';

/// Contenue de la réponse : statut HTTP/données/headers
abstract class BaseMockedResponseContent {
  final int status;
  final Map<String, List<String>> headers;

  const BaseMockedResponseContent(
      {this.status = HttpStatus.ok,
      this.headers = const <String, List<String>>{}});

  Future<ResponseBody> _computeBodyFromContent(
      Map<String, List<String>> headers);
}

/// Contenue de la réponse : statut HTTP/données/headers
class MockedResponseContent extends BaseMockedResponseContent {
  final String data;

  const MockedResponseContent(
      {this.data = '',
      int status = HttpStatus.ok,
      Map<String, List<String>> headers = const <String, List<String>>{}})
      : super(headers: headers, status: status);

  @override
  Future<ResponseBody> _computeBodyFromContent(
      Map<String, List<String>> headers) async {
    final bytes = Stream.value(MockedResponse.computeBufferWithIsolate
        ? await compute(_computeBuffer, data)
        : await _computeBuffer(data));

    return ResponseBody(bytes, status, headers: {
      HttpHeaders.contentTypeHeader: [ContentType.json.mimeType],
      ...headers,
      ...this.headers
    });
  }
}

/// Contenue de la réponse : statut HTTP/données/headers
class MockedBytesResponseContent extends BaseMockedResponseContent {
  final Uint8List? data;

  const MockedBytesResponseContent(
      {this.data,
      int status = HttpStatus.ok,
      Map<String, List<String>> headers = const <String, List<String>>{}})
      : super(headers: headers, status: status);

  @override
  Future<ResponseBody> _computeBodyFromContent(
      Map<String, List<String>> headers) async {
    return ResponseBody(Stream.value(data!), status, headers: {
      HttpHeaders.contentTypeHeader: [ContentType.binary.mimeType],
      ...headers,
      ...this.headers
    });
  }
}

/// Réponse indiquant une authentification.
class MockedResponseAuthContent<T> extends MockedResponseContent {
  /// Transforme la réponse en authId qui sera utilisée pour
  /// la collection de bouchons.
  final T Function(String data) responseToAuthId;
  const MockedResponseAuthContent(
      {String data = '',
      int status = HttpStatus.ok,
      required this.responseToAuthId})
      : super(data: data, status: status);
}

/// La réponse mockée
class MockedResponse {
  /// Pour éviter les lag sur le mobile, on utilise les Isolate (thread)
  static bool computeBufferWithIsolate = false;

  /// Fonction qui selon les requpêtes passée en paramètre retourne
  /// un couple status/données [MockedResponseContent]
  final BaseMockedResponseContent Function(RequestOptions options)
      performRequest;

  /// Les headers applicables à l'ensemble des réponses retournée par [performRequest]
  final Map<String, List<String>> headers;

  factory MockedResponse(
          {int status = HttpStatus.ok,
          String data = '',
          Map<String, List<String>> headers =
              const <String, List<String>>{}}) =>
      MockedResponse.withOptions((_) =>
          MockedResponseContent(data: data, status: status, headers: headers));

  const MockedResponse.withOptions(this.performRequest,
      {this.headers = const <String, List<String>>{}});

  /// Clé pour désigner la réponse quand aucune autre n'est trouvée dans les bouchons.
  static const notFoundPath = 'NOTFOUND';

  Future<ResponseBody> _computeResponse(RequestOptions options) async {
    final response = performRequest(options);
    return _computeBodyFromContent(response);
  }

  Future<ResponseBody> _computeBodyFromContent(
          BaseMockedResponseContent response) =>
      response._computeBodyFromContent(headers);
}

/// Optimisation pour éviter les lags
Future<Uint8List> _computeBuffer(String data) async {
  final bytes = utf8.encode(data);
  return _ByteStream.fromBytes(bytes).toBytes();
}

/// A stream of chunks of bytes representing a single piece of data.
class _ByteStream extends StreamView<List<int>> {
  _ByteStream(Stream<List<int>> stream) : super(stream);

  /// Returns a single-subscription byte stream that will emit the given bytes
  /// in a single chunk.
  factory _ByteStream.fromBytes(List<int> bytes) =>
      _ByteStream(Stream.fromIterable([bytes]));

  /// Collects the data of this stream in a [Uint8List].
  Future<Uint8List> toBytes() {
    var completer = Completer<Uint8List>();
    var sink = ByteConversionSink.withCallback(
        (bytes) => completer.complete(Uint8List.fromList(bytes)));
    listen(sink.add,
        onError: completer.completeError,
        onDone: sink.close,
        cancelOnError: true);
    return completer.future;
  }

  /// Collect the data of this stream in a [String], decoded according to
  /// [encoding], which defaults to `UTF8`.
  Future<String> bytesToString([Encoding encoding = utf8]) =>
      encoding.decodeStream(this);

  Stream<String> toStringStream([Encoding encoding = utf8]) =>
      encoding.decoder.bind(this);
}
