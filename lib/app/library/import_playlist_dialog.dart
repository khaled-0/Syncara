import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tubesync/provider/library_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class ImportPlaylistDialog extends StatefulWidget {
  const ImportPlaylistDialog({super.key, this.url});

  final String? url;

  @override
  State<ImportPlaylistDialog> createState() => _ImportPlaylistDialogState();
}

class _ImportPlaylistDialogState extends State<ImportPlaylistDialog> {
  final ytClient = YoutubeExplode().playlists;
  final TextEditingController input = TextEditingController();
  bool loading = false;
  String? error;

  Future<void> tryImportPlaylist() async {
    if (loading) return;
    try {
      error = null;
      setState(() => loading = true);
      FocusManager.instance.primaryFocus?.unfocus();
      if (input.text.isEmpty) throw "Empty url!";
      await context.read<LibraryProvider>().importPlaylist(input.text.trim());
      if (mounted) Navigator.pop(context);
    } catch (e) {
      error = e.toString();
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.url != null) {
      input.text = widget.url!;
      tryImportPlaylist();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Import Playlist"),
      icon: const Icon(Icons.link_rounded),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              TextFormField(
                controller: input,
                autofocus: true,
                maxLines: 5,
                minLines: 1,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Playlist URL",
                  hintText: "https://youtu.be/playlist?list=...",
                ),
              ),
              const Card(
                margin: EdgeInsets.only(top: 12),
                elevation: 0,
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 6),
                  leading: Icon(Icons.info_rounded),
                  title: Text(
                    "Playlist must be public or unlisted.\n"
                    "Youtube Mix is currently unsupported.",
                  ),
                ),
              ),
              if (loading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              if (error != null)
                Card(
                  margin: const EdgeInsets.only(top: 12),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      error!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        if (!loading)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        if (!loading)
          FilledButton(
            onPressed: tryImportPlaylist,
            child: const Text("Import"),
          ),
      ],
    );
  }
}
