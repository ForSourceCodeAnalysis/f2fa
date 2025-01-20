import 'dart:io';

import 'package:hive/hive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_storage_repository/local_storage_repository.dart';

void main() {
  late Box testBox;

  setUpAll(() async {
    // Initialize Hive
    Hive.init('./test_hive');
    // Register adapters if needed
    // Hive.registerAdapter(WebdavConfigAdapter());
    await Hive.openBox('f2faconfig');
    testBox = Hive.box('f2faconfig');
  });

  tearDownAll(() async {
    await Hive.close();
    // Delete the temporary directory
    final dir = Directory('./test_hive');
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  });

  group('WebdavConfig Tests', () {
    test('Constructor and properties', () {
      final webdavConfig = WebdavConfig(
        url: 'https://example.com',
        username: 'user',
        password: 'pass',
        encryptKey: 'key123',
      );

      expect(webdavConfig.url, equals('https://example.com'));
      expect(webdavConfig.username, equals('user'));
      expect(webdavConfig.password, equals('pass'));
      expect(webdavConfig.encryptKey, equals('key123'));
    });

    test('toJson method', () {
      final webdavConfig = WebdavConfig(
        url: 'https://example.com',
        username: 'user',
        password: 'pass',
        encryptKey: 'key123',
      );

      final json = webdavConfig.toJson();
      expect(
          json,
          equals({
            'url': 'https://example.com',
            'username': 'user',
            'password': 'pass',
            'encryptKey': 'key123',
          }));
    });

    test('fromJson method', () {
      final json = {
        'url': 'https://example.com',
        'username': 'user',
        'password': 'pass',
        'encryptKey': 'key123',
      };

      final webdavConfig = WebdavConfig.fromJson(json);
      expect(webdavConfig.url, equals('https://example.com'));
      expect(webdavConfig.username, equals('user'));
      expect(webdavConfig.password, equals('pass'));
      expect(webdavConfig.encryptKey, equals('key123'));
    });

    test('fromJson method with optional encryptKey', () {
      final json = {
        'url': 'https://example.com',
        'username': 'user',
        'password': 'pass',
      };

      final webdavConfig = WebdavConfig.fromJson(json);
      expect(webdavConfig.url, equals('https://example.com'));
      expect(webdavConfig.username, equals('user'));
      expect(webdavConfig.password, equals('pass'));
      expect(webdavConfig.encryptKey, isNull);
    });
  });

  group('LocalStorageRepository Tests', () {
    test('getInstance returns the same instance', () async {
      final instance1 = await LocalStorageRepository.getInstance();
      final instance2 = await LocalStorageRepository.getInstance();
      expect(instance1, same(instance2));
    });
    test('getInstance initializes the box correctly', () async {
      final instance = await LocalStorageRepository.getInstance();
      final box = instance.box;
      expect(box, isA<Box>());
      expect(box.name, equals('f2faconfig'));
      expect(box, same(testBox));
    });

    test('getWebdavConfig returns null when no data exists', () async {
      final instance = await LocalStorageRepository.getInstance();
      final config = instance.getWebdavConfig();
      expect(config, isNull);
    });

    test('saveWebdavConfig saves data correctly', () async {
      final webdavConfig = WebdavConfig(
        url: 'https://example.com',
        username: 'user',
        password: 'pass',
        encryptKey: 'key123',
      );
      final instance = await LocalStorageRepository.getInstance();
      instance.saveWebdavConfig(webdavConfig);
      final savedConfigJson = testBox.get(LocalStorageRepository.webdavKey);
      expect(savedConfigJson, equals(webdavConfig.toJson()));
    });

    test('getWebdavConfig returns correct data after saving', () async {
      final webdavConfig = WebdavConfig(
        url: 'https://example.com',
        username: 'user',
        password: 'pass',
        encryptKey: 'key123',
      );
      final instance = await LocalStorageRepository.getInstance();
      final config = instance.getWebdavConfig();
      expect(config, isA<WebdavConfig>());
      expect(config?.toJson(), equals(webdavConfig.toJson()));
    });
  });
}
