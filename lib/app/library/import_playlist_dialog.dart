import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncara/provider/library_provider.dart';
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

  Future<void> launchMusicDirectoryPicker() async {
    FilePicker.platform.getDirectoryPath().then((value) {
      if (value == null || !mounted) return;
      context.read<LibraryProvider>().importLocalPlaylist(Directory(value));
      Navigator.pop(context);
    });
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
              Row(
                spacing: 6,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: input,
                      maxLines: 5,
                      minLines: 1,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: "Playlist URL",
                        hintText: "https://youtu.be/playlist?list=...",
                        errorText: error,
                        errorMaxLines: 4,
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(8),
                          child: ValueListenableBuilder(
                            valueListenable: input,
                            builder: (context, value, spinner) {
                              final disabled = value.text.isEmpty || loading;
                              if (loading) return spinner!;
                              return IconButton.filledTonal(
                                onPressed: disabled ? null : tryImportPlaylist,
                                icon: const Icon(Icons.check_rounded),
                              );
                            },
                            child: const CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Card(
                margin: const EdgeInsets.only(top: 12),
                elevation: 0,
                child: ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  leading: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xffff0033),
                    ),
                    child: const Padding(
                      padding: EdgeInsetsGeometry.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: Icon(Icons.play_arrow_rounded),
                    ),
                  ),
                  title: const Text(
                    "Playlist must be public or unlisted.\n"
                    "Youtube Mix is currently unsupported.",
                  ),
                ),
              ),

              const Divider(endIndent: 32, indent: 32, height: 28),

              Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: const Icon(Icons.folder_copy_rounded),
                  trailing: const Chip(
                    label: Text("Pick"),
                    avatar: Icon(Icons.open_in_new_rounded),
                  ),
                  onTap: launchMusicDirectoryPicker,
                  title: const Text("Local Directory"),
                  subtitle: const Text("Bring your own music"),
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
      ],
    );
  }
}
