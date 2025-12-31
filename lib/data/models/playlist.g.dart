// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PlaylistCWProxy {
  Playlist url(String url);

  Playlist title(String title);

  Playlist author(String author);

  Playlist thumbnail(String? thumbnail);

  Playlist thumbnailHiRes(String? thumbnailHiRes);

  Playlist itemCount(int itemCount);

  Playlist description(String? description);

  Playlist customTitle(String? customTitle);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `Playlist(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Playlist(...).copyWith(id: 12, name: "My name")
  /// ```
  Playlist call({
    String url,
    String title,
    String author,
    String? thumbnail,
    String? thumbnailHiRes,
    int itemCount,
    String? description,
    String? customTitle,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfPlaylist.copyWith(...)` or call `instanceOfPlaylist.copyWith.fieldName(value)` for a single field.
class _$PlaylistCWProxyImpl implements _$PlaylistCWProxy {
  const _$PlaylistCWProxyImpl(this._value);

  final Playlist _value;

  @override
  Playlist url(String url) => call(url: url);

  @override
  Playlist title(String title) => call(title: title);

  @override
  Playlist author(String author) => call(author: author);

  @override
  Playlist thumbnail(String? thumbnail) => call(thumbnail: thumbnail);

  @override
  Playlist thumbnailHiRes(String? thumbnailHiRes) =>
      call(thumbnailHiRes: thumbnailHiRes);

  @override
  Playlist itemCount(int itemCount) => call(itemCount: itemCount);

  @override
  Playlist description(String? description) => call(description: description);

  @override
  Playlist customTitle(String? customTitle) => call(customTitle: customTitle);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `Playlist(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Playlist(...).copyWith(id: 12, name: "My name")
  /// ```
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
      url: url == const $CopyWithPlaceholder() || url == null
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
      title: title == const $CopyWithPlaceholder() || title == null
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      author: author == const $CopyWithPlaceholder() || author == null
          ? _value.author
          // ignore: cast_nullable_to_non_nullable
          : author as String,
      thumbnail: thumbnail == const $CopyWithPlaceholder()
          ? _value.thumbnail
          // ignore: cast_nullable_to_non_nullable
          : thumbnail as String?,
      thumbnailHiRes: thumbnailHiRes == const $CopyWithPlaceholder()
          ? _value.thumbnailHiRes
          // ignore: cast_nullable_to_non_nullable
          : thumbnailHiRes as String?,
      itemCount: itemCount == const $CopyWithPlaceholder() || itemCount == null
          ? _value.itemCount
          // ignore: cast_nullable_to_non_nullable
          : itemCount as int,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
      customTitle: customTitle == const $CopyWithPlaceholder()
          ? _value.customTitle
          // ignore: cast_nullable_to_non_nullable
          : customTitle as String?,
    );
  }
}

extension $PlaylistCopyWith on Playlist {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfPlaylist.copyWith(...)` or `instanceOfPlaylist.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PlaylistCWProxy get copyWith => _$PlaylistCWProxyImpl(this);

  /// Returns a copy of the object with the selected fields set to `null`.
  /// A flag set to `false` leaves the field unchanged. Prefer `copyWith(field: null)` or `copyWith.fieldName(null)` for single-field updates.
  ///
  /// Example:
  /// ```dart
  /// Playlist(...).copyWithNull(firstField: true, secondField: true)
  /// ```
  Playlist copyWithNull({
    bool thumbnail = false,
    bool thumbnailHiRes = false,
    bool description = false,
    bool customTitle = false,
  }) {
    return Playlist(
      url: url,
      title: title,
      author: author,
      thumbnail: thumbnail == true ? null : this.thumbnail,
      thumbnailHiRes: thumbnailHiRes == true ? null : this.thumbnailHiRes,
      itemCount: itemCount,
      description: description == true ? null : this.description,
      customTitle: customTitle == true ? null : this.customTitle,
    );
  }
}
