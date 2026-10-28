import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/pitch_diagram_data.dart';
import '../theme/app_theme.dart';

/// Standard pitch proportions (in generic length units, not metres-exact —
/// grassroots pitches vary) used to draw the field ourselves rather than
/// relying on a photo: 68 wide x 105 long, goal-to-goal running top to
/// bottom. Every other marking is defined relative to these.
const double _pitchUnitsW = 68;
const double _pitchUnitsL = 105;
const double _boxDepth = 16.5;
const double _boxWidth = 40.32;
const double _sixDepth = 5.5;
const double _sixWidth = 18.32;
const double _centreCircleR = 9.15;
const double _penaltySpotInset = 11;
const double _cornerR = 1.0;
const double _goalWidth = 7.32;
const double _goalDepth = 2.0;

extension on PitchSize {
  String get label {
    switch (this) {
      case PitchSize.full:
        return 'Full Pitch';
      case PitchSize.half:
        return 'Half Pitch';
      case PitchSize.third:
        return '1/3 Pitch';
      case PitchSize.box:
        return 'Penalty Box';
    }
  }

  /// The window of the pitch (in pitch units, see above) shown for this
  /// mode — the board's own aspect ratio is derived from it, so switching
  /// modes actually redraws a correctly-proportioned crop of the pitch
  /// rather than zooming a fixed image. Every mode's bottom edge sits just
  /// past the goal line (and Full Pitch's top edge too) so the goal mouth,
  /// drawn just outside the boundary, is actually visible rather than
  /// clipped off.
  Rect get viewRect {
    switch (this) {
      case PitchSize.full:
        return const Rect.fromLTRB(0, -_goalDepth, _pitchUnitsW, _pitchUnitsL + _goalDepth);
      case PitchSize.half:
        return const Rect.fromLTRB(0, _pitchUnitsL / 2, _pitchUnitsW, _pitchUnitsL + _goalDepth);
      case PitchSize.third:
        return const Rect.fromLTRB(0, _pitchUnitsL - 35, _pitchUnitsW, _pitchUnitsL + _goalDepth);
      case PitchSize.box:
        return const Rect.fromLTRB(0, _pitchUnitsL - _boxDepth - 8, _pitchUnitsW, _pitchUnitsL + _goalDepth);
    }
  }
}

extension on PitchTool {
  String get label {
    switch (this) {
      case PitchTool.move:
        return 'Move';
      case PitchTool.pass:
        return 'Pass';
      case PitchTool.run:
        return 'Run';
      case PitchTool.dribble:
        return 'Dribble';
      case PitchTool.shoot:
        return 'Shoot';
      case PitchTool.line:
        return 'Line';
      case PitchTool.highlight:
        return 'Highlight Area';
      case PitchTool.remove:
        return 'Remove';
    }
  }

  IconData get icon {
    switch (this) {
      case PitchTool.move:
        return Icons.open_with_rounded;
      case PitchTool.pass:
        return Icons.arrow_right_alt_rounded;
      case PitchTool.run:
        return Icons.timeline_rounded;
      case PitchTool.dribble:
        return Icons.gesture_rounded;
      case PitchTool.shoot:
        return Icons.sports_soccer_rounded;
      case PitchTool.line:
        return Icons.horizontal_rule_rounded;
      case PitchTool.highlight:
        return Icons.highlight_alt_rounded;
      case PitchTool.remove:
        return Icons.close_rounded;
    }
  }

  bool get isLineTool =>
      this == PitchTool.pass || this == PitchTool.run || this == PitchTool.dribble || this == PitchTool.shoot || this == PitchTool.line;

  bool get isAreaTool => this == PitchTool.highlight;

  /// This tool's default line colour — seeds [_PitchDiagramState._lineColor]
  /// when the tool is first selected, and is also shown as the swatch dot
  /// next to the tool in the "Drawing tool" row. The coach can still pick
  /// any colour from the "Line colour" row afterwards.
  Color get lineColor {
    switch (this) {
      case PitchTool.pass:
        return const Color(0xFFF2F4F8);
      case PitchTool.run:
        return AppColors.statusGood;
      case PitchTool.dribble:
        return AppColors.accentGold;
      case PitchTool.shoot:
        return AppColors.statusDifficult;
      case PitchTool.line:
        return Colors.black;
      default:
        return AppColors.textPrimary;
    }
  }

  /// This tool's default line style — seeds [_PitchDiagramState._lineStyle]
  /// the same way [lineColor] seeds the colour. Also just a starting point,
  /// not a constraint: any tool can be drawn in any style.
  LineStyle get defaultLineStyle {
    switch (this) {
      case PitchTool.run:
        return LineStyle.dashed;
      case PitchTool.dribble:
        return LineStyle.wavy;
      default:
        return LineStyle.solid;
    }
  }

