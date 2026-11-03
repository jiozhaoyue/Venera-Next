import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venera_next/features/comic_source/models.dart';
import 'package:venera_next/features/local_comics/local.dart';
import 'package:venera_next/features/local_comics/local_comic_delete_dialog.dart';
import 'package:venera_next/foundation/comic_type.dart';
import 'package:venera_next/routing/app_navigation.dart';

const _type = ComicType(9001);

LocalComic _comic({ComicChapters? chapters}) => LocalComic(
  id: 'comic',
  title: 'Comic',
  subtitle: '',
  tags: const [],
  directory: 'comic',
  chapters: chapters,
  cover: 'cover.jpg',
  comicType: _type,
  downloadedChapters: const [],
  createdAt: DateTime(2026, 1, 1),
);

Widget _host(Widget child) => MaterialApp(
  navigatorKey: appNavigation.rootNavigatorKey,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('local defaults keep files and favorite removal enabled', (
    tester,
  ) async {
    List<Object?>? call;
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showLocalComicDeleteDialog(
              context,
              [_comic()],
              delete: (comics, removeFiles, removeFavoriteAndHistory) async {
                call = [comics, removeFiles, removeFavoriteAndHistory];
              },
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Remove local favorite and history'), findsOneWidget);
    expect(find.text('Also remove files on disk'), findsOneWidget);

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(call, isNotNull);
    expect(call![1], isTrue);
    expect(call![2], isTrue);
  });

  testWidgets('detail defaults keep favorites and always remove files', (
    tester,
  ) async {
    List<Object?>? call;
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showLocalComicDeleteDialog(
              context,
              [_comic()],
              initialRemoveFavoriteAndHistory: false,
              showRemoveFilesOption: false,
              delete: (comics, removeFiles, removeFavoriteAndHistory) async {
                call = [comics, removeFiles, removeFavoriteAndHistory];
              },
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Remove local favorite and history'), findsOneWidget);
    expect(find.text('Also remove files on disk'), findsNothing);

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(call, isNotNull);
    expect(call![1], isTrue);
    expect(call![2], isFalse);
  });

  testWidgets('chapter deletion is offered only for chaptered comics', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showLocalComicDeleteDialog(
              context,
              [
                _comic(chapters: const ComicChapters({'a': 'A'})),
              ],
              delete: (comics, removeFiles, removeFavoriteAndHistory) async {},
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Delete Chapters'), findsOneWidget);
  });
}
