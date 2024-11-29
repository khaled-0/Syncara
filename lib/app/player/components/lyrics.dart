import 'package:amlv/amlv.dart';
import 'package:flutter/material.dart';

class Lyrics extends StatelessWidget{
  const Lyrics({super.key});

  @override
  Widget build(BuildContext context) {
    return LyricViewer(
      lyric: lyric!,
      onLyricChanged: (LyricLine line, String source) {
        // ignore: avoid_print
        print("$source: [${line.time}] ${line.content}");
      },
      onCompleted: () {
        // ignore: avoid_print
        print("Completed");
      },
      gradientColor1: const Color(0xFFCC9934),
      gradientColor2: const Color(0xFF444341),
    );
  }
  
}