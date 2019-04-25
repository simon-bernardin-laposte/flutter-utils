import 'dart:async';

import 'package:equatable/equatable.dart';

typedef PaginationPageConsumer<T> = FutureOr<PaginationPage<T>> Function(
    int offset);

typedef PaginationConfigurationErrorHandler<T> = void Function(
    Object error, StackTrace stackTrace);

class PaginationConfiguration {
  final int threshold;

  final PaginationConfigurationErrorHandler? errorHandler;

  PaginationConfiguration({this.threshold = 100, this.errorHandler});
}

/// [Pagination] porte les informations de pagination:
/// * [list] : la liste des éléments paginés.
/// * [count] : le nombre d'éléments de la liste
/// * [total] : le nombre total d'éléments
///
/// [Pagination] contient plusieurs page. [PaginationPage] correspond à une
/// seule page.
class Pagination<T> extends Equatable {
  static PaginationConfiguration _configuration = PaginationConfiguration();
  static void configure(
      {int threshold = 100,
      PaginationConfigurationErrorHandler? errorHandler}) {
    _configuration = PaginationConfiguration(
        threshold: threshold, errorHandler: errorHandler);
  }

  const Pagination({required this.list, int? total, int? count})
      : assert(total == null || total >= 0),
        total = total ?? list.length,
        count = count ?? list.length;

  final Iterable<T> list;
  final int total;
  final int count;

  bool get hasNext => count < total;
  bool get complete => !hasNext;

  @override
  List<Object> get props => [list, total, count];
}

/// [consimePagination] consomme la totalité de la pagination.
/// Chaque élément du flux retourné correspond à la liste d'éléménts qui se
/// complète au fur et à mesure.
Stream<Pagination<T>> consumePagination<T>(
    FutureOr<PaginationPage<T>> Function(int offset) consumer) async* {
  var offset = 0;
  Pagination<T>? pagination;

  do {
    var pp = await consumer(offset);
    offset = pp.offset + pp.limit;
    final previousList = pagination?.list ?? [];
    final currentCount = pagination?.count ?? 0;
    pagination = Pagination(
        list: [...previousList, ...pp.list],
        count: currentCount + pp.count,
        total: pp.total);
    yield pagination;
  } while (pagination.hasNext);
}

/// Flux de pagination qui se complète au fur et à mesure que
/// [consumeNextIfNecessary] est appelé.
class PaginationConsumerStream<T> {
  final _paginationStream = StreamController<PaginationConsumer<T>>();
  int _offsetLastThreshold = 0;
  bool _callingService = false;
  final int threshold;

  PaginationConsumer<T>? _value;

  PaginationConsumerStream(Future<PaginationConsumer<T>> consumer,
      {int? threshold})
      : threshold = threshold ?? Pagination._configuration.threshold {
    consumer.then(_add).catchError((error, stackTrace) {
      _paginationStream.addError(error, stackTrace);
    });
    _stream = _paginationStream.stream;
    final errorhandler = Pagination._configuration.errorHandler;
    if (errorhandler != null) _stream = _stream.handleError(errorhandler);
  }

  late Stream<Pagination<T>> _stream;

  void close() {
    if (!_paginationStream.isClosed) _paginationStream.close();
  }

  bool get isClosed => _paginationStream.isClosed;

  void _add(PaginationConsumer<T> event) {
    _value = event;
    _paginationStream.add(event);
    if (!event.hasNext) {
      if (!_paginationStream.isClosed) _paginationStream.close();
    }
  }

  /// Délenche la consommation des suivants
  /// À placer directement dans le [build] d'un [Widget]
  Future<void> consumeNextIfNecessary(int offset) async {
    // On abandonne s'il y a un appel de service,
    // il sera évalué au prochain build.
    if (_callingService) return;

    final last = _value;
    if (last == null || !last.hasNext) return;

    if (offset > _offsetLastThreshold) {
      _offsetLastThreshold = offset + threshold;
    }

    if (last.offset < _offsetLastThreshold) {
      try {
        _callingService = true;
        if (!_paginationStream.isClosed) _add(await last.consumeNext());
      } catch (error, stackTrace) {
        _paginationStream.addError(error, stackTrace);
      } finally {
        _callingService = false;
      }
    }
  }

  Stream<Pagination<T>> get stream => _stream;
}

/// Classe qui consomme la pagination. Elle porte les informations de
/// pagination en cours qui sera consommée par [PaginationConsumerStream] et
/// [consumeNextIfNecessary].
/// Pour initialiser cette classe, il faut utiliser le constructeur
/// [init] qui prend en paramètre la fonction qui retroune les éléments selon
/// l'[offset]
class PaginationConsumer<T> extends Pagination<T> {
  final int limit;
  final int offset;

  final PaginationPageConsumer<T> _consumer;

  static Future<PaginationConsumer<T>> init<T>(
      PaginationPageConsumer<T> consumer) async {
    final result = await consumer(0);
    return PaginationConsumer._(
        list: result.list,
        total: result.total,
        limit: result.limit,
        offset: result.offset,
        consumer: consumer);
  }

  Future<PaginationConsumer<T>> consumeNext() async {
    if (complete) return this;
    final result = await _consumer(offset + limit);
    return PaginationConsumer._(
        list: [...list, ...result.list],
        total: result.total,
        limit: result.limit,
        offset: result.offset,
        consumer: _consumer);
  }

  const PaginationConsumer._(
      {required PaginationPageConsumer<T> consumer,
      int? total,
      required Iterable<T> list,
      this.limit = 0,
      this.offset = 0})
      : assert(offset >= 0),
        assert(total == null || total >= 0),
        assert(limit >= 0),
        _consumer = consumer,
        super(list: list, total: total);

  @override
  List<Object> get props => [...super.props, _consumer];
}

/// [PaginationPage] porte une seule de page de pagination. Cet objet est
/// retourné par la fonction qui appel le web service.
class PaginationPage<T> extends Equatable {
  final Iterable<T> list;

  final int limit;
  final int offset;

  final int total;
  final int count;

  const PaginationPage(
      {required this.list,
      required this.offset,
      int? count,
      required this.total,
      required this.limit})
      : assert(offset >= 0),
        assert(total >= 0),
        assert(limit >= 0),
        count = count ?? list.length;

  @override
  List<Object> get props => [list, offset, count, total, limit];
}