  /// This tool's default arrow choice — seeds [_PitchDiagramState._lineArrow]
  /// the same way [lineColor]/[defaultLineStyle] seed the colour/style. Plain
  /// "Line" annotations default to no arrowhead (they're often used to mark
  /// a boundary or a pass channel rather than a direction); every other
  /// drawing tool defaults to an arrow, since it already implies a
  /// direction. Either way, the coach can flip it from the "Arrow" row.
  bool get defaultHasArrow => this != PitchTool.line;
}

extension on LineStyle {
  String get label {
    switch (this) {
      case LineStyle.solid:
        return 'Solid';
      case LineStyle.dashed:
        return 'Dashed';
      case LineStyle.dotted:
        return 'Dotted';
      case LineStyle.wavy:
        return 'Wavy';
    }
  }
}

/// Swatches offered on the "Line colour" row — a deliberately short, legible
/// list rather than a full picker, since these need to read clearly against
/// the green pitch from across a phone screen.
const List<Color> _lineColorPalette = [
  Colors.white,
  Colors.black,
  AppColors.accentGold,
  AppColors.statusGood,
  AppColors.statusDifficult,
  AppColors.statusTough,
];

/// Picks black or white text for readable contrast against [background],
/// using the same luminance approach as Flutter's own ThemeData.estimateBrightnessForColor.
Color _contrastingTextColor(Color background) {
  return background.computeLuminance() > 0.45 ? AppColors.onAccent : Colors.white;
}

/// Public, reusable pitch-background painter widget — paints the exact same
/// hand-drawn pitch (mowed stripes, all standard markings) as the tactics
/// board above, cropped to [size]. Exposed so other screens — e.g. the
/// Matchday starting-XI pitch — can draw an identical pitch without
/// duplicating the markings logic.
class PitchBackground extends StatelessWidget {
  final PitchSize size;
  const PitchBackground({super.key, this.size = PitchSize.full});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _PitchFieldPainter(viewRect: size.viewRect));
  }
}

/// [size]'s width/height aspect ratio — exposed so other widgets can size an
/// `AspectRatio` to match [PitchBackground] without duplicating the
/// view-rect math (which lives in a private extension on [PitchSize]).
double pitchAspectRatio(PitchSize size) => size.viewRect.width / size.viewRect.height;

class _PitchPlayer {
  final String id;
  final int number;
  final PitchTeam team;
  Offset pos; // fractional 0..1 within the board
  _PitchPlayer({required this.id, required this.number, required this.team, required this.pos});
}

class _PitchLine {
  final PitchTool type;
  final LineStyle style;
  final Color color;
  final bool hasArrow;
  final Offset start; // fractional
  final Offset end; // fractional
  const _PitchLine({
    required this.type,
    required this.style,
    required this.color,
    required this.start,
    required this.end,
    this.hasArrow = true,
  });
}

class _PitchHighlight {
  final Offset a; // fractional corner
  final Offset b; // fractional opposite corner
  const _PitchHighlight({required this.a, required this.b});
}

/// Interactive tactics-board pitch diagram: pick a pitch size (a crisp,
/// correctly-proportioned drawn pitch — no photo involved), drag players
/// (two color-coded teams) into position, draw pass/run/dribble/shoot/line
/// annotations, and highlight zones in translucent white.
///
/// Dragging is implemented with a raw [Listener] rather than
/// [GestureDetector]'s pan callbacks. This widget normally lives inside a
/// scrolling page (session builder / session detail / reflection detail),
/// and a `PanGestureRecognizer` there can lose the gesture arena to the
/// ancestor `ListView`'s scroll recognizer, which made the tokens feel
/// unresponsive. `Listener` receives the full, raw pointer-event stream
/// unconditionally, so a drag started on a token or on the pitch always
/// reaches this widget.
class PitchDiagram extends StatefulWidget {
  /// Optional label (e.g. a session section's phase name) shown in the
  /// "Save Diagram" confirmation, so it's clear which plan the save applies
  /// to when a session has several diagrams.
  final String? sectionLabel;

  /// Team A's colour/name — normally the colour the coach picked for this
  /// session's team on their Profile, so the diagram always matches. Falls
  /// back to the brand accent blue and "Team A" when not supplied (e.g. no
  /// team assigned yet).
  final Color? teamColor;
  final String? teamName;

  /// The session's player count — when set (and there's no [initialData]
  /// yet), the board seeds exactly this many Team A counters, ready to drag
  /// into position, and the "Add" button for Team A stops once that many
  /// are on the pitch. Leaving it null keeps the old unlimited-add demo
  /// default (a 2v2 starting layout).
  final int? playerCount;

  /// A previously-saved board for this exact section, if there is one —
  /// reopening a section shows what was left there instead of a blank
  /// board.
  final PitchDiagramData? initialData;

  /// Called with a snapshot of the current board whenever "Save Diagram" is
  /// pressed, so the caller can persist it (typically onto that section).
  final ValueChanged<PitchDiagramData>? onSaved;

  const PitchDiagram({
    super.key,
    this.sectionLabel,
    this.teamColor,
    this.teamName,
    this.playerCount,
    this.initialData,
    this.onSaved,
  });

