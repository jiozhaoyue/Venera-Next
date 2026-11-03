import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:venera_next/features/local_comics/local.dart';
import 'package:venera_next/foundation/app.dart';
import 'package:venera_next/foundation/comic_type.dart';

const _testComicType = ComicType(9001);

LocalComic _comic(String id) => LocalComic(
  id: id,
  title: 'Local $id',
  subtitle: '',
  tags: const [],
  directory: id,
  chapters: null,
  cover: 'cover.jpg',
  comicType: _testComicType,
  downloadedChapters: const [],
  createdAt: DateTime(2026, 1, 1),
);

bool _sqliteAvailable() {
  try {
    final db = sqlite3.openInMemory();
    db.dispose();
    return true;
  } catch (_) {
    return false;
  }
}

void main() {
  test(
    'missingComicIds reports only directories that no longer exist',
    () async {
      final dataDir = Directory.systemTemp.createTempSync(
        'venera-missing-data-',
      );
      final cacheDir = Directory.systemTemp.createTempSync(
        'venera-missing-cache-',
      );
      addTearDown(() {
        LocalManager.current?.dispose();
        if (dataDir.existsSync()) dataDir.deleteSync(recursive: true);
        if (cacheDir.existsSync()) cacheDir.deleteSync(recursive: true);
      });

      App.dataPath = dataDir.path;
      App.cachePath = cacheDir.path;
      LocalManager.current?.dispose();
      LocalManager(initializeSources: () async {});
      final manager = LocalManager();
      await manager.init();

      final present = _comic('present');
      final absent = _comic('absent');
      Directory(
        '${manager.path}${Platform.pathSeparator}present',
      ).createSync(recursive: true);
      await manager.add(present);
      await manager.add(absent);

      final missing = await manager.missingComicIds();

      expect(missing, {(absent.id, absent.comicType.value)});
      expect(missing.contains((present.id, present.comicType.value)), isFalse);
    },
    skip: _sqliteAvailable() ? false : 'sqlite3 native library is unavailable',
  );
}
