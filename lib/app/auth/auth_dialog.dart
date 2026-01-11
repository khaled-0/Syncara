import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../model/objectbox.g.dart';

class AuthDialog extends StatefulWidget {
  static void show(BuildContext context) => showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isDismissible: false,
    isScrollControlled: true,
    useSafeArea: true,
    enableDrag: false,
    builder: (_) => Provider.value(
      value: context.read<Store>(),
      child: const AuthDialog(),
    ),
  );

  const AuthDialog({super.key});

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  late final store = context.read<Store>();
  late final WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(Uri.parse("https://m.youtube.com"));

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      children: [
        Expanded(
          child: Card.outlined(
            margin: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
            child: WebViewWidget(controller: controller),
          ),
        ),
      ],
    );
  }
}