  @override
  State<PitchDiagram> createState() => _PitchDiagramState();
}

class _PitchDiagramState extends State<PitchDiagram> {
  PitchSize _size = PitchSize.full;
  PitchTool _tool = PitchTool.move;

  /// The pen currently in use for drawing — seeded from whichever tool was
  /// last selected (see [PitchTool.lineColor]/[PitchTool.defaultLineStyle]),
  /// but freely overridable from the "Line style"/"Line colour" rows so a
  /// coach isn't locked to one look per tool.
  LineStyle _lineStyle = LineStyle.solid;
  Color _lineColor = AppColors.textPrimary;
  bool _lineArrow = true;

  int _nextA = 1;
  int _nextB = 1;
  final List<_PitchPlayer> _players = [];
  int _idCounter = 1;

  final List<_PitchLine> _lines = [];
  final List<_PitchHighlight> _highlights = [];
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    if (data != null) {
      _size = data.size;
      _players.addAll(data.players.map(
        (p) => _PitchPlayer(id: p.id, number: p.number, team: p.team, pos: Offset(p.x, p.y)),
      ));
      _lines.addAll(data.lines.map(
        (l) => _PitchLine(
          type: l.type,
          style: l.style,
          color: Color(l.colorValue),
          hasArrow: l.hasArrow,
          start: Offset(l.startX, l.startY),
          end: Offset(l.endX, l.endY),
        ),
      ));
      _highlights.addAll(data.highlights.map(
        (h) => _PitchHighlight(a: Offset(h.ax, h.ay), b: Offset(h.bx, h.by)),
      ));
      // What was loaded is, by definition, exactly what was last saved.
      _saved = true;
    } else if (widget.playerCount != null && widget.playerCount! > 0) {
      _seedFromPlayerCount(widget.playerCount!);
    } else {
      _players.addAll([
        _PitchPlayer(id: 'a1', number: 1, team: PitchTeam.teamA, pos: const Offset(0.3, 0.7)),
        _PitchPlayer(id: 'a2', number: 2, team: PitchTeam.teamA, pos: const Offset(0.7, 0.7)),
        _PitchPlayer(id: 'b1', number: 1, team: PitchTeam.teamB, pos: const Offset(0.3, 0.3)),
        _PitchPlayer(id: 'b2', number: 2, team: PitchTeam.teamB, pos: const Offset(0.7, 0.3)),
      ]);
    }
    _recomputeCounters();
  }

  /// Lines up one counter per player entered for this session (capped at a
  /// sane roster size), spread along the bottom of the board ready to drag
  /// into position — rather than starting from the old fixed 2v2 demo.
  void _seedFromPlayerCount(int count) {
    _players.clear();
    final n = count.clamp(1, 24);
    for (int i = 0; i < n; i++) {
      final t = (i + 1) / (n + 1);
      _players.add(_PitchPlayer(id: 'a${i + 1}', number: i + 1, team: PitchTeam.teamA, pos: Offset(t, 0.9)));
    }
  }

  /// Keeps "next number to hand out" and "next id" consistent with whatever
  /// players are currently on the board (loaded, seeded, or default).
  void _recomputeCounters() {
    int maxA = 0, maxB = 0, maxId = 0;
    for (final p in _players) {
      if (p.team == PitchTeam.teamA && p.number > maxA) maxA = p.number;
      if (p.team == PitchTeam.teamB && p.number > maxB) maxB = p.number;
      final numeric = int.tryParse(p.id.replaceAll(RegExp(r'[^0-9]'), ''));
      if (numeric != null && numeric > maxId) maxId = numeric;
    }
    _nextA = maxA + 1;
    _nextB = maxB + 1;
    _idCounter = maxId + 1;
  }

  String? _draggingId;
  Offset? _downPx;
  Offset? _dragStartPx;
  Offset? _dragEndPx;

  static const double _tokenRadius = 12;
  static const double _hitRadius = 24; // generous tap/drag-pickup tolerance
  static const double _boardMaxWidth = 300; // keeps the board compact on phones

  Color get _teamAColor => widget.teamColor ?? AppColors.accentGold;
  Color get _teamAText => _contrastingTextColor(_teamAColor);
  String get _teamALabel => widget.teamName ?? 'Team A';
  static const Color _teamBColor = Colors.white;
  static const Color _teamBText = Color(0xFF0F2A4A);
  static const String _teamBLabel = 'Opposition';

  Color _colorFor(PitchTeam team) => team == PitchTeam.teamA ? _teamAColor : _teamBColor;
  Color _textColorFor(PitchTeam team) => team == PitchTeam.teamA ? _teamAText : _teamBText;

  void _addPlayer(PitchTeam team) {
    setState(() {
      final number = team == PitchTeam.teamA ? _nextA++ : _nextB++;
      _players.add(_PitchPlayer(
        id: 'p${_idCounter++}',
        number: number,
        team: team,
        pos: Offset(0.4 + (0.04 * (_idCounter % 3)), 0.5),
      ));
    });
  }

  _PitchPlayer? _nearestPlayer(Offset px, Size boardSize) {
    _PitchPlayer? best;
    double bestDist = double.infinity;
    for (final p in _players) {
      final actual = Offset(p.pos.dx * boardSize.width, p.pos.dy * boardSize.height);
      final d = (actual - px).distance;
      if (d < _hitRadius && d < bestDist) {
        best = p;
        bestDist = d;
      }
    }
    return best;
  }

  void _handlePointerDown(PointerDownEvent event, Size boardSize) {
    final px = event.localPosition;
    _downPx = px;
    if (_tool != PitchTool.remove) {
      final nearest = _nearestPlayer(px, boardSize);
      if (nearest != null) {
        setState(() => _draggingId = nearest.id);
        return;
      }
    }
    if (_tool.isLineTool || _tool.isAreaTool) {
      setState(() {
        _dragStartPx = px;
        _dragEndPx = px;
      });
    }
  }

  void _handlePointerMove(PointerMoveEvent event, Size boardSize) {
    if (_draggingId != null) {
      _PitchPlayer? p;
      for (final candidate in _players) {
        if (candidate.id == _draggingId) {
          p = candidate;
          break;
        }
      }
      if (p == null) return;
      final px = event.localPosition;
      setState(() {
        p!.pos = Offset(
          (px.dx / boardSize.width).clamp(0.0, 1.0),
          (px.dy / boardSize.height).clamp(0.0, 1.0),
        );
      });
    } else if (_dragStartPx != null) {
      setState(() => _dragEndPx = event.localPosition);
    }
  }

  void _handlePointerUp(PointerUpEvent event, Size boardSize) {
    if (_draggingId != null) {
      setState(() => _draggingId = null);
      _downPx = null;
      return;
    }
    if (_dragStartPx != null && _dragEndPx != null) {
      final start = _dragStartPx!;
      final end = _dragEndPx!;
      if ((end - start).distance > 14) {
        if (_tool.isAreaTool) {
          setState(() {
            _highlights.add(_PitchHighlight(
              a: Offset(start.dx / boardSize.width, start.dy / boardSize.height),
              b: Offset(end.dx / boardSize.width, end.dy / boardSize.height),
            ));
          });
        } else {
          setState(() {
            _lines.add(_PitchLine(
              type: _tool,
              style: _lineStyle,
              color: _lineColor,
              hasArrow: _lineArrow,
              start: Offset(start.dx / boardSize.width, start.dy / boardSize.height),
              end: Offset(end.dx / boardSize.width, end.dy / boardSize.height),
            ));
          });
        }
      }
      setState(() {
        _dragStartPx = null;
        _dragEndPx = null;
      });
      _downPx = null;
      return;
    }
    // A tap (minimal movement) with the Remove tool active removes the
    // nearest player under the tap point.
    if (_tool == PitchTool.remove && _downPx != null) {
      final upPx = event.localPosition;
      if ((upPx - _downPx!).distance < 12) {
        final nearest = _nearestPlayer(upPx, boardSize);
        if (nearest != null) setState(() => _players.remove(nearest));
      }
    }
    _downPx = null;
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    setState(() {
      _draggingId = null;
      _dragStartPx = null;
      _dragEndPx = null;
    });
    _downPx = null;
  }

  /// Confirms before wiping the board — the clear covers every player as
  /// well as every drawn mark, so it's a bigger step than "Clear markings"
  /// and worth a guard against an accidental tap.
  void _confirmClearPitch() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Clear pitch?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'This removes every player, line and highlight from the board and starts fresh — handy after a mistake, but it can\'t be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _clearPitch();
            },
            child: const Text('Clear Pitch', style: TextStyle(color: AppColors.statusDifficult, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  /// Wipes the board back to a blank starting point — every player, line
  /// and highlight gone, counters/ids reset to match — so a coach who's
  /// made a mess of a diagram can start over in one tap instead of undoing
  /// each mark by hand.
  void _clearPitch() {
    setState(() {
      _players.clear();
      _lines.clear();
      _highlights.clear();
      if (widget.playerCount != null && widget.playerCount! > 0) {
        _seedFromPlayerCount(widget.playerCount!);
      } else {
        _players.addAll([
          _PitchPlayer(id: 'a1', number: 1, team: PitchTeam.teamA, pos: const Offset(0.3, 0.7)),
          _PitchPlayer(id: 'a2', number: 2, team: PitchTeam.teamA, pos: const Offset(0.7, 0.7)),
          _PitchPlayer(id: 'b1', number: 1, team: PitchTeam.teamB, pos: const Offset(0.3, 0.3)),
          _PitchPlayer(id: 'b2', number: 2, team: PitchTeam.teamB, pos: const Offset(0.7, 0.3)),
        ]);
      }
      _recomputeCounters();
      _saved = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pitch cleared.')),
    );
  }

  void _saveDiagram() {
    final snapshot = PitchDiagramData(
      size: _size,
      players: _players.map((p) => DiagramPlayer(id: p.id, number: p.number, team: p.team, x: p.pos.dx, y: p.pos.dy)).toList(),
      lines: _lines
          .map((l) => DiagramLine(
                type: l.type,
                style: l.style,
                colorValue: l.color.value,
                hasArrow: l.hasArrow,
                startX: l.start.dx,
                startY: l.start.dy,
                endX: l.end.dx,
                endY: l.end.dy,
              ))
          .toList(),
      highlights: _highlights.map((h) => DiagramHighlight(ax: h.a.dx, ay: h.a.dy, bx: h.b.dx, by: h.b.dy)).toList(),
    );
    setState(() => _saved = true);
    widget.onSaved?.call(snapshot);
    final label = widget.sectionLabel;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(label != null ? 'Diagram saved for "$label".' : 'Diagram saved to this session.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pitch size', style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w700)),
        const SizedBox(height: 7),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: PitchSize.values.map((s) {
            final selected = s == _size;
            return _Chip(
              label: s.label,
              selected: selected,
              onTap: () => setState(() => _size = s),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _boardMaxWidth),
            child: AspectRatio(
            aspectRatio: _size.viewRect.width / _size.viewRect.height,
            child: LayoutBuilder(builder: (context, constraints) {
              final boardSize = Size(constraints.maxWidth, constraints.maxHeight);
              return ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (e) => _handlePointerDown(e, boardSize),
                  onPointerMove: (e) => _handlePointerMove(e, boardSize),
                  onPointerUp: (e) => _handlePointerUp(e, boardSize),
                  onPointerCancel: _handlePointerCancel,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.pitchGreen,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Stack(
                      children: [
                        // The pitch itself is drawn to scale for the
                        // selected size — switching modes redraws a
                        // correctly-proportioned crop rather than
                        // zooming/cropping a fixed image.
                        Positioned.fill(
                          child: CustomPaint(painter: _PitchFieldPainter(viewRect: _size.viewRect)),
                        ),
                        Positioned(
                          left: 8,
                          top: 8,
                          child: _SizeLabelChip(label: _size.label),
                        ),
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _HighlightsPainter(
                              highlights: _highlights,
                              previewA: _tool.isAreaTool ? _dragStartPx : null,
                              previewB: _tool.isAreaTool ? _dragEndPx : null,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _LinesPainter(
                              lines: _lines,
                              boardSize: boardSize,
                              previewTool: (_dragStartPx != null && _tool.isLineTool) ? _tool : null,
                              previewStyle: _lineStyle,
                              previewColor: _lineColor,
                              previewHasArrow: _lineArrow,
                              previewStart: _tool.isLineTool ? _dragStartPx : null,
                              previewEnd: _tool.isLineTool ? _dragEndPx : null,
                            ),
                          ),
                        ),
                        for (final p in _players)
                          Positioned(
                            left: p.pos.dx * boardSize.width - _tokenRadius,
                            top: p.pos.dy * boardSize.height - _tokenRadius,
                            child: IgnorePointer(
                              child: _PlayerToken(
                                number: p.number,
                                color: _colorFor(p.team),
                                textColor: _textColorFor(p.team),
                                radius: _tokenRadius,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text('Drawing tool', style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w700)),
        const SizedBox(height: 7),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: PitchTool.values.map((t) {
            final selected = t == _tool;
            return _Chip(
              label: t.label,
              icon: t.icon,
              selected: selected,
              dotColor: t.isLineTool ? t.lineColor : (t.isAreaTool ? Colors.white : null),
              onTap: () => setState(() {
                _tool = t;
                _saved = false;
                if (t.isLineTool) {
                  _lineStyle = t.defaultLineStyle;
                  _lineColor = t.lineColor;
                  _lineArrow = t.defaultHasArrow;
                }
              }),
            );
          }).toList(),
        ),
        if (_tool.isLineTool) ...[
          const SizedBox(height: 12),
          const Text('Line style', style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 7),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: LineStyle.values.map((s) {
              return _Chip(
                label: s.label,
                selected: s == _lineStyle,
                onTap: () => setState(() => _lineStyle = s),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          const Text('Line colour', style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 7),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: _lineColorPalette.map((c) {
              final selected = c.value == _lineColor.value;
              return GestureDetector(
                onTap: () => setState(() => _lineColor = c),
                child: Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(color: selected ? AppColors.accentGold : AppColors.border, width: selected ? 2.5 : 1),
                  ),
                  child: selected
                      ? Icon(Icons.check_rounded, size: 14, color: c.computeLuminance() > 0.45 ? AppColors.onAccent : Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          const Text('Arrow', style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 7),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _Chip(
                label: 'Arrow',
                icon: Icons.arrow_right_alt_rounded,
                selected: _lineArrow,
                onTap: () => setState(() => _lineArrow = true),
              ),
              _Chip(
                label: 'Plain line',
                icon: Icons.horizontal_rule_rounded,
                selected: !_lineArrow,
                onTap: () => setState(() => _lineArrow = false),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        Builder(builder: (context) {
          final teamACount = _players.where((p) => p.team == PitchTeam.teamA).length;
          final atRosterCap = widget.playerCount != null && teamACount >= widget.playerCount!;
          return Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: atRosterCap ? null : () => _addPlayer(PitchTeam.teamA),
                  icon: Container(width: 10, height: 10, decoration: BoxDecoration(color: _teamAColor, shape: BoxShape.circle)),
                  label: Text(
                    atRosterCap ? 'All $_teamALabel on pitch' : 'Add $_teamALabel',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _addPlayer(PitchTeam.teamB),
                  icon: const Icon(Icons.circle, size: 10, color: Colors.white),
                  label: const Text('Add $_teamBLabel', overflow: TextOverflow.ellipsis, maxLines: 1),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
                ),
              ),
            ],
          );
        }),
        if (widget.playerCount != null) ...[
          const SizedBox(height: 6),
          Text(
            '${_players.where((p) => p.team == PitchTeam.teamA).length} / ${widget.playerCount} $_teamALabel counters placed',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: _confirmClearPitch,
              icon: const Icon(Icons.restart_alt_rounded, size: 16, color: AppColors.statusDifficult),
              label: const Text('Clear Pitch', style: TextStyle(color: AppColors.statusDifficult, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
            if (_lines.isNotEmpty || _highlights.isNotEmpty)
              TextButton.icon(
                onPressed: () => setState(() {
                  _lines.clear();
                  _highlights.clear();
                }),
                icon: const Icon(Icons.layers_clear_rounded, size: 16, color: AppColors.textMuted),
                label: const Text('Clear markings', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _tool == PitchTool.move
              ? 'Drag a player to reposition them.'
              : _tool == PitchTool.remove
                  ? 'Tap a player to remove them.'
                  : _tool.isAreaTool
                      ? 'Drag on the pitch to highlight an area in white.'
                      : 'Drag on the pitch to draw a ${_tool.label.toLowerCase()} line. Switch to Move to reposition a player.',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5, height: 1.3),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _saveDiagram,
            icon: Icon(_saved ? Icons.check_rounded : Icons.save_outlined, size: 18, color: _saved ? AppColors.statusGood : null),
            label: Text(_saved ? 'Saved to session' : 'Save Diagram'),
          ),
        ),
      ],
    );
  }
}

/// Small pill in the corner of the board naming the current pitch-size mode
/// (e.g. "HALF PITCH"), since the crop itself is now the only other cue.
class _SizeLabelChip extends StatelessWidget {
  final String label;
  const _SizeLabelChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.85),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: AppFonts.subheading,
          color: AppColors.accentGold,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Draws the football pitch itself — mowed-stripe grass plus all standard
/// markings (touchlines, halfway line, centre circle, penalty/six-yard
/// boxes, penalty spots and arcs, corner arcs, goals) — scaled and cropped
/// to [viewRect] (see [PitchSize.viewRect]). Drawing it ourselves means
/// every pitch-size mode is a crisp, correctly-proportioned crop rather
/// than a zoomed/cropped photo.
class _PitchFieldPainter extends CustomPainter {
  final Rect viewRect;
  _PitchFieldPainter({required this.viewRect});

  double _scaleFor(Size size) => size.width / viewRect.width;

  Offset _pt(double x, double y, Size size) {
    final s = _scaleFor(size);
    return Offset((x - viewRect.left) * s, (y - viewRect.top) * s);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scale = _scaleFor(size);

    // Mowed-stripe background, bands running across the pitch's width.
    const stripeCount = 12;
    const stripeHeight = _pitchUnitsL / stripeCount;
    for (int i = 0; i < stripeCount; i++) {
      final yTop = i * stripeHeight;
      final rect = Rect.fromPoints(_pt(0, yTop, size), _pt(_pitchUnitsW, yTop + stripeHeight, size));
      canvas.drawRect(rect, Paint()..color = i.isEven ? AppColors.pitchGreen : AppColors.pitchGreenDark);
    }

    final line = Paint()
      ..color = Colors.white.withOpacity(0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final spot = Paint()..color = Colors.white.withOpacity(0.92);

    // Outer boundary (touchlines + goal lines).
    canvas.drawRect(Rect.fromPoints(_pt(0, 0, size), _pt(_pitchUnitsW, _pitchUnitsL, size)), line);

    // Halfway line + centre circle + centre spot.
    canvas.drawLine(_pt(0, _pitchUnitsL / 2, size), _pt(_pitchUnitsW, _pitchUnitsL / 2, size), line);
    canvas.drawCircle(_pt(_pitchUnitsW / 2, _pitchUnitsL / 2, size), _centreCircleR * scale, line);
    canvas.drawCircle(_pt(_pitchUnitsW / 2, _pitchUnitsL / 2, size), 0.5 * scale, spot);

    // Penalty boxes, six-yard boxes, spots and arcs — one set per end.
    for (final end in [0.0, _pitchUnitsL]) {
      final dir = end == 0 ? 1.0 : -1.0; // into the field
      final boxTop = end == 0 ? 0.0 : end - _boxDepth;
      final boxBottom = end == 0 ? _boxDepth : end;
      canvas.drawRect(
        Rect.fromPoints(
          _pt(_pitchUnitsW / 2 - _boxWidth / 2, boxTop, size),
          _pt(_pitchUnitsW / 2 + _boxWidth / 2, boxBottom, size),
        ),
        line,
      );
      final sixTop = end == 0 ? 0.0 : end - _sixDepth;
      final sixBottom = end == 0 ? _sixDepth : end;
      canvas.drawRect(
        Rect.fromPoints(
          _pt(_pitchUnitsW / 2 - _sixWidth / 2, sixTop, size),
          _pt(_pitchUnitsW / 2 + _sixWidth / 2, sixBottom, size),
        ),
        line,
      );

      final spotY = end == 0 ? _penaltySpotInset : end - _penaltySpotInset;
      final spotCentre = _pt(_pitchUnitsW / 2, spotY, size);
      canvas.drawCircle(spotCentre, 0.5 * scale, spot);

      // Penalty arc: only the segment of the circle (radius _centreCircleR,
      // centred on the spot) that bulges past the box line, away from goal.
      final boxEdgeY = end == 0 ? _boxDepth : end - _boxDepth;
      final d = (boxEdgeY - spotY).abs();
      if (d < _centreCircleR) {
        final dx = math.sqrt(_centreCircleR * _centreCircleR - d * d);
        final a1 = math.atan2(dir * d, -dx);
        final a2 = math.atan2(dir * d, dx);
        // The D-arc is always the minor arc (< 180°) between the two box/
        // circle intersection points — normalising to (-pi, pi] always
        // picks it, and it automatically bulges away from goal.
        double sweep = a2 - a1;
        while (sweep <= -math.pi) sweep += 2 * math.pi;
        while (sweep > math.pi) sweep -= 2 * math.pi;
        canvas.drawArc(
          Rect.fromCircle(center: spotCentre, radius: _centreCircleR * scale),
          a1,
          sweep,
          false,
          line,
        );
      }

      // Goal mouth, drawn just outside the boundary.
      final goalY0 = end == 0 ? -_goalDepth : end;
      final goalY1 = end == 0 ? 0.0 : end + _goalDepth;
      canvas.drawRect(
        Rect.fromPoints(
          _pt(_pitchUnitsW / 2 - _goalWidth / 2, goalY0, size),
          _pt(_pitchUnitsW / 2 + _goalWidth / 2, goalY1, size),
        ),
        line,
      );
    }

    // Corner arcs.
    for (final corner in [
      const Offset(0, 0),
      Offset(_pitchUnitsW, 0),
      Offset(0, _pitchUnitsL),
      Offset(_pitchUnitsW, _pitchUnitsL),
    ]) {
      final centre = _pt(corner.dx, corner.dy, size);
      final startAngle = corner.dx == 0 ? (corner.dy == 0 ? 0.0 : -math.pi / 2) : (corner.dy == 0 ? math.pi / 2 : math.pi);
      canvas.drawArc(Rect.fromCircle(center: centre, radius: _cornerR * scale), startAngle, math.pi / 2, false, line);
    }
  }

  @override
  bool shouldRepaint(covariant _PitchFieldPainter oldDelegate) => oldDelegate.viewRect != viewRect;
}

class _PlayerToken extends StatelessWidget {
  final int number;
  final Color color;
  final Color textColor;
  final double radius;

  const _PlayerToken({required this.number, required this.color, required this.textColor, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0x66000000), width: 1.5),
        boxShadow: const [BoxShadow(color: Color(0x552A2A2A), blurRadius: 3, offset: Offset(0, 1))],
      ),
      child: Text('$number', style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 12)),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData? icon;
  final Color? dotColor;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.selected, required this.onTap, this.icon, this.dotColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentGold : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? AppColors.accentGold : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 9,
                height: 9,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle, border: Border.all(color: AppColors.border, width: 0.5)),
              ),
            ] else if (icon != null) ...[
              Icon(icon, size: 14, color: selected ? AppColors.onAccent : AppColors.textSecondary),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.onAccent : AppColors.textSecondary,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Draws saved + in-progress translucent white "highlight area" zones,
/// underneath the tactical lines so lines stay legible over a highlight.
class _HighlightsPainter extends CustomPainter {
  final List<_PitchHighlight> highlights;
  final Offset? previewA;
  final Offset? previewB;

  _HighlightsPainter({required this.highlights, this.previewA, this.previewB});

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = Colors.white.withOpacity(0.38);
    final stroke = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    for (final h in highlights) {
      final rect = Rect.fromPoints(
        Offset(h.a.dx * size.width, h.a.dy * size.height),
        Offset(h.b.dx * size.width, h.b.dy * size.height),
      );
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));
      canvas.drawRRect(rrect, fill);
      canvas.drawRRect(rrect, stroke);
    }

    if (previewA != null && previewB != null) {
      final rect = Rect.fromPoints(previewA!, previewB!);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));
      canvas.drawRRect(rrect, Paint()..color = Colors.white.withOpacity(0.22));
      canvas.drawRRect(rrect, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _HighlightsPainter oldDelegate) => true;
}

/// Draws committed pass/run/dribble/shoot/line annotations, each with a
/// distinct color/stroke style and an arrowhead, plus a live preview while
/// dragging.
class _LinesPainter extends CustomPainter {
  final List<_PitchLine> lines;
  final Size boardSize;
  final PitchTool? previewTool;
  final LineStyle? previewStyle;
  final Color? previewColor;
  final bool? previewHasArrow;
  final Offset? previewStart;
  final Offset? previewEnd;

  _LinesPainter({
    required this.lines,
    required this.boardSize,
    this.previewTool,
    this.previewStyle,
    this.previewColor,
    this.previewHasArrow,
    this.previewStart,
    this.previewEnd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final line in lines) {
      _drawLine(
        canvas,
        Offset(line.start.dx * size.width, line.start.dy * size.height),
        Offset(line.end.dx * size.width, line.end.dy * size.height),
        line.type,
        line.style,
        line.color,
        line.hasArrow,
      );
    }
    if (previewTool != null && previewStyle != null && previewColor != null && previewStart != null && previewEnd != null) {
      _drawLine(canvas, previewStart!, previewEnd!, previewTool!, previewStyle!, previewColor!, previewHasArrow ?? true, preview: true);
    }
  }

  void _drawLine(Canvas canvas, Offset start, Offset end, PitchTool type, LineStyle style, Color baseColor, bool hasArrow, {bool preview = false}) {
    final color = preview ? baseColor.withOpacity(0.55) : baseColor.withOpacity(1.0);
    final strokeWidth = type == PitchTool.shoot ? 3.0 : (type == PitchTool.line ? 2.6 : 2.2);
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    switch (style) {
      case LineStyle.dashed:
        _drawDashed(canvas, start, end, paint);
        break;
      case LineStyle.dotted:
        _drawDotted(canvas, start, end, paint);
        break;
      case LineStyle.wavy:
        _drawWavy(canvas, start, end, paint);
        break;
      case LineStyle.solid:
        canvas.drawLine(start, end, paint);
    }
    if (hasArrow) _drawArrowhead(canvas, start, end, color);
  }

  void _drawDashed(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashLen = 6.0;
    const gapLen = 5.0;
    final total = (end - start).distance;
    if (total == 0) return;
    final dir = (end - start) / total;
    double covered = 0;
    while (covered < total) {
      final segEnd = math.min(covered + dashLen, total);
      canvas.drawLine(start + dir * covered, start + dir * segEnd, paint);
      covered += dashLen + gapLen;
    }
  }

  void _drawDotted(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dotSpacing = 7.0;
    final total = (end - start).distance;
    if (total == 0) return;
    final dir = (end - start) / total;
    final dotPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
    var covered = 0.0;
    while (covered <= total) {
      final point = start + dir * covered;
      canvas.drawCircle(point, paint.strokeWidth / 2.2, dotPaint);
      covered += dotSpacing;
    }
  }

  void _drawWavy(Canvas canvas, Offset start, Offset end, Paint paint) {
    final total = (end - start).distance;
    if (total < 1) return;
    final dir = (end - start) / total;
    final normal = Offset(-dir.dy, dir.dx);
    const waveLength = 10.0;
    const amplitude = 4.0;
    final path = Path()..moveTo(start.dx, start.dy);
    var t = 0.0;
    var side = 1;
    while (t < total) {
      final next = math.min(t + waveLength, total);
      final mid = start + dir * ((t + next) / 2) + normal * (amplitude * side);
      final end_ = start + dir * next;
      path.quadraticBezierTo(mid.dx, mid.dy, end_.dx, end_.dy);
      t = next;
      side *= -1;
    }
    canvas.drawPath(path, paint);
  }

  void _drawArrowhead(Canvas canvas, Offset start, Offset end, Color color) {
    final dir = end - start;
    if (dir.distance < 1) return;
    final angle = math.atan2(dir.dy, dir.dx);
    const arrowLen = 9.0;
    const arrowAngle = 0.45;
    final p1 = end - Offset(math.cos(angle - arrowAngle), math.sin(angle - arrowAngle)) * arrowLen;
    final p2 = end - Offset(math.cos(angle + arrowAngle), math.sin(angle + arrowAngle)) * arrowLen;
    final fill = Paint()..color = color;
    final path = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();
    canvas.drawPath(path, fill);
  }

  @override
  bool shouldRepaint(covariant _LinesPainter oldDelegate) => true;
}
