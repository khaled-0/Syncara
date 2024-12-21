import 'dart:convert';

import 'package:objectbox/objectbox.dart';
import 'package:tubesync/model/common.dart';
import 'package:tubesync/model/objectbox.g.dart' as obj;

// TODO Embed type and defaultValue
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
  maxParallelDownload,
  // Others
  inAppUpdate,
}

@Entity()
class Preferences {
  @Id()
  int objectId = 0;

  @Index()
  @Unique(onConflict: ConflictStrategy.replace)
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

extension PreferenceExtension on Box<Preferences> {
  void setValue<T>(Preference key, T value) {
    final preference = Preferences(key.name)..set(value);
    put(preference);
  }

  void removeValue(Preference key) =>
      query(obj.Preferences_.key.equals(key.name)).build().remove();

  bool valueExists(Preference key) =>
      query(obj.Preferences_.key.equals(key.name)).build().count() != 0;

  T? getValue<T>(Preference key, T? defaultValue) {
    return query(obj.Preferences_.key.equals(key.name))
            .build()
            .findFirst()
            ?.get() ??
        defaultValue;
  }

  Stream<Query<Preferences>> watch(Preference key) =>
      query(obj.Preferences_.key.equals(key.name)).watch(
        triggerImmediately: true,
      );
}
