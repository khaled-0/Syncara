import 'dart:convert';

import 'package:objectbox/objectbox.dart';
import 'package:syncara/model/common.dart';
import 'package:syncara/model/objectbox.g.dart' as obj;

// TODO Embed type and defaultValue
enum Preference<T> {
  // Appearance
  materialYou<bool>(true),
  pitchBlack<bool>(false),
  // Auto Remember Stuff
  lastPlayed<LastPlayedMedia?>(null),
  subsLang<String>("en"),
  loopMode<int>(0), // LoopMode.off
  // Media Notification
  notifCloseButtonAction<int>(0),
  notifShowShuffle<bool>(true),
  notifShowRepeat<bool>(true),
  // Player Customization
  miniPlayerSecondaryAction<int>(0), // MiniPlayerSecondaryActions.Close
  playerBottomAppBar<bool>(true),
  // Downloader
  maxParallelDownload<int>(3),
  // Others
  inAppUpdate<bool>(true);

  final T defaultValue;

  const Preference(this.defaultValue);
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

  void put(dynamic value) {
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
  void set<T>(Preference key, T value) {
    final preference = Preferences(key.name)..put(value);
    put(preference);
  }

  void delete(Preference key) =>
      query(obj.Preferences_.key.equals(key.name)).build().remove();

  bool exists(Preference key) =>
      query(obj.Preferences_.key.equals(key.name)).build().count() != 0;

  T value<T>(Preference key) {
    return query(
          obj.Preferences_.key.equals(key.name),
        ).build().findFirst()?.get() ??
        key.defaultValue;
  }

  Stream<Query<Preferences>> watch(Preference key) =>
      query(obj.Preferences_.key.equals(key.name)).watch(
        triggerImmediately: true,
      );
}

extension PreferenceQueryExtension on Query<Preferences> {
  T value<T>(Preference key) {
    final value = findFirst();
    if (value != null) assert(value.key == key.name);
    return value?.get() ?? key.defaultValue;
  }
}
