// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PlaylistCWProxy {
  Playlist url(String url);

  Playlist title(String title);

  Playlist author(String author);

  Playlist thumbnail(String thumbnail);

  Playlist thumbnailHiRes(String? thumbnailHiRes);

  Playlist itemCount(int itemCount);

  Playlist description(String? description);

  Playlist customTitle(String? customTitle);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Playlist(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Playlist(...).copyWith(id: 12, name: "My name")
  /// ````
  Playlist call({
    String url,
    String title,
    String author,
    String thumbnail,
    String? thumbnailHiRes,
    int itemCount,
    String? description,
    String? customTitle,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPlaylist.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPlaylist.copyWith.fieldName(...)`
class _$PlaylistCWProxyImpl implements _$PlaylistCWProxy {
  const _$PlaylistCWProxyImpl(this._value);

  final Playlist _value;

  @override
  Playlist url(String url) => this(url: url);

  @override
  Playlist title(String title) => this(title: title);

  @override
  Playlist author(String author) => this(author: author);

  @override
  Playlist thumbnail(String thumbnail) => this(thumbnail: thumbnail);

  @override
  Playlist thumbnailHiRes(String? thumbnailHiRes) =>
      this(thumbnailHiRes: thumbnailHiRes);

  @override
  Playlist itemCount(int itemCount) => this(itemCount: itemCount);

  @override
  Playlist description(String? description) => this(description: description);

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
    Object? url = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? author = const $CopyWithPlaceholder(),
    Object? thumbnail = const $CopyWithPlaceholder(),
    Object? thumbnailHiRes = const $CopyWithPlaceholder(),
    Object? itemCount = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? customTitle = const $CopyWithPlaceholder(),
  }) {
    return Playlist(
      url:
          url == const $CopyWithPlaceholder()
              ? _value.url
              // ignore: cast_nullable_to_non_nullable
              : url as String,
      title:
          title == const $CopyWithPlaceholder()
              ? _value.title
              // ignore: cast_nullable_to_non_nullable
              : title as String,
      author:
          author == const $CopyWithPlaceholder()
              ? _value.author
              // ignore: cast_nullable_to_non_nullable
              : author as String,
      thumbnail:
          thumbnail == const $CopyWithPlaceholder()
              ? _value.thumbnail
              // ignore: cast_nullable_to_non_nullable
              : thumbnail as String,
      thumbnailHiRes:
          thumbnailHiRes == const $CopyWithPlaceholder()
              ? _value.thumbnailHiRes
              // ignore: cast_nullable_to_non_nullable
              : thumbnailHiRes as String?,
      itemCount:
          itemCount == const $CopyWithPlaceholder()
              ? _value.itemCount
              // ignore: cast_nullable_to_non_nullable
              : itemCount as int,
      description:
          description == const $CopyWithPlaceholder()
              ? _value.description
              // ignore: cast_nullable_to_non_nullable
              : description as String?,
      customTitle:
          customTitle == const $CopyWithPlaceholder()
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
    bool thumbnailHiRes = false,
    bool description = false,
    bool customTitle = false,
  }) {
    return Playlist(
      url: url,
      title: title,
      author: author,
      thumbnail: thumbnail,
      thumbnailHiRes: thumbnailHiRes == true ? null : this.thumbnailHiRes,
      itemCount: itemCount,
      description: description == true ? null : this.description,
      customTitle: customTitle == true ? null : this.customTitle,
    );
  }
}
