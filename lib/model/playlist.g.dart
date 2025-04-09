// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PlaylistCWProxy {
  Playlist id(String id);

  Playlist title(String title);

  Playlist author(String author);

  Playlist thumbnailStd(String thumbnailStd);

  Playlist thumbnailMax(String thumbnailMax);

  Playlist videoCount(int videoCount);

  Playlist description(String? description);

  Playlist videoIds(List<String> videoIds);

  Playlist customTitle(String? customTitle);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Playlist(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Playlist(...).copyWith(id: 12, name: "My name")
  /// ````
  Playlist call({
    String id,
    String title,
    String author,
    String thumbnailStd,
    String thumbnailMax,
    int videoCount,
    String? description,
    List<String> videoIds,
    String? customTitle,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPlaylist.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPlaylist.copyWith.fieldName(...)`
class _$PlaylistCWProxyImpl implements _$PlaylistCWProxy {
  const _$PlaylistCWProxyImpl(this._value);

  final Playlist _value;

  @override
  Playlist id(String id) => this(id: id);

  @override
  Playlist title(String title) => this(title: title);

  @override
  Playlist author(String author) => this(author: author);

  @override
  Playlist thumbnailStd(String thumbnailStd) =>
      this(thumbnailStd: thumbnailStd);

  @override
  Playlist thumbnailMax(String thumbnailMax) =>
      this(thumbnailMax: thumbnailMax);

  @override
  Playlist videoCount(int videoCount) => this(videoCount: videoCount);

  @override
  Playlist description(String? description) => this(description: description);

  @override
  Playlist videoIds(List<String> videoIds) => this(videoIds: videoIds);

  @override
  Playlist customTitle(String? customTitle) => this(customTitle: customTitle);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Playlist(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Playlist(...).copyWith(id: 12, name: "My name")
  /// ````
  Playlist call({
    Object? id = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? author = const $CopyWithPlaceholder(),
    Object? thumbnailStd = const $CopyWithPlaceholder(),
    Object? thumbnailMax = const $CopyWithPlaceholder(),
    Object? videoCount = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? videoIds = const $CopyWithPlaceholder(),
    Object? customTitle = const $CopyWithPlaceholder(),
  }) {
    return Playlist(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      author: author == const $CopyWithPlaceholder()
          ? _value.author
          // ignore: cast_nullable_to_non_nullable
          : author as String,
      thumbnailStd: thumbnailStd == const $CopyWithPlaceholder()
          ? _value.thumbnailStd
          // ignore: cast_nullable_to_non_nullable
          : thumbnailStd as String,
      thumbnailMax: thumbnailMax == const $CopyWithPlaceholder()
          ? _value.thumbnailMax
          // ignore: cast_nullable_to_non_nullable
          : thumbnailMax as String,
      videoCount: videoCount == const $CopyWithPlaceholder()
          ? _value.videoCount
          // ignore: cast_nullable_to_non_nullable
          : videoCount as int,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
      videoIds: videoIds == const $CopyWithPlaceholder()
          ? _value.videoIds
          // ignore: cast_nullable_to_non_nullable
          : videoIds as List<String>,
      customTitle: customTitle == const $CopyWithPlaceholder()
          ? _value.customTitle
          // ignore: cast_nullable_to_non_nullable
          : customTitle as String?,
    );
  }
}

extension $PlaylistCopyWith on Playlist {
  /// Returns a callable class that can be used as follows: `instanceOfPlaylist.copyWith(...)` or like so:`instanceOfPlaylist.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PlaylistCWProxy get copyWith => _$PlaylistCWProxyImpl(this);

  /// Copies the object with the specific fields set to `null`. If you pass `false` as a parameter, nothing will be done and it will be ignored. Don't do it. Prefer `copyWith(field: null)` or `Playlist(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Playlist(...).copyWithNull(firstField: true, secondField: true)
  /// ````
  Playlist copyWithNull({
    bool description = false,
    bool customTitle = false,
  }) {
    return Playlist(
      id: id,
      title: title,
      author: author,
      thumbnailStd: thumbnailStd,
      thumbnailMax: thumbnailMax,
      videoCount: videoCount,
      description: description == true ? null : this.description,
      videoIds: videoIds,
      customTitle: customTitle == true ? null : this.customTitle,
    );
  }
}
