import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

class InAppUpdateClient {
  static const repo = "khaled-0/TubeSync";
  @visibleForTesting
  static final nightlyRegex = RegExp(r"-([a-z0-9]{7})");

  static Future<void> checkAndNotify(
    BuildContext context, {
    void Function(String err)? onError,
  }) async {
    try {
      final currentVersion = (await PackageInfo.fromPlatform()).version;
      final commit = nightlyRegex.firstMatch(currentVersion)?[1];

      if (commit != null) {
        final nightlyChangesAndCommit = await checkNightlyUpdate(commit);
        if (!context.mounted) return;
        showUpdateDialog(
          context,
          nightlyChangesAndCommit.$1,
          nightlyDiff: (commit, nightlyChangesAndCommit.$2),
        );
      } else {
        final changes = await _checkReleaseUpdate();
        if (!context.mounted) return;
        showUpdateDialog(context, changes);
      }
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  static Future<String> _checkReleaseUpdate() async {
    final url = Uri.parse('https://api.github.com/repos/$repo/releases/latest');
    final response = await http.get(url);
    if (response.statusCode != 200) throw response.body;

    final Map<String, dynamic> releaseInfo = jsonDecode(response.body);
    final String latestVersion = releaseInfo['tag_name'];

    final currentVersion = (await PackageInfo.fromPlatform()).version;
    if (currentVersion.compareTo(latestVersion) >= 0) {
      throw "Already on latest release!";
    }

    final String changelog = releaseInfo["body"];
    return changelog;
  }

  @visibleForTesting
  static Future<(String, String)> checkNightlyUpdate(String commit) async {
    final url = Uri.parse(
      'https://api.github.com/repos/$repo/actions/runs'
      '?branch=main&status=success&per_page=1&exclude_pull_requests=true',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) throw response.body;

    final Map<String, dynamic> data = jsonDecode(response.body);
    final List<dynamic> workflowRuns = data['workflow_runs'];

    if (workflowRuns.isEmpty) throw "No new update found!";
    final Map<String, dynamic> firstRun = workflowRuns[0];
    String latestCommit =
        firstRun['head_commit']['id'].substring(0, commit.length);

    // Has new update
    if (commit.compareTo(latestCommit) >= 0) {
      final String title = firstRun['display_title'];
      return (title, latestCommit);
    }

    throw "No new update found!";
  }

  static Future<String> fetchNightlyChangelog(String from, String to) async {
    final url = Uri.parse(
      'https://api.github.com/repos/$repo/'
      'compare/$from...$to',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) throw response.body;

    Map<String, dynamic> jsonData = jsonDecode(response.body);

    // Extract commit messages
    final List<String> commitMessages = [];
    for (var commit in jsonData['commits']) {
      commitMessages.add(commit['commit']['message']);
    }

    // Markdown formatted
    return "- ${commitMessages.join("\n- ")}";
  }

  static void showUpdateDialog(
    BuildContext context,
    String changelog, {
    (String, String)? nightlyDiff,
  }) {
    showDialog(
      useRootNavigator: true,
      useSafeArea: true,
      context: context,
      builder: (context) => _InAppUpdateDialog(
        changelog,
        nightlyDiff: nightlyDiff,
      ),
    );
  }
}

class _InAppUpdateDialog extends StatefulWidget {
  const _InAppUpdateDialog(this.changelog, {this.nightlyDiff});

  final String changelog;
  final (String, String)? nightlyDiff;

  @override
  State<_InAppUpdateDialog> createState() => _InAppUpdateDialogState();
}

class _InAppUpdateDialogState extends State<_InAppUpdateDialog> {
  late String changelog = widget.changelog;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.nightlyDiff != null) {
      changelog += "\n\n### [Fetch full changelog](#_nightly-changes)";
    }
  }

  void onTapLink(String text, String? href, String title) async {
    if (href == "#_nightly-changes") {
      try {
        if (widget.nightlyDiff == null) throw "Something went wrong";
        setState(() => loading = true);
        final changes = await InAppUpdateClient.fetchNightlyChangelog(
          widget.nightlyDiff!.$1,
          widget.nightlyDiff!.$2,
        );
        changelog = changes;
      } catch (err) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err.toString())),
        );
      } finally {
        if (mounted) setState(() => loading = false);
      }
    }
    if (href != null) launchUrlString(href);
  }

  String get title {
    String title = "A new update";
    if (widget.nightlyDiff != null) title = "🦉[NIGHTLY] $title";
    return title;
  }

  void launchUpdateUrl() {
    const repo = InAppUpdateClient.repo;

    if (widget.nightlyDiff != null) {
      launchUrlString("https://nightly.link/$repo/workflows/nightly/main");
    } else {
      launchUrlString("https://github.com/$repo/releases/latest");
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AlertDialog(
        title: Text(title),
        content: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          width: MediaQuery.of(context).size.width * 0.8,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Markdown(
                  data: changelog,
                  onTapLink: onTapLink,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
              if (loading) ...{
                const Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                ),
              },
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: launchUpdateUrl,
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
}
