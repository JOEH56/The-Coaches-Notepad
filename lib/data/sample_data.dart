import '../models/player.dart';
import '../models/reflection.dart';
import '../models/reflection_status.dart';
import '../models/session.dart';

/// Hardcoded sample data so the app is never empty on first run — mirrors
/// the "Jamie" coach shown in the original screenshots. In the real app
/// this is replaced by data loaded from Supabase for the signed-in coach.
class SampleData {
  SampleData._();

  static const String coachFirstName = 'Jamie';

  /// Sample dates are kept relative to whenever the app is actually opened
  /// (rather than hardcoded to a fixed calendar date) so the "next session"
  /// card and the Progress charts never drift into a stale, confusing state
  /// like a "next" session showing as weeks in the past. The offsets below
  /// preserve the original story — two upcoming sessions, four completed
  /// ones trailing back over the previous fortnight.
  static final DateTime _today = DateTime.now();
  static DateTime _relDate(int offsetDays) {
    final base = DateTime(_today.year, _today.month, _today.day);
    return base.add(Duration(days: offsetDays));
  }

  static final List<Session> sessions = [
    Session(
      id: 's1',
      title: 'High Press & Pressing Triggers',
      date: _relDate(2),
      durationMins: 90,
      topicTheme: 'Pressing & Defending',
      playerCount: 18,
      venue: 'Riverside Training Ground, Pitch 2',
      status: SessionStatus.planned,
      teamId: 't1',
      objectives: const [
        'Establish coordinated pressing triggers from the front three',
        'Improve compactness in mid-block defensive shape',
        'Transition speed out of press into attack',
      ],
      equipment: const ['Balls', 'Cones', 'Bibs', 'Poles'],
      safetyNotes: 'Pitch slightly damp after rain — check footing near the near-side touchline.',
      sections: [
        SessionSection(
          phase: 'Warm Up & Activation',
          drillName: 'Dynamic Activation',
          durationMins: 10,
          coachingPoints: 'High energy, gradual increase in intensity.',
        ),
        SessionSection(
          phase: 'Main Activity 1',
          drillName: 'Pressing Trigger Recognition',
          durationMins: 20,
          coachingPoints: 'Cue off the pass to the weak side; front three stagger their press.',
        ),
        SessionSection(
          phase: 'Small Sided Game',
          drillName: 'SSG 7v7 High Press',
          durationMins: 25,
          coachingPoints: 'Reward regains inside 6 seconds; reset on turnover.',
        ),
        SessionSection(
          phase: 'Cool Down & Recovery',
          drillName: 'Static Stretch & Review',
          durationMins: 10,
          coachingPoints: 'Group review of pressing triggers, then individual stretch.',
        ),
      ],
    ),
    Session(
      id: 's2',
      title: 'High Intensity Conditioning',
      date: _relDate(5),
      durationMins: 65,
      topicTheme: 'Conditioned Games',
      playerCount: 20,
      venue: 'Riverside Training Ground, Pitch 1',
      status: SessionStatus.planned,
      teamId: 't2',
      objectives: const [
        'Build aerobic capacity through ball-based conditioning',
        'Maintain technical quality under fatigue',
      ],
      equipment: const ['Balls', 'Cones', 'Bibs', 'Goals'],
      sections: [
        SessionSection(phase: 'Warm Up & Activation', drillName: 'Rondo Possession', durationMins: 10),
        SessionSection(phase: 'Main Activity 1', drillName: 'Gegenpress Conditioned Game', durationMins: 20),
        SessionSection(phase: 'Small Sided Game', drillName: 'SSG 5v5 Continuous', durationMins: 25),
        SessionSection(phase: 'Cool Down & Recovery', drillName: 'Walkthrough & Stretch', durationMins: 10),
      ],
    ),
    Session(
      id: 's3',
      title: 'Build-Up Play from GK',
      date: _relDate(-4),
      durationMins: 75,
      topicTheme: 'Passing & Possession',
      playerCount: 16,
      venue: 'Riverside Training Ground, Pitch 2',
      status: SessionStatus.completed,
      teamId: 't1',
      objectives: const [
        'Build confidence receiving under pressure from the goalkeeper',
        'Establish passing patterns through the thirds',
        'Recognise when to play short vs. go long',
      ],
      sections: [
        SessionSection(phase: 'Warm Up & Activation', drillName: 'Passing Triangles', durationMins: 10),
        SessionSection(phase: 'Main Activity 1', drillName: 'Build-Up Patterns vs. Passive Press', durationMins: 25),
        SessionSection(phase: 'Small Sided Game', drillName: 'SSG 8v8 Build From Back', durationMins: 25),
        SessionSection(phase: 'Cool Down & Recovery', drillName: 'Stretch & Review', durationMins: 15),
      ],
    ),
    Session(
      id: 's4',
      title: 'Defensive Shape & Compactness',
      date: _relDate(-7),
      durationMins: 60,
      topicTheme: 'Pressing & Defending',
      playerCount: 18,
      venue: 'Riverside Training Ground, Pitch 1',
      status: SessionStatus.completed,
      teamId: 't2',
      objectives: const [
        'Maintain compact mid-block defensive shape',
        'Improve unit shifting side to side',
      ],
      sections: [
        SessionSection(phase: 'Warm Up & Activation', drillName: 'Shape Walkthrough', durationMins: 10),
        SessionSection(phase: 'Main Activity 1', drillName: 'Shifting Shape Grid', durationMins: 20),
        SessionSection(phase: 'Small Sided Game', drillName: 'SSG 8v8 Compact Block', durationMins: 20),
        SessionSection(phase: 'Cool Down & Recovery', drillName: 'Stretch & Review', durationMins: 10),
      ],
    ),
    Session(
      id: 's5',
      title: 'Set Pieces — Attacking Corners',
      date: _relDate(-12),
      durationMins: 60,
      topicTheme: 'Set Pieces — Attacking',
      playerCount: 18,
      venue: 'Riverside Training Ground, Pitch 2',
      status: SessionStatus.completed,
      teamId: 't1',
      objectives: const [
        'Install three attacking corner routines',
        'Improve first-contact quality at the near post',
      ],
      sections: [
        SessionSection(phase: 'Warm Up & Activation', drillName: 'Dynamic Activation', durationMins: 10),
        SessionSection(phase: 'Main Activity 1', drillName: 'Corner Routine Walkthrough', durationMins: 20),
        SessionSection(phase: 'Main Activity 2', drillName: 'Corner Routines vs. Opposed Defence', durationMins: 20),
        SessionSection(phase: 'Cool Down & Recovery', drillName: 'Stretch & Review', durationMins: 10),
      ],
    ),
    Session(
      id: 's6',
      title: 'High Press — Previous Attempt',
      date: _relDate(-14),
      durationMins: 90,
      topicTheme: 'Pressing & Defending',
      playerCount: 17,
      venue: 'Riverside Training Ground, Pitch 2',
      status: SessionStatus.completed,
      teamId: 't2',
      objectives: const [
        'Establish coordinated pressing triggers from the front three',
        'Improve compactness in mid-block defensive shape',
      ],
      sections: [
        SessionSection(phase: 'Warm Up & Activation', drillName: 'Dynamic Activation', durationMins: 10),
        SessionSection(phase: 'Main Activity 1', drillName: 'Pressing Trigger Recognition', durationMins: 25),
        SessionSection(phase: 'Small Sided Game', drillName: 'SSG 7v7 High Press', durationMins: 25),
        SessionSection(phase: 'Cool Down & Recovery', drillName: 'Stretch & Review', durationMins: 10),
      ],
    ),
  ];

