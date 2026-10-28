import 'pitch_diagram_data.dart';

enum SessionStatus { planned, completed }

/// One phase of a session plan (Warm Up, Main Activity 1, etc.), matching
/// the `session_sections` table in the Supabase schema.
class SessionSection {
  final String phase;
  final String? drillName;
  final int durationMins;
  final String coachingPoints;

  /// This section's own saved tactics-board diagram (players, drawn lines,
  /// highlights) — null until the coach saves one from the Session Builder
  /// or by tapping into this section on Session Detail. Deliberately not
  /// `final`: saving mutates this same in-memory Session/section instance
  /// so every screen holding a reference to it sees the update, without
  /// needing a backend yet.
  PitchDiagramData? diagram;

  SessionSection({
    required this.phase,
    required this.durationMins,
    this.drillName,
    this.coachingPoints = '',
    this.diagram,
  });
}

/// A planned or completed training session, matching the `sessions` table.
class Session {
  final String id;
  final String title;
  final DateTime date;
  final int durationMins;
  final String topicTheme;
  final List<String> objectives;
  final int playerCount;
  final String venue;
  final List<String> equipment;
  final String safetyNotes;
  final SessionStatus status;
  final List<SessionSection> sections;

  /// Which of the coach's teams (see Team, set up on the Profile page) this
  /// session is for — `null` for a session that hasn't been assigned one.
  /// Drives the team name/colour shown on the session card and used for
  /// Team A in this session's pitch diagram(s).
  final String? teamId;

  const Session({
    required this.id,
    required this.title,
    required this.date,
    required this.durationMins,
    required this.topicTheme,
    required this.objectives,
    required this.playerCount,
    required this.venue,
    required this.status,
    this.equipment = const [],
    this.safetyNotes = '',
    this.sections = const [],
    this.teamId,
  });

  int get drillCount => sections.where((s) => s.drillName != null).length;

  /// Short, human relative label for the dashboard's "next session" card,
  /// e.g. "In 2 days", "Tomorrow", "3 days ago".
  String relativeLabel(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final sessionDay = DateTime(date.year, date.month, date.day);
    final diff = sessionDay.difference(today).inDays;
    if (diff == 0) return 'TODAY';
    if (diff == 1) return 'TOMORROW';
    if (diff > 1) return 'IN $diff DAYS';
    if (diff == -1) return '1D AGO';
    return '${diff.abs()}D AGO';
  }
}
