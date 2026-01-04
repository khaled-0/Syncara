import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:syncara/app/more/downloads/active_downloads_screen.dart';
import 'package:syncara/clients/media_client.dart';
import 'package:syncara/clients/yt_media_client.dart';
import 'package:syncara/main.dart';
import 'package:syncara/model/objectbox.g.dart';
import 'package:syncara/model/preferences.dart';

import '../data/models/media.dart';

class DownloaderService {
  /// <-- Singleton
  DownloaderService._();

  static final DownloaderService _instance = DownloaderService._();

  factory DownloaderService() => _instance;

  late final Store _store;

  /// Singleton -->

  /// Must call before runApp
  static Future<void> init(Store store) async {
    DownloaderService._instance._store = store;
    final max = store.box<Preferences>().value(Preference.maxParallelDownload);

    await FileDownloader().configure(
      globalConfig: [
        // Limit concurrent downloads
        (Config.holdingQueue, (max, max, max)),
        // >100mb space available
        (Config.checkAvailableSpace, 100),
        // Use background service when possible
        (Config.runInForeground, Config.always),
      ],
    );

    // Background downloader notifications
    FileDownloader().configureNotification(
      running: const TaskNotification('Downloading', '{displayName}'),
      complete: const TaskNotification('Download finished', '{displayName}'),
      progressBar: true,
    );

    // Register notification tap handler / download listener
    FileDownloader().registerCallbacks(
      taskNotificationTapCallback: DownloaderService.notificationTapHandler,
      taskStatusCallback: DownloaderService.downloadStatusListener,
    );

    // Using the database to track Tasks
    FileDownloader().trackTasks();
  }

  bool _abortQueueing = false;

  void abortQueueing() => _abortQueueing = true;

  // TODO The links expire
  // TODO Move this process to background or notify user to not close until this finishes
  // https://pub.dev/packages/workmanager or https://pub.dev/packages/flutter_background_service
  Future<void> downloadAll(List<Media> medias) async {
    _abortQueueing = false;
    for (final (index, media) in medias.indexed) {
      try {
        // Ignore already enqueued/downloaded
        if (MediaClient().isDownloaded(media)) continue;
        final record = await FileDownloader().database.recordForId(media.url);
        if (record != null) continue;

        if (_abortQueueing) break;

        final task = DownloadTask(
          taskId: media.url,
          url: media.url,
          displayName: media.title,
          directory: MediaClient().downloadsDir,
          filename: p.basename(media.url),
          baseDirectory: BaseDirectory.root,
          updates: Updates.statusAndProgress,
          options: TaskOptions(
            onTaskStart: _fetchYTDownloadUrl,
          ),
        );

        FileDownloader().enqueue(task);

        // TODO perform this after download finishes
        // https://github.com/781flyingdutchman/background_downloader/issues/615
        final updatedMedia = media.copyWith.localPath(await task.filePath());
        updatedMedia.objectId = media.objectId;
        _store.box<Media>().putQueued(updatedMedia, mode: PutMode.update);
      } catch (e, s) {
        // TODO Error
        debugPrintStack(stackTrace: s, label: e.toString());
      }

      /// Slow down to prevent Ui hang
      if (index % 5 == 0) await Future.delayed(Durations.short2);
    }
  }

  // Future<void> cancelAll() async {
  //   FileDownloader().taskQueues.forEach(FileDownloader().removeTaskQueue);
  //   DownloaderService().abortQueueing();
  //   Iterable<TaskRecord> records = await FileDownloader().database.allRecords();
  //
  //   await FileDownloader().cancelTasksWithIds(
  //     records.map((e) => e.taskId).toList(),
  //   );
  //   await FileDownloader().database.deleteAllRecords();
  // }

  // ------ Proxy Methods -------- //

  Database get db => FileDownloader().database;

  Future<void> cancel(TaskRecord task) async {
    FileDownloader().cancelTaskWithId(task.taskId);
    FileDownloader().database.deleteRecordWithId(task.taskId);
  }

  void registerCallbacks({
    TaskStatusCallback? taskStatusCallback,
    TaskProgressCallback? taskProgressCallback,
    TaskNotificationTapCallback? taskNotificationTapCallback,
  }) {
    FileDownloader().registerCallbacks(
      taskStatusCallback: taskStatusCallback,
      taskProgressCallback: taskProgressCallback,
      taskNotificationTapCallback: taskNotificationTapCallback,
    );
  }

  void unregisterCallbacks({Function? callback}) =>
      FileDownloader().unregisterCallbacks(callback: callback);

  static Future<bool> get hasInternet => InternetConnection().hasInternetAccess;

  // ------ Static Listeners -------- //

  static void notificationTapHandler(
    Task task,
    NotificationType notificationType,
  ) {
    rootNavigator.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ActiveDownloadsScreen()),
      (route) => route.isFirst,
    );
  }

  static void downloadStatusListener(TaskStatusUpdate update) {
    switch (update.status) {
      case TaskStatus.complete:
      case TaskStatus.failed:
      case TaskStatus.notFound:
      case TaskStatus.canceled:
        FileDownloader().database.deleteRecordWithId(update.task.taskId);
        break;

      default:
        break;
    }
  }
}

extension on AudioSource {
  String get url {
    if (this is! UriAudioSource) throw "Unknown $runtimeType has no uri";
    return (this as UriAudioSource).uri.toString();
  }
}

@pragma("vm:entry-point")
Future<Task?> _fetchYTDownloadUrl(Task task) async {
  try {
    final url = (await YTMediaClient().getMediaSource(
      Media(url: task.url, title: "", author: ""),
    )).url;
    return task.copyWith(url: url);
  } catch (e, s) {
    debugPrintStack(stackTrace: s, label: e.toString());
  }
  return task.copyWith(url: "");
}

typedef DownloadRecord = TaskRecord;
typedef DownloadProgressUpdate = TaskProgressUpdate;
typedef DownloadStatusUpdate = TaskStatusUpdate;
typedef DownloadStatus = TaskStatus;
