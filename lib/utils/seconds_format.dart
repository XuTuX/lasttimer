String formatSeconds(int totalSeconds) {
  final duration = Duration(seconds: totalSeconds);
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  final minStr = minutes.toString().padLeft(2, '0');
  final secStr = seconds.toString().padLeft(2, '0');

  if (hours > 0) {
    final hourStr = hours.toString().padLeft(2, '0');
    return '$hourStr:$minStr:$secStr';
  } else {
    return '$minStr:$secStr';
  }
}