  static final List<Reflection> reflections = [
    Reflection(
      id: 'r1',
      sessionId: 's3',
      sessionTitle: 'Build-Up Play from GK',
      date: _relDate(-4),
      ratingSessionDesign: 4,
      ratingSessionOutcomes: 4,
      ratingCoachingBehaviour: 4,
      ratingPlayerEngagement: 4,
      overallStatus: ReflectionStatus.good,
      whatWentWell: 'The passing patterns drill clicked really well — players read the press quicker each rep.',
      whatDidntGoAsPlanned: 'A couple of players struggled to switch play under pressure early on.',
      whatWouldYouDoDifferently: 'Introduce the passive press stage a rep or two earlier.',
      focusNextSession: 'Carry the switching-play pattern into next week\'s possession session.',
      coachWellbeingRating: 4,
      coachWellbeingNotes: 'Good energy, felt organised throughout.',
      actions: const [
        'Carry the switching-play pattern into next week\'s possession session',
        'Give the two players who struggled under pressure some 1-on-1 time before the next session',
      ],
    ),
    Reflection(
      id: 'r2',
      sessionId: 's4',
      sessionTitle: 'Defensive Shape & Compactness',
      date: _relDate(-7),
      ratingSessionDesign: 3,
      ratingSessionOutcomes: 3,
      ratingCoachingBehaviour: 3,
      ratingPlayerEngagement: 3,
      overallStatus: ReflectionStatus.neutral,
      whatWentWell: 'The walk-through at the start was the right call — players understood the shape faster.',
      whatDidntGoAsPlanned: 'Grid drill ran long; SSG got compressed to 15 minutes.',
      whatWouldYouDoDifferently: 'Time-box the grid drill more strictly and move on regardless.',
      focusNextSession: 'Revisit shifting shape under game speed.',
      actions: const [
        'Set a hard 10-minute timer for the grid drill next time',
        'Book a full-size pitch slot so the SSG doesn\'t get compressed again',
      ],
    ),
    Reflection(
      id: 'r3',
      sessionId: 's5',
      sessionTitle: 'Set Pieces — Attacking Corners',
      date: _relDate(-12),
      ratingSessionDesign: 5,
      ratingSessionOutcomes: 5,
      ratingCoachingBehaviour: 5,
      ratingPlayerEngagement: 5,
      overallStatus: ReflectionStatus.excellent,
      whatWentWell: 'Best set piece session of the year. All three routines were executed with real conviction.',
      whatDidntGoAsPlanned: 'Nothing significant — minor mix-up on the short-corner variant.',
      whatWouldYouDoDifferently: 'Nothing — repeat this structure for defensive corners.',
      focusNextSession: 'Add a fourth, more advanced corner routine.',
      coachWellbeingRating: 5,
      coachWellbeingNotes: 'Really enjoyed delivering this one — players fully bought in.',
      actions: const [
        'Design a fourth, more advanced corner routine for next set-piece session',
        'Clarify the short-corner variant with the two players who mixed it up',
      ],
    ),
    Reflection(
      id: 'r4',
      sessionId: 's6',
      sessionTitle: 'High Press — Previous Attempt',
      date: _relDate(-14),
      ratingSessionDesign: 2,
      ratingSessionOutcomes: 2,
      ratingCoachingBehaviour: 2,
      ratingPlayerEngagement: 2,
      overallStatus: ReflectionStatus.tough,
      whatWentWell: 'Players stayed engaged despite a tough session.',
      whatDidntGoAsPlanned: 'Pressing triggers were unclear — players hesitated and got bypassed repeatedly.',
      whatWouldYouDoDifferently: 'Simplify to a single trigger before layering in more complexity.',
      focusNextSession: 'Rebuild pressing triggers from a simpler starting point.',
      coachWellbeingRating: 2,
      coachWellbeingNotes: 'Frustrating one — plan felt too advanced for where the group is at.',
      actions: const [
        'Rebuild pressing triggers from a single, simple cue before next session',
        'Walk through the trigger on a whiteboard before going full speed on the pitch',
      ],
    ),
  ];

