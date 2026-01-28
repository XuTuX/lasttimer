import 'dart:math';

class StatsUtils {
  /// 평균 계산
  static double calculateMean(List<num> values) {
    if (values.isEmpty) return 0.0;
    final sum = values.fold<double>(0.0, (a, b) => a + b);
    return sum / values.length;
  }

  /// 분산 계산
  static double calculateVariance(List<num> values) {
    if (values.isEmpty || values.length == 1) return 0.0;
    final mean = calculateMean(values);
    final sumSquaredDiff = values
        .map((v) => pow(v - mean, 2))
        .fold<double>(0.0, (a, b) => a + b);
    return sumSquaredDiff / values.length;
  }

  /// 표준편차 계산
  static double calculateStdDev(List<num> values) {
    return sqrt(calculateVariance(values));
  }

  /// 절사 평균(Trimmed Mean) 계산
  /// [trimPercent]: 상하위 몇 %를 제거할지 (0.0 ~ 0.5, 기본값 0.3 = 30%)
  ///
  /// 예: 30% 절사평균은 상위 30%, 하위 30% 데이터를 제거 후 평균
  static double calculateTrimmedMean(
    List<num> values, {
    double trimPercent = 0.30,
  }) {
    if (values.isEmpty) return 0.0;
    if (values.length <= 2) return calculateMean(values);

    // 절사 비율 검증
    final safePercent = trimPercent.clamp(0.0, 0.49);

    // 정렬된 복사본 생성
    final sorted = List<num>.from(values)..sort();

    // 제거할 개수 계산 (최소 1개씩은 남기도록)
    final trimCount = (sorted.length * safePercent).floor();

    // 남는 데이터가 없으면 전체 평균 반환
    if (sorted.length - (trimCount * 2) <= 0) {
      return calculateMean(values);
    }

    // 상하위 제거 후 평균
    final trimmed = sorted.sublist(trimCount, sorted.length - trimCount);
    return calculateMean(trimmed);
  }

  /// 상위 N% 오래 걸린 문항들 추출
  /// [questionTimes]: Map<문항번호, List<소요시간들>>
  /// [topPercent]: 상위 몇 % 추출 (기본값 0.10 = 10%)
  ///
  /// 반환: List<(문항번호, 평균시간)> 오래 걸린 순서로 정렬
  static List<MapEntry<int, double>> getTopSlowQuestions(
    Map<int, List<int>> questionTimes, {
    double topPercent = 0.10,
  }) {
    if (questionTimes.isEmpty) return [];

    // 문항별 평균 시간 계산
    final avgTimes = <int, double>{};
    for (final entry in questionTimes.entries) {
      if (entry.value.isNotEmpty) {
        avgTimes[entry.key] = calculateMean(entry.value);
      }
    }

    // 평균 시간 기준 내림차순 정렬
    final sorted = avgTimes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // 상위 N% 추출 (최소 1개)
    final topCount = max(1, (sorted.length * topPercent).ceil());
    return sorted.take(topCount).toList();
  }

  /// 문항별 절사 평균 시간 계산
  /// [questionTimes]: Map<문항번호, List<소요시간들>>
  /// [trimPercent]: 절사 비율 (기본값 0.30 = 30%)
  ///
  /// 반환: Map<문항번호, 절사평균시간>
  static Map<int, double> getQuestionTrimmedMeans(
    Map<int, List<int>> questionTimes, {
    double trimPercent = 0.30,
  }) {
    final result = <int, double>{};
    for (final entry in questionTimes.entries) {
      if (entry.value.isNotEmpty) {
        result[entry.key] = calculateTrimmedMean(
          entry.value,
          trimPercent: trimPercent,
        );
      }
    }
    return result;
  }

  /// 문항별 시간 데이터 구조화
  /// [exams]: 시험 목록
  ///
  /// 반환: Map<문항번호(1부터), List<해당 문항 소요시간들>>
  static Map<int, List<int>> aggregateQuestionTimes(
    List<List<int>> questionSecondsList,
  ) {
    final result = <int, List<int>>{};

    for (final questionSeconds in questionSecondsList) {
      for (var i = 0; i < questionSeconds.length; i++) {
        final questionNum = i + 1; // 1-based
        result.putIfAbsent(questionNum, () => []);
        result[questionNum]!.add(questionSeconds[i]);
      }
    }

    return result;
  }
}
