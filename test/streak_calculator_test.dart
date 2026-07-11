import 'package:flutter_test/flutter_test.dart';
import 'package:theloop/core/utils/streak_calculator.dart';

void main() {
  group('computePracticeStreak', () {
    test('devuelve 0 sin prácticas', () {
      expect(computePracticeStreak(const []), 0);
    });

    test('cuenta racha consecutiva desde hoy', () {
      final now = DateTime.now();
      final dates = [
        now,
        now.subtract(const Duration(days: 1)),
        now.subtract(const Duration(days: 2)),
      ];
      expect(computePracticeStreak(dates), 3);
    });

    test('mantiene racha si practicó ayer pero no hoy', () {
      final now = DateTime.now();
      final dates = [
        now.subtract(const Duration(days: 1)),
        now.subtract(const Duration(days: 2)),
      ];
      expect(computePracticeStreak(dates), 2);
    });

    test('rompe racha si faltó ayer y hoy', () {
      final now = DateTime.now();
      final dates = [
        now.subtract(const Duration(days: 3)),
        now.subtract(const Duration(days: 4)),
      ];
      expect(computePracticeStreak(dates), 0);
    });

    test('un solo día hoy cuenta como 1', () {
      expect(computePracticeStreak([DateTime.now()]), 1);
    });
  });
}
