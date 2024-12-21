import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

class InAppUpdateClient {
  static const repo = "khaled-0/TubeSync";

  /// Returns changelog if update available. else null
  static Future<String?> checkFromGitHub() async {
    final url = Uri.parse('https://api.github.com/repos/$repo/releases/latest');
    final response = await http.get(url);
    // We're treating errors as no update.
    if (response.statusCode != 200) return null;

    final Map<String, dynamic> releaseInfo = json.decode(response.body);
    final String latestVersion = releaseInfo['tag_name'];

    final currentVersion = (await PackageInfo.fromPlatform()).version;
    if (currentVersion.compareTo(latestVersion) >= 0) return null;

    final String changelog = releaseInfo["body"];
    return changelog;
  }

  static void showUpdateDialog(BuildContext context, String changelog) {
    showDialog(
      useRootNavigator: true,
      useSafeArea: true,
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("A new update!"),
        content: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
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
            onPressed: () => launchUrlString(
              "https://github.com/$repo/releases/latest",
            ),
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
}
