String durationToMMSS(Duration duration) {
  final positive = duration.isNegative ? Duration.zero : duration;
  final totalSeconds = positive.inSeconds;
  final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

Duration? parseDurationFromMMSS(String value) {
  final trimmed = value.trim();
  final match = RegExp(r'^(\d+):(\d{2})$').firstMatch(trimmed);
  if (match == null) {
    return null;
  }
  final minutes = int.tryParse(match.group(1)!);
  final seconds = int.tryParse(match.group(2)!);
  if (minutes == null || seconds == null) {
    return null;
  }
  if (seconds < 0 || seconds >= 60 || minutes < 0) {
    return null;
  }
  return Duration(minutes: minutes, seconds: seconds);
}
