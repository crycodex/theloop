/// Calcula la racha actual a partir de fechas de práctica completadas.
///
/// Cuenta días consecutivos con al menos un loop completado,
/// empezando desde hoy o ayer si aún no practicó hoy.
int computePracticeStreak(Iterable<DateTime> practiceDates) {
  if (practiceDates.isEmpty) return 0;

  final days = practiceDates.map(_dateOnly).toSet();
  final today = _dateOnly(DateTime.now());

  var cursor = days.contains(today)
      ? today
      : today.subtract(const Duration(days: 1));

  if (!days.contains(cursor)) return 0;

  var streak = 0;
  while (days.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
