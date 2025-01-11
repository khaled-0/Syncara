import 'dart:math';

extension DurationExtensions on Duration? {
  String formatHHMM() {
    if (this == null) return "??:??";
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String twoDigitMinutes = twoDigits(this!.inMinutes.remainder(60));
    final String twoDigitSeconds = twoDigits(this!.inSeconds.remainder(60));
    final hour = twoDigits(this!.inHours);
    return " ${hour == '00' ? '' : '$hour:'}$twoDigitMinutes:$twoDigitSeconds ";
  }

  Duration? clampMin(Duration min) {
    if (this == null) return null;
    if (this! < min) return min;
    return this;
  }

  Duration? clampMax(Duration max) {
    if (this == null) return null;
    if (this! > max) return max;
    return this;
  }
}

extension NumberExtension on num {
  String getFileSizeString({int decimals = 0}) {
    if (isNaN || isInfinite || isNegative) return "Unknown";
    const suffixes = ["b", "kb", "mb", "gb", "tb"];
    if (this == 0) return '0${suffixes[0]}';
    var i = (log(this) / log(1024)).floor();
    return ((this / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
  }
}

extension StringExtensions on String {
  /// Converts SUSSY BAKA, SuSSy bAKA sussY BaKA etc to Sussy Baka
  String toCapitalCase() => splitMapJoin(" ", onNonMatch: (n) {
        if (n.length <= 2) return n.toUpperCase();
        return "${n[0].toUpperCase()}${n.substring(1).toLowerCase()}";
      });

  /// sussyBaka -> sussy Baka
  String normalizeCamelCase() => replaceAllMapped(
        RegExp(r"([A-Z]){1,3}"),
        (match) => " ${match[0]}",
      );
}

extension NumberExtensions on num {
  double toPrecision(int precision) {
    return double.parse((this).toStringAsFixed(precision));
  }
}
