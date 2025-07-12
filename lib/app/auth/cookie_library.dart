import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:objectbox/objectbox.dart';
import 'package:syncara/model/preferences.dart';

class CookieLibrary extends StatelessWidget {
  const CookieLibrary({super.key});

  Box<Preferences> get preference => GetIt.I<Store>().box<Preferences>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.cookie_rounded),
      title: const Text("Cookie Manager"),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            const SizedBox(height: 16),
            TextFormField(
              autofocus: false,
              maxLines: 5,
              minLines: 1,
              initialValue: preference.value<String>(Preference.cookies),
              onChanged: (value) => preference.set(Preference.cookies, value),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Youtube Cookie",
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Dismiss"),
        ),
      ],
    );
  }
}
