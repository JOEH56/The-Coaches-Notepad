/// Shared enums for the pitch tactics board (lib/widgets/pitch_diagram.dart)
/// plus a saved snapshot of a board (pitch size, player positions, drawn
/// lines/highlights). Declared here rather than in the widget file so a
/// plain model — `SessionSection` — can hold a `PitchDiagramData?` without
/// importing a widget file into the model layer.
library;

enum PitchSize { full, half, third, box }

enum PitchTool { move, pass, run, dribble, shoot, line, highlight, remove }

enum PitchTeam { teamA, teamB }

/// How a drawn line renders on the board — independent of which [PitchTool]
/// it was drawn with, so a coach can e.g. draw a "Pass" as a dashed line, or
/// a "Run" as solid, rather than being locked to one look per tool.
enum LineStyle { solid, dashed, dotted, wavy }

/// One counter's saved position, as a fraction (0..1) of the board.
class DiagramPlayer {
  final String id;
  final int number;
  final PitchTeam team;
  final double x;
  final double y;

  const DiagramPlayer({
    required this.id,
    required this.number,
    required this.team,
    required this.x,
    required this.y,
  });
}

/// One saved pass/run/dribble/shoot/line annotation, start/end as fractions
/// (0..1) of the board. [style], [colorValue] and [hasArrow] are the coach's
/// own choice at the time of drawing — [type] seeds sensible defaults for all
/// three when a drawing tool is first selected, but doesn't constrain them
/// afterwards. [colorValue] is a plain ARGB int (`Color.value`) rather than a
/// `Color`, keeping this model file free of a Flutter UI import.
class DiagramLine {
  final PitchTool type;
  final LineStyle style;
  final int colorValue;
  final bool hasArrow;
  final double startX;
  final double startY;
  final double endX;
  final double endY;

  const DiagramLine({
    required this.type,
    required this.style,
    required this.colorValue,
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    this.hasArrow = true,
  });
}

/// One saved highlighted zone, opposite corners as fractions (0..1) of the
/// board.
class DiagramHighlight {
  final double ax;
  final double ay;
  final double bx;
  final double by;

  const DiagramHighlight({required this.ax, required this.ay, required this.bx, required this.by});
}

/// A saved snapshot of a pitch diagram board — pitch size, every counter's
/// position, and any drawn lines/highlights — attached to a specific
/// session section (`SessionSection.diagram`) so a coach can tap back into
/// that section later and see exactly what they left there, rather than
/// starting from a blank board every time.
class PitchDiagramData {
  final PitchSize size;
  final List<DiagramPlayer> players;
  final List<DiagramLine> lines;
  final List<DiagramHighlight> highlights;

  const PitchDiagramData({
    required this.size,
    required this.players,
    this.lines = const [],
    this.highlights = const [],
  });
}
