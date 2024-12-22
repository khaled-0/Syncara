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
  static const _nightlyBadge = "[NIGHTLY]🦉";

  /// Returns changelog if update available. else null
  static Future<String?> checkFromGitHub() async {
    final currentVersion = (await PackageInfo.fromPlatform()).version;
    final commit = nightlyRegex.firstMatch(currentVersion)?[1];
    if (commit != null) return await checkNightlyUpdate(commit);
    return await _checkReleaseUpdate();
  }

  static Future<String?> _checkReleaseUpdate() async {
    final url = Uri.parse('https://api.github.com/repos/$repo/releases/latest');
    final response = await http.get(url);
    // We're treating errors as no update.
    if (response.statusCode != 200) return null;

    final Map<String, dynamic> releaseInfo = jsonDecode(response.body);
    final String latestVersion = releaseInfo['tag_name'];

    final currentVersion = (await PackageInfo.fromPlatform()).version;
    if (currentVersion.compareTo(latestVersion) >= 0) return null;

    final String changelog = releaseInfo["body"];
    return changelog;
  }

  @visibleForTesting
  static Future<String?> checkNightlyUpdate(String commit) async {
    final url = Uri.parse(
      'https://api.github.com/repos/$repo/actions/runs'
      '?branch=main&status=success&per_page=1&exclude_pull_requests=true',
    );

    final response = await http.get(url);
    // We're treating errors as no update.
    if (response.statusCode != 200) return null;

    final Map<String, dynamic> data = jsonDecode(response.body);
    final List<dynamic> workflowRuns = data['workflow_runs'];

    if (workflowRuns.isEmpty) return null;
    final Map<String, dynamic> firstRun = workflowRuns[0];
    final String latestCommit = firstRun['head_commit']['id'];

    // Has no new update
    if (commit.compareTo(latestCommit.substring(0, commit.length)) >= 0) {
      return null;
    }

    // TODO: Somehow pull full changelogs
    final String title = firstRun['display_title'];
    return "$_nightlyBadge $title";
  }

  static void showUpdateDialog(BuildContext context, String changelog) {
    bool isNightly = changelog.startsWith(_nightlyBadge);
    showDialog(
      useRootNavigator: true,
      useSafeArea: true,
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("A new update!"),
        content: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          width: MediaQuery.of(context).size.width * 0.8,
          child: Markdown(
            data: changelog,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (isNightly) {
                launchUrlString(
                  "https://nightly.link/$repo/workflows/nightly/main",
                );
              } else {
                launchUrlString(
                  "https://github.com/$repo/releases/latest",
                );
              }
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
}
