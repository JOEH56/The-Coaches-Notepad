/// Standard starting formations offered on Matchday's formation picker, and
/// the fractional pitch position for each role within them. Declared here
/// rather than in a widget file, matching `pitch_diagram_data.dart`'s own
/// doc comment — this is plain data, not UI.
library;

/// One position slot in a [Formation] — a fractional (0..1) spot on a full
/// pitch, goal to goal, with the own goal at the bottom (y close to 1) and
/// the attacking end at the top (y close to 0) — the same convention the
/// Session Diagram's tactics board uses for its own default layout. [role]
/// is a short label (e.g. "CB", "RW") shown behind a slot until a player is
/// assigned to it.
class FormationSlot {
  final String role;
  final double x;
  final double y;

  const FormationSlot({required this.role, required this.x, required this.y});
}

/// A standard formation shape — just the XI's positions, not tied to any
/// particular match or squad. [slots] always has exactly 11 entries,
/// goalkeeper first.
class Formation {
  final String name;
  final List<FormationSlot> slots;

  const Formation({required this.name, required this.slots});
}

/// The formations on offer in Matchday — a short, grassroots-friendly list
/// rather than every formation in the book.
const List<Formation> formations = [
  Formation(name: '4-4-2', slots: [
    FormationSlot(role: 'GK', x: 0.5, y: 0.92),
    FormationSlot(role: 'LB', x: 0.15, y: 0.72),
    FormationSlot(role: 'CB', x: 0.35, y: 0.76),
    FormationSlot(role: 'CB', x: 0.65, y: 0.76),
    FormationSlot(role: 'RB', x: 0.85, y: 0.72),
    FormationSlot(role: 'LM', x: 0.15, y: 0.46),
    FormationSlot(role: 'CM', x: 0.38, y: 0.48),
    FormationSlot(role: 'CM', x: 0.62, y: 0.48),
    FormationSlot(role: 'RM', x: 0.85, y: 0.46),
    FormationSlot(role: 'ST', x: 0.38, y: 0.18),
    FormationSlot(role: 'ST', x: 0.62, y: 0.18),
  ]),
  Formation(name: '4-3-3', slots: [
    FormationSlot(role: 'GK', x: 0.5, y: 0.92),
    FormationSlot(role: 'LB', x: 0.15, y: 0.72),
    FormationSlot(role: 'CB', x: 0.35, y: 0.76),
    FormationSlot(role: 'CB', x: 0.65, y: 0.76),
    FormationSlot(role: 'RB', x: 0.85, y: 0.72),
    FormationSlot(role: 'CM', x: 0.3, y: 0.5),
    FormationSlot(role: 'CM', x: 0.5, y: 0.54),
    FormationSlot(role: 'CM', x: 0.7, y: 0.5),
    FormationSlot(role: 'LW', x: 0.18, y: 0.22),
    FormationSlot(role: 'ST', x: 0.5, y: 0.16),
    FormationSlot(role: 'RW', x: 0.82, y: 0.22),
  ]),
  Formation(name: '3-5-2', slots: [
    FormationSlot(role: 'GK', x: 0.5, y: 0.92),
    FormationSlot(role: 'CB', x: 0.28, y: 0.76),
    FormationSlot(role: 'CB', x: 0.5, y: 0.78),
    FormationSlot(role: 'CB', x: 0.72, y: 0.76),
    FormationSlot(role: 'LM', x: 0.12, y: 0.5),
    FormationSlot(role: 'CM', x: 0.35, y: 0.52),
    FormationSlot(role: 'CM', x: 0.5, y: 0.56),
    FormationSlot(role: 'CM', x: 0.65, y: 0.52),
    FormationSlot(role: 'RM', x: 0.88, y: 0.5),
    FormationSlot(role: 'ST', x: 0.38, y: 0.18),
    FormationSlot(role: 'ST', x: 0.62, y: 0.18),
  ]),
  Formation(name: '4-2-3-1', slots: [
    FormationSlot(role: 'GK', x: 0.5, y: 0.92),
    FormationSlot(role: 'LB', x: 0.15, y: 0.72),
    FormationSlot(role: 'CB', x: 0.35, y: 0.76),
    FormationSlot(role: 'CB', x: 0.65, y: 0.76),
    FormationSlot(role: 'RB', x: 0.85, y: 0.72),
    FormationSlot(role: 'CDM', x: 0.38, y: 0.58),
    FormationSlot(role: 'CDM', x: 0.62, y: 0.58),
    FormationSlot(role: 'LAM', x: 0.18, y: 0.34),
    FormationSlot(role: 'CAM', x: 0.5, y: 0.36),
    FormationSlot(role: 'RAM', x: 0.82, y: 0.34),
    FormationSlot(role: 'ST', x: 0.5, y: 0.16),
  ]),
  Formation(name: '3-4-3', slots: [
    FormationSlot(role: 'GK', x: 0.5, y: 0.92),
    FormationSlot(role: 'CB', x: 0.28, y: 0.76),
    FormationSlot(role: 'CB', x: 0.5, y: 0.78),
    FormationSlot(role: 'CB', x: 0.72, y: 0.76),
    FormationSlot(role: 'LM', x: 0.15, y: 0.48),
    FormationSlot(role: 'CM', x: 0.38, y: 0.5),
    FormationSlot(role: 'CM', x: 0.62, y: 0.5),
    FormationSlot(role: 'RM', x: 0.85, y: 0.48),
    FormationSlot(role: 'LW', x: 0.18, y: 0.2),
    FormationSlot(role: 'ST', x: 0.5, y: 0.16),
    FormationSlot(role: 'RW', x: 0.82, y: 0.2),
  ]),
];
