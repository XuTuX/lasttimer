import 'dart:math';

class StatsUtils {
  static double calculateMean(List<num> values) {
    if (values.isEmpty) return 0.0;
    final sum = values.fold<double>(0.0, (a, b) => a + b);
    return sum / values.length;
  }

  static double calculateVariance(List<num> values) {
    if (values.isEmpty || values.length == 1) return 0.0;
    final mean = calculateMean(values);
    final sumSquaredDiff = values
        .map((v) => pow(v - mean, 2))
        .fold<double>(0.0, (a, b) => a + b);
    return sumSquaredDiff / values.length;
  }

  static double calculateStdDev(List<num> values) {
    return sqrt(calculateVariance(values));
  }
}
