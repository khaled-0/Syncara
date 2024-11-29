import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tubesync/clients/media_client.dart';
import 'package:tubesync/model/common.dart';
import 'package:tubesync/model/media.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

class YTMediaClient implements BaseMediaClient {
  final _ytClient = yt.YoutubeExplode().videos;

  @override
  Future<AudioSource> getMediaSource(Media media) async {
    final streamUri = await compute(
      (data) async {
        final ytClient = data[0] as yt.StreamClient;
        final videoManifest = await ytClient.getManifest(data[1]);
        return videoManifest.audioOnly.withHighestBitrate().url;
      },
      [_ytClient.streamsClient, media.id],
    );

    return AudioSource.uri(streamUri);
  }

  @override
  Future<List<LyricMetadata>> getAvailableLyrics(Media media) async {
    return await compute(
      (data) async {
        final ytClient = data[0] as yt.ClosedCaptionClient;
        final trackManifest = await ytClient.getManifest(data[1]);
        return trackManifest.tracks
            .map((e) => LyricMetadata.fromYTCaption(media, e))
            .toList();
      },
      [_ytClient.closedCaptions, media.id],
    );
  }

  @override
  Future<List<String>> getLRCLyrics(LyricMetadata track) async {
    return await compute(
      (data) async {
        final ytClient = data[0] as yt.ClosedCaptionClient;
        final trackManifest = await ytClient.get(
          data[1] as yt.ClosedCaptionTrackInfo,
        );
        return trackManifest.captions
            .map((e) => "[${e.duration.toString()}]${e.text}")
            .toList();
      },
      [_ytClient.closedCaptions, track],
    );
  }
}
