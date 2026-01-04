import 'package:flutter/material.dart';
import 'package:syncara/extensions.dart';
import 'package:syncara/services/downloader_service.dart';

class DownloadStatusFilters extends StatelessWidget {
  final DownloadStatus? activeFilter;
  final void Function(DownloadStatus?) onChange;

  const DownloadStatusFilters(
    this.activeFilter, {
    super.key,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsetsGeometry.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        spacing: 8,
        children: DownloadStatus.values.map((e) {
          return FilterChip(
            label: Text(e.name.normalizeCamelCase().toCapitalCase()),
            selected: e == activeFilter,
            onSelected: (value) => onChange(value ? e : null),
          );
        }).toList(),
      ),
    );
  }
}
