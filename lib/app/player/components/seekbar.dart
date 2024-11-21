import 'dart:math';

import 'package:flutter/material.dart';

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;
  final bool buffering;

  const SeekBar({
    super.key,
    required this.duration,
    required this.position,
    required this.bufferedPosition,
    required this.buffering,
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  SeekBarState createState() => SeekBarState();
}

class SeekBarState extends State<SeekBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    return Slider(
      secondaryTrackValue: min(
        widget.duration.inMilliseconds,
        widget.buffering ? 0 : widget.bufferedPosition.inMilliseconds,
      ).toDouble(),
      max: widget.duration.inMilliseconds.toDouble(),
      value: max(
        _dragValue ??
            min(
              widget.position.inMilliseconds,
              widget.duration.inMilliseconds,
            ).toDouble(),
        Duration.zero.inMilliseconds.toDouble(),
      ),
      onChanged: (value) {
        if (widget.buffering) return;
        setState(() => _dragValue = value);
        widget.onChanged?.call(Duration(milliseconds: value.round()));
      },
      onChangeEnd: (value) {
        if (widget.buffering) return;
        widget.onChangeEnd?.call(Duration(milliseconds: value.round()));
        _dragValue = null;
      },
    );
  }
}

/// A variant of the default circle thumb shape
/// Similar to the one found in Android 13 Media control
class LineThumbShape extends SliderComponentShape {
  /// The size of the thumb
  final Size thumbSize;

  const LineThumbShape({
    this.thumbSize = const Size(6, 36),
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return thumbSize;
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    assert(sliderTheme.disabledThumbColor != null);
    assert(sliderTheme.thumbColor != null);

    final colorTween = ColorTween(
      begin: sliderTheme.disabledThumbColor,
      end: sliderTheme.thumbColor,
    );

    final paint = Paint()..color = colorTween.evaluate(enableAnimation)!;

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: thumbSize.width,
          height: thumbSize.height,
        ),
        Radius.circular(thumbSize.width),
      ),
      paint,
    );
  }
}
