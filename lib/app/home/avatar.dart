import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';
import 'package:syncara/app/auth/auth_dialog.dart';

class Avatar extends StatelessWidget {
  final double radius;

  const Avatar({super.key, this.radius = 16});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => AuthDialog.show(context),
      borderRadius: BorderRadius.circular(radius),
      child: CircleAvatar(
        radius: radius,
        child: Consumer<InternetStatus>(
          child: const Icon(Icons.person_rounded),
          builder: (context, internet, avatar) {
            final crossFadeState = switch (internet) {
              InternetStatus.connected => CrossFadeState.showFirst,
              InternetStatus.disconnected => CrossFadeState.showSecond,
            };
            return AnimatedCrossFade(
              firstChild: avatar!,
              secondChild: const Icon(Icons.cloud_off_rounded),
              crossFadeState: crossFadeState,
              duration: Durations.medium4,
            );
          },
        ),
      ),
    );
  }
}