  /// Seeded onto 'Riverside Lions' (t1) — the squad now lives inside its
  /// team, so every sample player needs a home team.
  static const List<Player> squad = [
    Player(id: 'p1', teamId: 't1', firstName: 'Aiden', lastName: 'Clarke', position: 'Goalkeeper'),
    Player(id: 'p2', teamId: 't1', firstName: 'Leo', lastName: 'Mitchell', position: 'Defender'),
    Player(id: 'p3', teamId: 't1', firstName: 'Marcus', lastName: 'Wright', position: 'Defender'),
    Player(id: 'p4', teamId: 't1', firstName: 'Theo', lastName: 'Baker', position: 'Midfielder'),
    Player(id: 'p5', teamId: 't1', firstName: 'Kai', lastName: 'Hughes', position: 'Midfielder'),
    Player(id: 'p6', teamId: 't1', firstName: 'Ollie', lastName: 'Turner', position: 'Midfielder'),
    Player(id: 'p7', teamId: 't1', firstName: 'Zack', lastName: 'Bennett', position: 'Forward'),
    Player(id: 'p8', teamId: 't1', firstName: 'Finn', lastName: 'Harris', position: 'Forward'),
  ];

  static const List<String> ageGroupChips = ['U12', 'U14', 'U16'];

  /// Dashboard stat cards, taken directly from the app's screenshots.
  static const int sessionsThisMonth = 3;
  static const double avgSessionRating = 3.5; // out of 5 — matches reflections avg
  static const int upcomingSessionsScheduled = 2;

  /// Progress tab stat cards.
  static const int progressSessionsCompleted = 3;
  static const double progressTotalHoursCoached = 4;
  static const int progressReflectionsWritten = 4;

  /// The soonest upcoming planned session — sorted by date rather than just
  /// taking the first "planned" entry in list order, so this stays correct
  /// regardless of the order sessions are added in.
  static Session get nextSession {
    final planned = sessions.where((s) => s.status == SessionStatus.planned).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return planned.first;
  }
}
