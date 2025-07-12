import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:syncara/clients/media_client.dart';
import 'package:syncara/model/common.dart';
import 'package:syncara/model/media.dart';
import 'package:syncara/model/objectbox.g.dart';
import 'package:syncara/model/preferences.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

class CookieClient extends yt.YoutubeHttpClient {
  final Box<Preferences> preferences = GetIt.I<Store>().box<Preferences>();

  String get cookie {
    return preferences.value<String>(Preference.cookies);
  }

  @override
  Map<String, String> get headers {
    final Map<String, String> customHeaders = {
      ...yt.YoutubeHttpClient.defaultHeaders,
    };
    if (cookie.isEmpty) return customHeaders;

    customHeaders.update(
      "cookie",
      (value) => "$cookie; $value",
      ifAbsent: () => cookie,
    );
    return customHeaders;
  }
}

class YTMediaClient implements BaseMediaClient {
  static final client = yt.YoutubeExplode(CookieClient());

  @override
  Future<AudioSource> getMediaSource(Media media) async {
    final streamUri = await compute((data) async {
      final ytClient = data[0] as yt.StreamClient;
      final videoManifest = await ytClient.getManifest(data[1]);
      return videoManifest.audio.withHighestBitrate().url;
    }, [client.videos.streamsClient, media.id]);

    return AudioSource.uri(streamUri);
  }

  @override
  Future<List<LyricMetadata>> getAvailableLyrics(Media media) async {
    return await compute((data) async {
      final ytClient = data[0] as yt.ClosedCaptionClient;
      final trackManifest = await ytClient.getManifest(
        data[1],
        // TODO: It doesn't matter ??
        formats: [const yt.ClosedCaptionFormat("lrc")],
      );
      return trackManifest.tracks
          .map((e) => LyricMetadata.fromYTCaption(media, e))
          .toList();
    }, [client.videos.closedCaptions, media.id]);
  }

  @override
  Future<List<String>> getLRCLyrics(LyricMetadata meta) async {
    return await compute((data) async {
      final ytClient = data[0] as yt.ClosedCaptionClient;
      final trackManifest = await ytClient.get(
        data[1] as yt.ClosedCaptionTrackInfo,
      );
      return trackManifest.captions.map((e) {
        // FIXME: Don't do hacks
        final timestamp = (e.offset).toString().substring(2, 10);
        final lyric = e.text.replaceAll("\n", " ");

        return "[$timestamp]$lyric";
      }).toList();
    }, [client.videos.closedCaptions, meta.ytCCObj]);
  }
}
