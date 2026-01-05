import 'package:flutter_test/flutter_test.dart';
import 'package:syncara/clients/yt_transcript_fetcher.dart';

void main() async {
  final fetcher = YouTubeTranscriptFetcher();

  test("Fetch raw caption XML", () async {
    try {
      final captionXml = await fetcher.fetchCaptions(
        'Wr2crpug1j4',
        languageCode: 'en',
      );

      expect(captionXml.contains("Please help me. No worries. Sounds"), true);
    } on YouTubeTranscriptException catch (e) {
      markTestSkipped(e.toString());
    }
  });

  test("Get available captions metadata", () async {
    try {
      final availableCaptions = await fetcher.fetchAvailableCaptions(
        'dQw4w9WgXcQ',
      );

      expect(availableCaptions, isNotEmpty);
      expect(
        availableCaptions.any((e) => e.languageCode == "ja"),
        true,
      );
    } on YouTubeTranscriptException catch (e) {
      markTestSkipped(e.toString());
    }
  });

  test("Parse captions to structured data", () async {
    try {
      final captionXml = await fetcher.fetchCaptions(
        'Wr2crpug1j4',
        languageCode: 'en',
      );
      final parsedCaptions = CaptionParser.parseXml(captionXml);
      expect(parsedCaptions, isNotEmpty);
      expect(parsedCaptions.length > 3, true);

      expect(
        "${parsedCaptions[0].start}s: ${parsedCaptions[0].text} ${parsedCaptions[0].end} ${parsedCaptions[0].duration}",
        "2.0s: Please help me. No worries. Sounds 9.599 7.599",
      );

      expect(
        "${parsedCaptions[1].start}s: ${parsedCaptions[1].text} ${parsedCaptions[1].end} ${parsedCaptions[1].duration}",
        "5.2s: painful. 75year-old with a exposed bone. 11.2 6.0",
      );

      expect(
        "${parsedCaptions[2].start}s: ${parsedCaptions[2].text} ${parsedCaptions[2].end} ${parsedCaptions[2].duration}",
        "9.599s: Emergency ambulance. Is the patient 13.599 4.0",
      );
    } on YouTubeTranscriptException catch (e) {
      markTestSkipped(e.toString());
    }
  });
}
