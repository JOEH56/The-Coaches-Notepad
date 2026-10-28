import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../models/match_reflection.dart';
import '../models/next_step_action.dart';
import '../models/player.dart';
import '../models/reflection.dart';
import '../models/team.dart';

/// App-wide mutable state that isn't tied to one screen — the coach's teams
/// (set up on the Profile page, consumed by Session Builder and anywhere a
/// session's team colour is shown), the reflections they've logged (seeded
/// from SampleData, then grown by the "Log Reflection" form), and which
/// reflection actions have been ticked off (consumed by the Dashboard's
/// "Next Steps" area and each reflection's own action checklist). Holds
/// everything in memory only, same "no backend yet" pattern as the rest of
/// the app; this is where Supabase-backed state will eventually live.
class AppState extends ChangeNotifier {
  AppState._internal();
  static final AppState instance = AppState._internal();

  int _teamIdCounter = 3;

  final List<Team> _teams = [
    const Team(id: 't1', name: 'Riverside Lions', ageGroup: 'U12', color: Color(0xFF7EB7ED)),
    const Team(id: 't2', name: 'Riverside Eagles', ageGroup: 'U14', color: Color(0xFF3FAE6A)),
  ];

  List<Team> get teams => List.unmodifiable(_teams);

  Team? teamById(String? id) {
    if (id == null) return null;
    for (final t in _teams) {
      if (t.id == id) return t;
    }
    return null;
  }

  void addTeam({required String name, required String ageGroup, required Color color}) {
    _teams.add(Team(id: 't${_teamIdCounter++}', name: name, ageGroup: ageGroup, color: color));
    notifyListeners();
  }

  void updateTeam(Team team) {
    final i = _teams.indexWhere((t) => t.id == team.id);
    if (i != -1) {
      _teams[i] = team;
      notifyListeners();
    }
  }

  void removeTeam(String id) {
    _teams.removeWhere((t) => t.id == id);
    // The squad lives inside its team, so it has nowhere to go once the
    // team itself is gone — drop it with the team rather than leave an
    // orphaned roster no screen can reach any more.
    _squad.removeWhere((p) => p.teamId == id);
    notifyListeners();
  }

  // --- Reflections ---------------------------------------------------------

  final List<Reflection> _reflections = List<Reflection>.from(SampleData.reflections);

  List<Reflection> get reflections => List.unmodifiable(_reflections);

  /// Whether [sessionId] already has a logged reflection — a session can
  /// only be reflected on once, so screens use this to hide/show the "Log
  /// Reflection" button.
  bool hasReflectionFor(String sessionId) => _reflections.any((r) => r.sessionId == sessionId);

  Reflection? get mostRecentReflection {
    if (_reflections.isEmpty) return null;
    return _reflections.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
  }

  void addReflection(Reflection reflection) {
    _reflections.add(reflection);
    notifyListeners();
  }

  // --- Reflection actions ("Next Steps") ---------------------------------

  final Set<String> _doneActionKeys = {};

  static String _keyFor(String reflectionId, int index) => '$reflectionId::$index';

  bool isActionDone(String key) => _doneActionKeys.contains(key);

  void setActionDone(String key, bool done) {
    if (done) {
      _doneActionKeys.add(key);
    } else {
      _doneActionKeys.remove(key);
    }
    notifyListeners();
  }

  /// Flattens every reflection's `actions` list into individual, orderable
  /// items with completion resolved — newest reflection first.
  List<NextStepAction> nextSteps() {
    final sorted = List<Reflection>.from(_reflections)..sort((a, b) => b.date.compareTo(a.date));
    final result = <NextStepAction>[];
    for (final r in sorted) {
      for (var i = 0; i < r.actions.length; i++) {
        final key = _keyFor(r.id, i);
        result.add(NextStepAction(
          key: key,
          text: r.actions[i],
          reflectionId: r.id,
          sessionTitle: r.sessionTitle,
          reflectionDate: r.date,
          done: isActionDone(key),
        ));
      }
    }
    return result;
  }

  // --- Squads ----------------------------------------------------------------
  //
  // Each team has its own squad — built from inside that team on Profile,
  // then picked from on Matchday — rather than one flat roster, so a coach
  // with several teams keeps each one's players separate.

  /// Hard cap on squad size, per team, enforced here and mirrored in the
  /// squad-list UI.
  static const int maxSquadSize = 18;

  int _squadIdCounter = 100;
  final List<Player> _squad = List<Player>.from(SampleData.squad);

  /// Every squad player belonging to [teamId], in the order they were added.
  List<Player> squadForTeam(String teamId) =>
      List.unmodifiable(_squad.where((p) => p.teamId == teamId));

  bool squadFullFor(String teamId) => squadForTeam(teamId).length >= maxSquadSize;

  /// Adds a player to [teamId]'s squad, up to [maxSquadSize]. Returns false
  /// (and adds nothing) once that team's squad is already full. First name
  /// and surname are both required — see [Player]'s own doc comment for why.
  bool addSquadPlayer({required String teamId, required String firstName, required String lastName, String? position}) {
    if (squadFullFor(teamId)) return false;
    _squad.add(Player(
      id: 'sq${_squadIdCounter++}',
      teamId: teamId,
      firstName: firstName,
      lastName: lastName,
      position: position,
    ));
    notifyListeners();
    return true;
  }

  void removeSquadPlayer(String id) {
    _squad.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // --- Matchday reflections --------------------------------------------------

  final List<MatchReflection> _matchReflections = [];

  List<MatchReflection> get matchReflections => List.unmodifiable(_matchReflections);

  void addMatchReflection(MatchReflection reflection) {
    _matchReflections.add(reflection);
    notifyListeners();
  }
}
