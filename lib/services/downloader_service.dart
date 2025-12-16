import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:syncara/app/more/downloads/active_downloads_screen.dart';
import 'package:syncara/clients/media_client.dart';
import 'package:syncara/main.dart';
import 'package:syncara/model/objectbox.g.dart';
import 'package:syncara/model/preferences.dart';

import '../data/models/media.dart';

class DownloaderService {
  /// <-- Singleton
  DownloaderService._();

  static final DownloaderService _instance = DownloaderService._();

  factory DownloaderService() => _instance;

  /// Singleton -->
  /// Must call before runApp
  static Future<void> init(Store store) async {
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
  Future<void> download(Media media) async {
    try {
      if (MediaClient().isDownloaded(media)) return;
      final url = (await MediaClient().getMediaSource(media)).url;
      final task = ParallelDownloadTask(
        url: url,
        displayName: media.title,
        directory: MediaClient().downloadsDir,
        filename: p.basename(media.url),
        baseDirectory: BaseDirectory.root,
        updates: Updates.statusAndProgress,
      );

      await FileDownloader().enqueue(task);
    } catch (_) {
      //TODO Error
    }
  }

  // TODO The links expire
  // TODO Move this process to background or notify user to not close until this finishes
  // https://pub.dev/packages/workmanager or https://pub.dev/packages/flutter_background_service
  Future<void> downloadAll(List<Media> medias) async {
    _abortQueueing = false;
    for (final media in medias) {
      try {
        // Ignore already enqueued/downloaded
        if (MediaClient().isDownloaded(media)) continue;
        final record = await FileDownloader().database.recordForId(media.url);
        if (record != null) continue;

        if (_abortQueueing) break;

        final url = (await MediaClient().getMediaSource(media)).url;
        FileDownloader().enqueue(
          ParallelDownloadTask(
            taskId: media.url,
            url: url,
            displayName: media.title,
            directory: MediaClient().downloadsDir,
            filename: p.basename(media.url),
            baseDirectory: BaseDirectory.root,
            updates: Updates.statusAndProgress,
          ),
        );
      } catch (_) {
        // TODO Error
      }
    }
  }

  Future<void> cancelAll() async {
    FileDownloader().taskQueues.forEach(FileDownloader().removeTaskQueue);
    DownloaderService().abortQueueing();
    Iterable<TaskRecord> records = await FileDownloader().database.allRecords();

    await FileDownloader().cancelTasksWithIds(
      records.map((e) => e.taskId).toList(),
    );
    await FileDownloader().database.deleteAllRecords();
  }

  // ------ Proxy Methods -------- //

  Database get db => FileDownloader().database;

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

typedef DownloadRecord = TaskRecord;
typedef DownloadProgressUpdate = TaskProgressUpdate;
typedef DownloadStatusUpdate = TaskStatusUpdate;
typedef DownloadStatus = TaskStatus;
