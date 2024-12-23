import 'package:flutter/material.dart';
import 'package:syncara/app/more/downloads/download_entry_builder.dart';
import 'package:syncara/main.dart';
import 'package:syncara/services/downloader_service.dart';

class ActiveDownloadsScreen extends StatefulWidget {
  const ActiveDownloadsScreen({super.key});

  @override
  State<ActiveDownloadsScreen> createState() => _ActiveDownloadsScreenState();

  static void showEnqueuedSnackbar(BuildContext context) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: const Text("Downloading....."),
        action: SnackBarAction(
          label: "View",
          onPressed: () => rootNavigator.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const ActiveDownloadsScreen()),
            (route) => route.isFirst,
          ),
        ),
      ),
    );
  }
}

class _ActiveDownloadsScreenState extends State<ActiveDownloadsScreen> {
  @override
  void initState() {
    super.initState();
    DownloaderService().registerCallbacks(
      taskProgressCallback: taskProgressCallback,
      taskStatusCallback: taskStatusCallback,
    );
  }

  @override
  void dispose() {
    super.dispose();
    DownloaderService().unregisterCallbacks(callback: taskProgressCallback);
    DownloaderService().unregisterCallbacks(callback: taskStatusCallback);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Active Downloads")),
      floatingActionButton: FutureBuilder(
        future: DownloaderService().db.allRecords(),
        initialData: [],
        builder: (context, snapshot) {
          if (snapshot.hasError) return const SizedBox();
          if (snapshot.requireData.isEmpty) return const SizedBox();
          return FloatingActionButton.extended(
            icon: const Icon(Icons.clear_all_rounded),
            label: const Text("Cancel All"),
            onPressed: () => DownloaderService().cancelAll().whenComplete(() {
              setState(() {});
            }),
          );
        },
      ),
      body: FutureBuilder<List<DownloadRecord>>(
        future: DownloaderService().db.allRecords(),
        initialData: [],
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          if (snapshot.requireData.isEmpty) {
            return Center(
              child: Text(
                "No Active Downloads!",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data?.length ?? 0,
            padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight * 2),
            itemBuilder: (context, index) {
              final entry = snapshot.requireData[index];
              return DownloadEntryBuilder(
                key: ValueKey(entry.hashCode),
                index: index,
                entry: entry,
              );
            },
          );
        },
      ),
    );
  }

  void taskProgressCallback(DownloadProgressUpdate _) => setState(() {});

  void taskStatusCallback(DownloadStatusUpdate update) {
    switch (update.status) {
      case DownloadStatus.complete:
      case DownloadStatus.failed:
      case DownloadStatus.notFound:
      case DownloadStatus.canceled:
        DownloaderService()
            .db
            .deleteRecordWithId(update.task.taskId)
            .whenComplete(() => setState(() {}));
        break;

      default:
        setState(() {});
        break;
    }
  }
}
