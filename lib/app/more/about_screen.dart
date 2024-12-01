import "package:flutter/material.dart";
import "package:package_info_plus/package_info_plus.dart";
import "package:url_launcher/url_launcher_string.dart";

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About"),
      ),
      body: Center(
        child: FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }
            if (!snapshot.hasData) return const CircularProgressIndicator();

            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/tubesync.png",
                    height: 80,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "TubeSync",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    "v${snapshot.requireData.version}",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Licenced under the GNU General Public Licence v3.0",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextButton.icon(
                    onPressed: () => showLicensePage(context: context),
                    icon: const Icon(Icons.chrome_reader_mode_rounded),
                    label: const Text("Open Source Licences"),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                        onPressed: () => launchUrlString(
                          "https://github.com/khaled-0/TubeSync",
                        ),
                        icon: const Icon(Icons.code_rounded),
                        label: const Text("GitHub"),
                      ),
                      TextButton.icon(
                        onPressed: () => launchUrlString(
                          "https://khaled.is-a.dev",
                        ),
                        icon: const Icon(Icons.copyright_rounded),
                        label: const Text("Khaled"),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
