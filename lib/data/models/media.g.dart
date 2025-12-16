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

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Media(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Media(...).copyWith(id: 12, name: "My name")
  /// ````
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

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMedia.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMedia.copyWith.fieldName(...)`
class _$MediaCWProxyImpl implements _$MediaCWProxy {
  const _$MediaCWProxyImpl(this._value);

  final Media _value;

  @override
  Media url(String url) => this(url: url);

  @override
  Media title(String title) => this(title: title);

  @override
  Media author(String author) => this(author: author);

  @override
  Media durationMs(int? durationMs) => this(durationMs: durationMs);

  @override
  Media thumbnail(String? thumbnail) => this(thumbnail: thumbnail);

  @override
  Media thumbnailHiRes(String? thumbnailHiRes) =>
      this(thumbnailHiRes: thumbnailHiRes);

  @override
  Media localPath(String? localPath) => this(localPath: localPath);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Media(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Media(...).copyWith(id: 12, name: "My name")
  /// ````
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
      durationMs:
          durationMs == const $CopyWithPlaceholder()
              ? _value.durationMs
              // ignore: cast_nullable_to_non_nullable
              : durationMs as int?,
      thumbnail:
          thumbnail == const $CopyWithPlaceholder()
              ? _value.thumbnail
              // ignore: cast_nullable_to_non_nullable
              : thumbnail as String?,
      thumbnailHiRes:
          thumbnailHiRes == const $CopyWithPlaceholder()
              ? _value.thumbnailHiRes
              // ignore: cast_nullable_to_non_nullable
              : thumbnailHiRes as String?,
      localPath:
          localPath == const $CopyWithPlaceholder()
              ? _value.localPath
              // ignore: cast_nullable_to_non_nullable
              : localPath as String?,
    );
  }
}

extension $MediaCopyWith on Media {
  /// Returns a callable class that can be used as follows: `instanceOfMedia.copyWith(...)` or like so:`instanceOfMedia.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MediaCWProxy get copyWith => _$MediaCWProxyImpl(this);

  /// Copies the object with the specific fields set to `null`. If you pass `false` as a parameter, nothing will be done and it will be ignored. Don't do it. Prefer `copyWith(field: null)` or `Media(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Media(...).copyWithNull(firstField: true, secondField: true)
  /// ````
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
