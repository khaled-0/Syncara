import 'package:flutter/material.dart';

class ChoiceDialog<T> extends StatelessWidget {
  const ChoiceDialog({
    super.key,
    required this.title,
    this.icon,
    required this.options,
    this.subtitle,
    this.width = double.minPositive,
    this.selected,
  });

  final String title;
  final String? subtitle;
  final Widget? icon;
  final Map<String, T> options;
  final T? selected;
  final double width;

  @override
  Widget build(BuildContext context) {
    final keys = options.keys.toList();
    final titleAlignment =
        icon == null ? CrossAxisAlignment.start : CrossAxisAlignment.center;
    return AlertDialog(
      icon: icon,
      title: Column(crossAxisAlignment: titleAlignment, children: [
        Text(title),
        if (subtitle != null)
          Text(subtitle!, style: Theme.of(context).textTheme.titleSmall),
      ]),
      content: SizedBox(
        width: width,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: keys.length,
          itemBuilder: (context, i) {
            final value = options[keys[i]];
            if (selected == null) {
              return ListTile(
                dense: true,
                onTap: () => Navigator.pop(context, value),
                title: Text(keys[i]),
              );
            }
            return RadioListTile(
              dense: true,
              value: value,
              groupValue: selected,
              onChanged: (v) => Navigator.pop(context, v),
              title: Text(keys[i]),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
