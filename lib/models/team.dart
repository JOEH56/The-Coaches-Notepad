import 'package:flutter/material.dart';

/// A team the coach manages, set up on their Profile. Used to differentiate
/// sessions in the Session Planner, and the team's colour carries through to
/// the Session Builder's pitch diagram so a session always shows in the
/// coach's own team colours.
class Team {
  final String id;
  final String name;
  final String ageGroup;
  final Color color;

  const Team({
    required this.id,
    required this.name,
    required this.ageGroup,
    required this.color,
  });

  Team copyWith({String? name, String? ageGroup, Color? color}) {
    return Team(
      id: id,
      name: name ?? this.name,
      ageGroup: ageGroup ?? this.ageGroup,
      color: color ?? this.color,
    );
  }
}

/// Common grassroots age-group presets shown as quick-pick chips when
/// setting up a team. Coaches aren't limited to these — see [Team.ageGroup].
const List<String> ageGroupPresets = [
  'U7', 'U8', 'U9', 'U10', 'U11', 'U12', 'U13', 'U14', 'U15', 'U16', 'U17', 'U18', 'Adult',
];

/// Selectable team colours — kept distinct from one another and readable
/// against the app's navy background/pitch green.
const List<Color> teamColorPalette = [
  Color(0xFF7EB7ED), // brand sky blue
  Color(0xFFE0553C), // red
  Color(0xFF3FAE6A), // green
  Color(0xFFE08A3C), // orange
  Color(0xFFC792EA), // purple
  Color(0xFFF2C94C), // yellow
  Color(0xFF4DD0E1), // cyan
  Color(0xFFFFFFFF), // white
];
