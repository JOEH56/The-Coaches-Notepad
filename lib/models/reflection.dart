import 'reflection_status.dart';

/// A post-session reflection, matching the `reflections` table.
/// total_score is a generated column (sum of the four dimension ratings,
/// out of 20) in the real schema — computed here as a getter to match.
class Reflection {
  final String id;
  final String sessionId;
  final String sessionTitle;
  final DateTime date;

  final int ratingSessionDesign; // 1-5
  final int ratingSessionOutcomes; // 1-5
  final int ratingCoachingBehaviour; // 1-5
  final int ratingPlayerEngagement; // 1-5

  final String whatWentWell;
  final String whatDidntGoAsPlanned;
  final String whatWouldYouDoDifferently;
  final String focusNextSession;

  final int? coachWellbeingRating; // 1-5, optional
  final String coachWellbeingNotes;

  final ReflectionStatus overallStatus;

  /// Concrete, actionable next steps the coach identified while writing
  /// this reflection (separate from the free-text `focusNextSession`
  /// summary) — each one shows as a checkable item on this reflection and
  /// feeds the Dashboard's "Next Steps" area until it's ticked off.
  final List<String> actions;

  const Reflection({
    required this.id,
    required this.sessionId,
    required this.sessionTitle,
    required this.date,
    required this.ratingSessionDesign,
    required this.ratingSessionOutcomes,
    required this.ratingCoachingBehaviour,
    required this.ratingPlayerEngagement,
    required this.overallStatus,
    this.whatWentWell = '',
    this.whatDidntGoAsPlanned = '',
    this.whatWouldYouDoDifferently = '',
    this.focusNextSession = '',
    this.coachWellbeingRating,
    this.coachWellbeingNotes = '',
    this.actions = const [],
  });

  /// Auto-calculated total out of 20 (matches the DB's generated column).
  int get totalScore =>
      ratingSessionDesign +
      ratingSessionOutcomes +
      ratingCoachingBehaviour +
      ratingPlayerEngagement;

  /// Quick-glance star rating out of 5, shown on the Reflect list.
  double get starRating => totalScore / 4;
}
