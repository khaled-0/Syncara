import 'package:flutter_test/flutter_test.dart';
import 'package:tubesync/clients/in_app_update_client.dart';

void main() {
  test("NightlyVersionMatcher", () {
    expect(InAppUpdateClient.nightlyRegex.hasMatch("0.6.9"), false);
    expect(InAppUpdateClient.nightlyRegex.hasMatch("0.6.9-90da5fe"), true);
    expect(InAppUpdateClient.nightlyRegex.firstMatch("0.6.9")?[1], null);
    expect(
      InAppUpdateClient.nightlyRegex.firstMatch("0.6.9-90da5fe")?[1],
      "90da5fe",
    );
  });

  test("NightlyUpdateChecker", () async {
    expect(await InAppUpdateClient.checkNightlyUpdate("34fde1f"), isNotEmpty);
  });

  test("NightlyChangeLog", () async {
    expect(
      await InAppUpdateClient.fetchNightlyChangelog("4513580", "506df1d"),
      "- ci: Compress Uploaded Artifacts by 9x\n"
      "- feat: Add Nightly Updates [Android] , Add Tests\n"
      "- ci: Attach Commit Hash to All Nightly Platform Version",
    );
  });
}
