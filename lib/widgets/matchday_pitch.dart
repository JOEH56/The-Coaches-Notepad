import 'package:flutter/material.dart';
import '../models/formation.dart';
import '../models/pitch_diagram_data.dart';
import '../models/player.dart';
import '../theme/app_theme.dart';
import 'pitch_diagram.dart' show PitchBackground, pitchAspectRatio;

/// The Matchday starting-XI pitch: one tappable slot per [formation]
/// position (goalkeeper included), on the exact same hand-drawn full pitch
/// as the Session Diagram's tactics board (via [PitchBackground]), each
/// slot showing the assigned player's initials rather than a shirt number.
/// [lineup] maps a slot's index in [formation.slots] to a squad player id;
/// an unfilled slot just shows its role label (e.g. "CB"). Tapping any slot
/// calls [onSlotTap] with its index so the screen can offer a squad picker
/// (empty slot) or a swap/remove choice (filled slot).
class MatchdayPitch extends StatelessWidget {
  final Formation formation;
  final Map<int, String> lineup;
  final List<Player> squad;
  final Color teamColor;
  final ValueChanged<int> onSlotTap;

  const MatchdayPitch({
    super.key,
    required this.formation,
    required this.lineup,
    required this.squad,
    required this.onSlotTap,
    this.teamColor = AppColors.accentGold,
  });

  Player? _playerFor(String? id) {
    if (id == null) return null;
    for (final p in squad) {
      if (p.id == id) return p;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: AspectRatio(
          aspectRatio: pitchAspectRatio(PitchSize.full),
          child: LayoutBuilder(builder: (context, constraints) {
            final boardSize = Size(constraints.maxWidth, constraints.maxHeight);
            const radius = 15.0;
            return ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.pitchGreen,
                  border: Border.all(color: AppColors.border),
                ),
                child: Stack(
                  children: [
                    const Positioned.fill(child: PitchBackground(size: PitchSize.full)),
                    for (int i = 0; i < formation.slots.length; i++)
                      Positioned(
                        left: formation.slots[i].x * boardSize.width - radius,
                        top: formation.slots[i].y * boardSize.height - radius,
                        child: GestureDetector(
                          onTap: () => onSlotTap(i),
                          child: _SlotToken(
                            role: formation.slots[i].role,
                            label: _playerFor(lineup[i])?.initials,
                            color: teamColor,
                            radius: radius,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _SlotToken extends StatelessWidget {
  final String role;
  final String? label;
  final Color color;
  final double radius;

  const _SlotToken({required this.role, required this.label, required this.color, required this.radius});

  @override
  Widget build(BuildContext context) {
    final filled = label != null;
    return Container(
      width: radius * 2,
      height: radius * 2,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? color : AppColors.surface.withOpacity(0.55),
        shape: BoxShape.circle,
        border: Border.all(
          color: filled ? const Color(0x66000000) : Colors.white.withOpacity(0.7),
          width: filled ? 1.5 : 1.3,
        ),
        boxShadow: filled ? const [BoxShadow(color: Color(0x552A2A2A), blurRadius: 3, offset: Offset(0, 1))] : null,
      ),
      child: Text(
        label ?? role,
        style: TextStyle(
          color: filled ? (color.computeLuminance() > 0.45 ? AppColors.onAccent : Colors.white) : Colors.white.withOpacity(0.85),
          fontWeight: FontWeight.w800,
          fontSize: filled ? 12 : 9.5,
        ),
      ),
    );
  }
}
