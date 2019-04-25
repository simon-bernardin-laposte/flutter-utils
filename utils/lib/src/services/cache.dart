import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:sembast/sembast.dart';

typedef CacheManagerFetcher = Future<Uint8List> Function();

/// Permet de garder en cache des objets indéfiniment par rapport à une quantité
/// et une categorie.
class CacheManager {
  static late CacheManager _instance;

  CacheManager._({
    required Directory cacheBaseDirectory,
    required Future<Database> database,
    String cacheManagerStoreKey = 'cacheManager',
    this.filesCachedByCategory = 100,
  })  : _cacheBaseDirectory = cacheBaseDirectory,
        _db = database,
        _mapCategoryIdsRecord = StoreRef<String, dynamic>(cacheManagerStoreKey)
            .record('categoryIds');
  factory CacheManager() => _instance;

  /// Configure le cache manager. Doit être appelé avant [init].
  static void configureCacheManager({
    required Directory cacheBaseDirectory,
    required Future<Database> database,
    String cacheManagerStoreKey = 'cacheManager',
    int filesCachedByCategory = 100,
  }) {
    _instance = CacheManager._(
        cacheBaseDirectory: cacheBaseDirectory,
        database: database,
        cacheManagerStoreKey: cacheManagerStoreKey,
        filesCachedByCategory: filesCachedByCategory);
  }

  final int filesCachedByCategory;
  final Directory _cacheBaseDirectory;
  final Future<Database> _db;
  final RecordRef<String, dynamic> _mapCategoryIdsRecord;

  late Completer _initCompleter;

  final _memoryCache = <String, Map<String, Future<File>>>{};

  static const _defaultCacheCategory = '_default';

  Map<String?, List<String>>? _mapCategoryIdsValue;
  Future<Map<String?, List<String>>> get _mapCategoryIds async {
    if (_mapCategoryIdsValue == null) {
      final db = await _db;
      _mapCategoryIdsValue = await _mapCategoryIdsRecord.get(db).then((m) {
        if (m == null) return {};

        return Map.fromEntries(m.entries.map<MapEntry<String, List<String>>>(
            (e) => MapEntry<String, List<String>>(
                e.key, List<String>.from(e.value))));
      });
    }
    return _mapCategoryIdsValue!;
  }

  /// Initialisation à lancer avant tout utilisation. Elle purge tous les
  /// fichiers qui ne sont plus référencés par le cache (la suppression n'étant
  /// pas immédiate),
  /// Il est recommandé de la lancer au démarrage de l'application.
  /// Doit être appelé après [configureCacheManager]
  Future<void> init() async {
    _initCompleter = Completer();
    final db = await _db;
    final mapCategoryIds = await (_mapCategoryIds);
    dynamic error;
    StackTrace? stackTrace;

    for (final entryCategory in mapCategoryIds.entries) {
      final values = entryCategory.value;

      if (values.length > filesCachedByCategory) {
        mapCategoryIds[entryCategory.key] =
            values.take(filesCachedByCategory).toList();

        final toDelete =
            values.sublist(0, values.length - filesCachedByCategory);

        await Future.wait(toDelete.map((id) async {
          final file = _getFile(category: entryCategory.key, id: id);
          if (file.existsSync()) {
            try {
              await file.delete();
              mapCategoryIds[entryCategory.key]!.remove(id);
            } catch (e, s) {
              error ??= e; // A priori l'erreur sera tj du même type
              stackTrace ??= s;
              unawaited(Future.error(error, stackTrace));
            }
          }
        }));
        await _mapCategoryIdsRecord.put(db, mapCategoryIds);
      }
    }

    if (!_initCompleter.isCompleted) _initCompleter.complete();
  }

  /// Retourne vrai si l'élément est déjà présent. Si [category] n'est pas
  /// mentionnée, alors une catégorie par défaut est attribuée.
  bool hasElement(String id, {String? category}) {
    category ??= _defaultCacheCategory;
    return _getCategory(category).containsKey(id);
  }

  /// Retourne l'élément présent ou non dans le cache.
  /// Si l'élément est absent du cache, [fetcher] est appelé s'il est utlisé.
  ///
  Future<File> getElement(String id,
      {required CacheManagerFetcher fetcher, String? category}) {
    category ??= _defaultCacheCategory;

    return _getCategory(category).putIfAbsent(id, () async {
      var file = _getFile(id: id, category: category);

      final data = await fetcher();

      if (!_cacheBaseDirectory.existsSync()) {
        _cacheBaseDirectory.createSync(recursive: true);
      }

      return file.writeAsBytes(data);
    }).then((file) async {
      final db = await _db;
      final mapCategoryIds = await _mapCategoryIds;
      final categoryIds =
          mapCategoryIds.putIfAbsent(category, () => <String>[]);

      categoryIds.remove(id); // pour assurer l'unicité
      // et doit être en dernier => le plus récemment utilisé
      categoryIds.add(id);
      await _mapCategoryIdsRecord.put(db, mapCategoryIds);

      return file;
    });
  }

  /// Supprime l'élément du cache.
  Future<void> removeElement(String id, {String? category}) async {
    final db = await _db;
    final mapCategoryIds = await _mapCategoryIds;

    if (!mapCategoryIds.containsKey(category)) return;
    final categoryIds = mapCategoryIds[category];

    categoryIds?.remove(id);
    await _mapCategoryIdsRecord.put(db, mapCategoryIds);
  }

  File _getFile({
    String? category,
    required String id,
  }) =>
      File(path.join(_cacheBaseDirectory.path, '$category-${id.hashCode}'));

  Map<String, Future<File>> _getCategory(String category) =>
      _memoryCache.putIfAbsent(category, () => <String, Future<File>>{});
}
