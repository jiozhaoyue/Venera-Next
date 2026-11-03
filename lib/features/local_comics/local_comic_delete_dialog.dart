import 'package:flutter/material.dart';
import 'package:venera_next/components/message.dart';
import 'package:venera_next/components/pop_up_widget.dart';
import 'package:venera_next/foundation/context.dart';
import 'package:venera_next/foundation/translations.dart';
import 'package:venera_next/routing/app_navigation.dart';

import 'local.dart';

typedef LocalComicDeleteAction =
    Future<void> Function(
      List<LocalComic> comics,
      bool removeFiles,
      bool removeFavoriteAndHistory,
    );

/// Shared deletion confirmation for the local page and comic details.
Future<bool> showLocalComicDeleteDialog(
  BuildContext context,
  List<LocalComic> comics, {
  bool initialRemoveFavoriteAndHistory = true,
  bool showRemoveFilesOption = true,
  bool Function()? isCurrent,
  LocalComicDeleteAction? delete,
}) async {
  var isDeleted = false;
  await showDialog<void>(
    context: appNavigation.rootContext,
    builder: (context) {
      var removeComicFile = true;
      var removeFavoriteAndHistory = initialRemoveFavoriteAndHistory;
      return StatefulBuilder(
        builder: (context, setState) {
          return ContentDialog(
            title: "Delete".tl,
            content: Column(
              children: [
                CheckboxListTile(
                  title: Text("Remove local favorite and history".tl),
                  value: removeFavoriteAndHistory,
                  onChanged: (v) {
                    setState(() {
                      removeFavoriteAndHistory = !removeFavoriteAndHistory;
                    });
                  },
                ),
                if (showRemoveFilesOption)
                  CheckboxListTile(
                    title: Text("Also remove files on disk".tl),
                    value: removeComicFile,
                    onChanged: (v) {
                      setState(() {
                        removeComicFile = !removeComicFile;
                      });
                    },
                  ),
              ],
            ),
            actions: [
              if (comics.length == 1 && comics.first.hasChapters)
                TextButton(
                  child: Text("Delete Chapters".tl),
                  onPressed: () {
                    if (isCurrent?.call() == false) {
                      context.pop();
                      return;
                    }
                    context.pop();
                    showDeleteChaptersPopWindow(context, comics.first);
                  },
                ),
              FilledButton(
                onPressed: () async {
                  if (isCurrent?.call() == false) {
                    context.pop();
                    return;
                  }
                  try {
                    await (delete ??
                        (comics, removeFiles, removeFavoriteAndHistory) =>
                            LocalManager().batchDeleteComics(
                              comics,
                              removeFiles,
                              removeFavoriteAndHistory,
                            ))(
                      comics,
                      removeComicFile,
                      removeFavoriteAndHistory,
                    );
                    isDeleted = true;
                    if (context.mounted) context.pop();
                  } catch (error) {
                    if (context.mounted) {
                      context.showMessage(message: error.toString().tl);
                    }
                  }
                },
                child: Text("Confirm".tl),
              ),
            ],
          );
        },
      );
    },
  );
  return isDeleted;
}

void showDeleteChaptersPopWindow(BuildContext context, LocalComic comic) {
  var chapters = <String>[];

  showPopUpWidget(
    context,
    PopUpWidgetScaffold(
      title: "Delete Chapters".tl,
      body: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: comic.downloadedChapters.length,
                  itemBuilder: (context, index) {
                    var id = comic.downloadedChapters[index];
                    var chapter = comic.chapters![id] ?? "Unknown Chapter";
                    return CheckboxListTile(
                      title: Text(chapter),
                      value: chapters.contains(id),
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            chapters.add(id);
                          } else {
                            chapters.remove(id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FilledButton(
                      onPressed: () async {
                        try {
                          await LocalManager().deleteComicChapters(
                            comic,
                            chapters,
                          );
                          if (context.mounted) context.pop();
                        } catch (error) {
                          if (context.mounted) {
                            context.showMessage(message: error.toString().tl);
                          }
                        }
                      },
                      child: Text("Submit".tl),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}
