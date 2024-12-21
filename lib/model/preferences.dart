import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:tubesync/model/common.dart';

part 'preferences.g.dart';

enum Preference {
  // Appearance
  materialYou,
  // Auto Remember Stuff
  lastPlayed,
  subsLang,
  loopMode,
  // Media Notification
  notifShowShuffle,
  notifShowRepeat,
  // Player Customization
  miniPlayerSecondaryAction,
  // Downloader
  maxParallelDownload
}

@Collection()
class Preferences {
  @Id()
  final String key;

  String? stringValue;
  int? intValue;
  double? doubleValue;
  bool? boolValue;

  String? jsonValue;

  Preferences(this.key);

  void set(dynamic value) {
    switch (value.runtimeType) {
      case const (String):
        stringValue = value;
        break;
      case const (int):
        intValue = value;
        break;
      case const (double):
        doubleValue = value;
        break;
      case const (bool):
        boolValue = value;
        break;
      default:
        jsonValue = jsonEncode(value);
        break;
    }
  }

  T? get<T>() {
    if (jsonValue != null) return _fromJson<T>(jsonDecode(jsonValue!));
    return (stringValue ?? intValue ?? doubleValue ?? boolValue) as T?;
  }

  T _fromJson<T>(Map<String, dynamic> value) {
    switch (T) {
      case const (LastPlayedMedia):
        return LastPlayedMedia.fromJson(value) as T;

      default:
        throw UnimplementedError("$T is not defined");
    }
  }
}

extension PreferenceExtension on IsarCollection<String, Preferences> {
  void setValue<T>(Preference key, T value) {
    final preference = Preferences(key.name)..set(value);
    isar.write((db) => db.preferences.put(preference));
  }

  void remove(Preference key) => isar.write(
        (isar) => isar.preferences.where().keyEqualTo(key.name).deleteFirst(),
      );

  bool valueExists(Preference key) =>
      !isar.preferences.where().keyEqualTo(key.name).isEmpty();

  T? getValue<T>(Preference key, T? defaultValue) {
    return get(key.name)?.get<T>() ?? defaultValue;
  }

  Stream<Preferences?> watch(Preference key) =>
      watchObject(key.name, fireImmediately: true);
}
