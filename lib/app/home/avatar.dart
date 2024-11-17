import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';

class Avatar extends StatelessWidget {
  final double radius;
  final VoidCallback? onTap;

  const Avatar({super.key, this.radius = 16, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
