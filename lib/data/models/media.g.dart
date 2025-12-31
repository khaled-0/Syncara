// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MediaCWProxy {
  Media url(String url);

  Media title(String title);

  Media author(String author);

  Media durationMs(int? durationMs);

  Media thumbnail(String? thumbnail);

  Media thumbnailHiRes(String? thumbnailHiRes);

  Media localPath(String? localPath);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `Media(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Media(...).copyWith(id: 12, name: "My name")
  /// ```
  Media call({
    String url,
    String title,
    String author,
    int? durationMs,
    String? thumbnail,
    String? thumbnailHiRes,
    String? localPath,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfMedia.copyWith(...)` or call `instanceOfMedia.copyWith.fieldName(value)` for a single field.
class _$MediaCWProxyImpl implements _$MediaCWProxy {
  const _$MediaCWProxyImpl(this._value);

  final Media _value;

  @override
  Media url(String url) => call(url: url);

  @override
  Media title(String title) => call(title: title);

  @override
  Media author(String author) => call(author: author);

  @override
  Media durationMs(int? durationMs) => call(durationMs: durationMs);

  @override
  Media thumbnail(String? thumbnail) => call(thumbnail: thumbnail);

  @override
  Media thumbnailHiRes(String? thumbnailHiRes) =>
      call(thumbnailHiRes: thumbnailHiRes);

  @override
  Media localPath(String? localPath) => call(localPath: localPath);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `Media(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Media(...).copyWith(id: 12, name: "My name")
  /// ```
  Media call({
    Object? url = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? author = const $CopyWithPlaceholder(),
    Object? durationMs = const $CopyWithPlaceholder(),
    Object? thumbnail = const $CopyWithPlaceholder(),
    Object? thumbnailHiRes = const $CopyWithPlaceholder(),
    Object? localPath = const $CopyWithPlaceholder(),
  }) {
    return Media(
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
      durationMs: durationMs == const $CopyWithPlaceholder()
          ? _value.durationMs
          // ignore: cast_nullable_to_non_nullable
          : durationMs as int?,
      thumbnail: thumbnail == const $CopyWithPlaceholder()
          ? _value.thumbnail
          // ignore: cast_nullable_to_non_nullable
          : thumbnail as String?,
      thumbnailHiRes: thumbnailHiRes == const $CopyWithPlaceholder()
          ? _value.thumbnailHiRes
          // ignore: cast_nullable_to_non_nullable
          : thumbnailHiRes as String?,
      localPath: localPath == const $CopyWithPlaceholder()
          ? _value.localPath
          // ignore: cast_nullable_to_non_nullable
          : localPath as String?,
    );
  }
}

extension $MediaCopyWith on Media {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfMedia.copyWith(...)` or `instanceOfMedia.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MediaCWProxy get copyWith => _$MediaCWProxyImpl(this);

  /// Returns a copy of the object with the selected fields set to `null`.
  /// A flag set to `false` leaves the field unchanged. Prefer `copyWith(field: null)` or `copyWith.fieldName(null)` for single-field updates.
  ///
  /// Example:
  /// ```dart
  /// Media(...).copyWithNull(firstField: true, secondField: true)
  /// ```
  Media copyWithNull({
    bool durationMs = false,
    bool thumbnail = false,
    bool thumbnailHiRes = false,
    bool localPath = false,
  }) {
    return Media(
      url: url,
      title: title,
      author: author,
      durationMs: durationMs == true ? null : this.durationMs,
      thumbnail: thumbnail == true ? null : this.thumbnail,
      thumbnailHiRes: thumbnailHiRes == true ? null : this.thumbnailHiRes,
      localPath: localPath == true ? null : this.localPath,
    );
  }
}
