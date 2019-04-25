import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lp_utils/services.dart';
import 'package:sembast/sembast_memory.dart';

void main() async {
  late CacheManager cacheManager;

  setUpAll(() async {
    CacheManager.configureCacheManager(
        cacheBaseDirectory: Directory.systemTemp.createTempSync(),
        database: databaseFactoryMemory.openDatabase('main.db'),
        filesCachedByCategory: 3);

    cacheManager = CacheManager();
    await cacheManager.init(); // Le await n'est pas obligatoire
  });

  Future<File?> _getAndTestElement(String id) async {
    final fileItem = await cacheManager.getElement(id,
        fetcher: () async => Uint8List.fromList([0]));

    expect(cacheManager.hasElement(id), true);

    expect(
        await cacheManager.getElement(id,
            fetcher: () async => Uint8List.fromList([0])),
        fileItem);

    return fileItem;
  }

  test('Création instantanée', () async {
    Future<File?> getItem() => cacheManager.getElement('item',
        fetcher: () async => Uint8List.fromList([0]));
    final item = getItem();

    // L'élement doit être de suite disponible
    expect(cacheManager.hasElement('item'), true);

    final itemBis = getItem();

    expect(await item, await itemBis);
  });

  test('Ajout premier élément dans le cache', () async {
    expect(cacheManager.hasElement('item1'), false);

    final item1 = await (_getAndTestElement('item1'));
    final item2 = await (_getAndTestElement('item2'));
    final item3 = await (_getAndTestElement('item3'));
    final item4 = await (_getAndTestElement('item4'));

    expect(item1 != item2, true);

    // On fait en sorte que le deuxième élément est accédé
    // en dernier. C'est lui qui devrait être donc supprimé.
    await _getAndTestElement('item1');

    await cacheManager.init();

    expect(item1?.existsSync(), true);
    expect(item2?.existsSync(), false);
    expect(item3?.existsSync(), true);
    expect(item4?.existsSync(), true);
  });
}
