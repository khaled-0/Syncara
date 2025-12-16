import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:syncara/clients/media_client.dart';
import 'package:syncara/model/common.dart';
import 'package:syncara/data/models/media.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

class YTMediaClient implements BaseMediaClient {
  final _ytClient = yt.YoutubeExplode().videos;

  @override
  Future<AudioSource> getMediaSource(Media media) async {
    final streamUri = await compute(
      (data) async {
        final ytClient = data[0] as yt.StreamClient;
        final videoManifest = await ytClient.getManifest(data[1]);
        return videoManifest.audio.withHighestBitrate().url;
      },
      [_ytClient.streamsClient, media.url],
    );

    return AudioSource.uri(streamUri);
  }

  @override
  Future<List<LyricMetadata>> getAvailableLyrics(Media media) async {
    return await compute(
      (data) async {
        final ytClient = data[0] as yt.ClosedCaptionClient;
        final trackManifest = await ytClient.getManifest(
          data[1],
          // TODO: It doesn't matter ??
          formats: [const yt.ClosedCaptionFormat("lrc")],
        );
        return trackManifest.tracks
            .map((e) => LyricMetadata.fromYTCaption(media, e))
            .toList();
      },
      [_ytClient.closedCaptions, media.url],
    );
  }

  @override
  Future<List<String>> getLRCLyrics(LyricMetadata meta) async {
    return await compute(
      (data) async {
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
      },
      [_ytClient.closedCaptions, meta.ytCCObj],
    );
  }
}
