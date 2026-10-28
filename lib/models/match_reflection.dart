import 'reflection_status.dart';

/// A post-match reflection, logged from the Matchday tab — the same shape as
/// [Reflection] (four 1-5 dimension ratings summing to a /20 total, free-text
/// questions, an overall status badge and a list of concrete actions) but
/// with match-specific questions instead of session ones, and tagged with
/// the formation that started the match.
class MatchReflection {
  final String id;
  final String matchTitle;
  final DateTime date;
  final String formationName;

  final int ratingTeamPerformance; // 1-5
  final int ratingTacticalExecution; // 1-5
  final int ratingPlayerAttitude; // 1-5

  /// Covers both the coach's in-match decision-making and their behaviour
  /// on the touchline — one rating rather than two, so this stays a
  /// four-dimension reflection instead of growing a fifth star rating.
  final int ratingCoachingManner; // 1-5

  final String whatWentWell;
  final String whatDidntGoAsPlanned;
  final String whatWouldYouDoDifferently;
  final String focusNextMatch;

  final ReflectionStatus overallStatus;

  /// Concrete, actionable next steps identified while writing this
  /// reflection — feeds the Dashboard's "Next Steps" area, same as a
  /// session reflection's own actions.
  final List<String> actions;

  const MatchReflection({
    required this.id,
    required this.matchTitle,
    required this.date,
    required this.formationName,
    required this.ratingTeamPerformance,
    required this.ratingTacticalExecution,
    required this.ratingPlayerAttitude,
    required this.ratingCoachingManner,
    required this.overallStatus,
    this.whatWentWell = '',
    this.whatDidntGoAsPlanned = '',
    this.whatWouldYouDoDifferently = '',
    this.focusNextMatch = '',
    this.actions = const [],
  });

  /// Auto-calculated total out of 20, same convention as [Reflection.totalScore].
  int get totalScore =>
      ratingTeamPerformance + ratingTacticalExecution + ratingPlayerAttitude + ratingCoachingManner;

  /// Quick-glance star rating out of 5.
  double get starRating => totalScore / 4;
}
