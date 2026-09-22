String formatDuration(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;

  return "$minutes:${seconds.toString().padLeft(2, '0')}";
}

Duration parse(String time) {
  // Support "." maupun ","
  time = time.replaceAll(',', '.');

  final p = time.split(':');

  final hour = int.parse(p[0]);
  final minute = int.parse(p[1]);

  final sec = double.parse(p[2]);

  return Duration(
    hours: hour,
    minutes: minute,
    milliseconds: (sec * 1000).round(),
  );
}