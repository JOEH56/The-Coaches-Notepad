import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../models/formation.dart';
import '../models/match_reflection.dart';
import '../models/player.dart';
import '../models/reflection_status.dart';
import '../models/team.dart';
import '../theme/app_theme.dart';
import '../widgets/matchday_pitch.dart';
import '../widgets/rating_input.dart';
import '../widgets/section_label.dart';
import '../widgets/squad_player_sheet.dart';
import '../widgets/squad_row.dart';
import 'profile_screen.dart';

/// Matchday tab: pick which team is playing, build its squad (max
/// [AppState.maxSquadSize] — the squad lives inside its team, set up on
/// Profile), pick the formation it started in, tap pitch slots to assign
/// the starting XI (each token shows the player's initials, not a shirt
/// number — see [MatchdayPitch]), then log a post-match reflection
/// underneath, in the same shape as a session reflection. No backend yet —
/// same in-memory demo pattern as the rest of the app, persisted to
/// [AppState] for the session.
class MatchdayScreen extends StatefulWidget {
  const MatchdayScreen({super.key});

  @override
  State<MatchdayScreen> createState() => _MatchdayScreenState();
}

class _MatchdayScreenState extends State<MatchdayScreen> {
  Team? _selectedTeam;
  Formation _formation = formations.first;

  /// Formation slot index -> squad player id.
  final Map<int, String> _lineup = {};

  final _opponentController = TextEditingController();
  int _performanceRating = 0;
  int _tacticalRating = 0;
  int _attitudeRating = 0;
  int _mannerRating = 0;
  final _wentWellController = TextEditingController();
  final _notPlannedController = TextEditingController();
  final _differentlyController = TextEditingController();
  final _focusController = TextEditingController();
  final List<TextEditingController> _actionControllers = [TextEditingController()];

  @override
  void initState() {
    super.initState();
    AppState.instance.addListener(_onAppStateChanged);
    _syncSelectedTeam();
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_onAppStateChanged);
    _opponentController.dispose();
    _wentWellController.dispose();
    _notPlannedController.dispose();
    _differentlyController.dispose();
    _focusController.dispose();
    for (final c in _actionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onAppStateChanged() => setState(_syncSelectedTeam);

  /// Keeps [_selectedTeam] pointing at a real team — defaults to the first
  /// one the coach has, and falls back if the selected team was renamed or
  /// removed elsewhere (e.g. from Profile) while this tab was open.
  void _syncSelectedTeam() {
    final teams = AppState.instance.teams;
    if (_selectedTeam == null || !teams.any((t) => t.id == _selectedTeam!.id)) {
      _selectedTeam = teams.isEmpty ? null : teams.first;
    } else {
      _selectedTeam = teams.firstWhere((t) => t.id == _selectedTeam!.id);
    }
  }

  void _changeTeam(Team team) {
    if (team.id == _selectedTeam?.id) return;
    setState(() {
      _selectedTeam = team;
      // A different team means a different squad — the old lineup's
      // player ids wouldn't mean anything here.
      _lineup.clear();
    });
  }

  Set<String> get _assignedIds => _lineup.values.toSet();

  Player? _playerById(String id) {
    final team = _selectedTeam;
    if (team == null) return null;
    for (final p in AppState.instance.squadForTeam(team.id)) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Confirms, then empties every filled slot in the starting XI in one
  /// tap — for when a coach has made a mess of the lineup and wants to
  /// start the assignments over rather than remove each player by hand.
  void _confirmClearLineup() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Clear pitch?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'This empties every position in the starting XI — your squad list is unaffected. Can\'t be undone.',
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
              setState(() => _lineup.clear());
            },
            child: const Text('Clear Pitch', style: TextStyle(color: AppColors.statusDifficult, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _changeFormation(Formation f) {
    if (f == _formation) return;
    setState(() {
      _formation = f;
      // The shape changed, so slot indices no longer line up with roles —
      // start the starting XI fresh rather than carry over a mismatch.
      _lineup.clear();
    });
  }

  void _onSlotTap(int slotIndex) {
    final currentId = _lineup[slotIndex];
    if (currentId != null) {
      _showSlotOptions(slotIndex);
    } else {
      _showPlayerPicker(slotIndex);
    }
  }

  void _showPlayerPicker(int slotIndex) {
    final team = _selectedTeam;
    final available = team == null
        ? <Player>[]
        : AppState.instance.squadForTeam(team.id).where((p) => !_assignedIds.contains(p.id)).toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_formation.slots[slotIndex].role} — pick a player',
                  style: TextStyle(fontFamily: AppFonts.subheading, color: AppColors.accentGold, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                if (available.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Every squad player is already in the starting XI. Add more players to your squad, or remove one from the pitch first.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 320),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: available.length,
                      itemBuilder: (context, i) {
                        final p = available[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 17,
                            backgroundColor: AppColors.accentGold,
                            child: Text(p.initials, style: const TextStyle(color: AppColors.onAccent, fontWeight: FontWeight.w800, fontSize: 12)),
                          ),
                          title: Text(p.fullName, style: const TextStyle(color: AppColors.textPrimary)),
                          subtitle: p.position != null ? Text(p.position!, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)) : null,
                          onTap: () {
                            setState(() => _lineup[slotIndex] = p.id);
                            Navigator.pop(sheetContext);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSlotOptions(int slotIndex) {
    final player = _playerById(_lineup[slotIndex] ?? '');
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (player != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(player.fullName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
              ListTile(
                leading: const Icon(Icons.swap_horiz_rounded, color: AppColors.accentGold),
                title: const Text('Swap player', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  setState(() => _lineup.remove(slotIndex));
                  _showPlayerPicker(slotIndex);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close_rounded, color: AppColors.statusDifficult),
                title: const Text('Remove from lineup', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () {
                  setState(() => _lineup.remove(slotIndex));
                  Navigator.pop(sheetContext);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  static ReflectionStatus _statusForScore(int score) {
    if (score >= 18) return ReflectionStatus.excellent;
    if (score >= 14) return ReflectionStatus.good;
    if (score >= 10) return ReflectionStatus.neutral;
    if (score >= 6) return ReflectionStatus.tough;
    return ReflectionStatus.difficult;
  }

  void _addActionField() => setState(() => _actionControllers.add(TextEditingController()));

  void _removeActionField(int i) => setState(() {
        _actionControllers[i].dispose();
        _actionControllers.removeAt(i);
      });

  void _submitMatchReflection() {
    if (_performanceRating == 0 || _tacticalRating == 0 || _attitudeRating == 0 || _mannerRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please rate all four dimensions before saving.')),
      );
      return;
    }

    final score = _performanceRating + _tacticalRating + _attitudeRating + _mannerRating;
    final actions = _actionControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
    final opponent = _opponentController.text.trim();

    final reflection = MatchReflection(
      id: 'mr${DateTime.now().millisecondsSinceEpoch}',
      matchTitle: opponent.isEmpty ? 'Matchday' : 'vs $opponent',
      date: DateTime.now(),
      formationName: _formation.name,
      ratingTeamPerformance: _performanceRating,
      ratingTacticalExecution: _tacticalRating,
      ratingPlayerAttitude: _attitudeRating,
      ratingCoachingManner: _mannerRating,
      overallStatus: _statusForScore(score),
      whatWentWell: _wentWellController.text.trim(),
      whatDidntGoAsPlanned: _notPlannedController.text.trim(),
      whatWouldYouDoDifferently: _differentlyController.text.trim(),
      focusNextMatch: _focusController.text.trim(),
      actions: actions,
    );

    AppState.instance.addMatchReflection(reflection);

    setState(() {
      _performanceRating = 0;
      _tacticalRating = 0;
      _attitudeRating = 0;
      _mannerRating = 0;
      _opponentController.clear();
      _wentWellController.clear();
      _notPlannedController.clear();
      _differentlyController.clear();
      _focusController.clear();
      for (final c in _actionControllers) {
        c.dispose();
      }
      _actionControllers
        ..clear()
        ..add(TextEditingController());
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Match reflection saved.')),
    );
  }

  /// Team picker — the squad and starting XI below both come from whichever
  /// team is selected here, since the squad now lives inside its team
  /// (built on Profile) rather than as one flat roster.
  Widget _buildTeamSection() {
    final teams = AppState.instance.teams;
    if (teams.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add a team on your Profile first — Matchday picks its squad from a team\'s own roster.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
                child: const Text('Go to Profile'),
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(text: 'Team'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: teams.map((t) {
            return ChoiceChip(
              label: Text(t.name),
              selected: t.id == _selectedTeam?.id,
              onSelected: (_) => _changeTeam(t),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSquadSection() {
    final team = _selectedTeam;
    if (team == null) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (context, _) {
        final squad = AppState.instance.squadForTeam(team.id);
        final full = AppState.instance.squadFullFor(team.id);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel(
              text: '${team.name} Squad (${squad.length}/${AppState.maxSquadSize})',
              trailing: TextButton.icon(
                onPressed: full ? null : () => showAddSquadPlayerSheet(context, team.id),
                icon: Icon(Icons.add_rounded, size: 16, color: full ? AppColors.textMuted : AppColors.accentGold),
                label: Text('Add Player', style: TextStyle(color: full ? AppColors.textMuted : AppColors.accentGold, fontSize: 12.5)),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              full ? 'Squad is full — remove a player to add another.' : 'Up to ${AppState.maxSquadSize} players.',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5),
            ),
            const SizedBox(height: 10),
            if (squad.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No players yet — add this team\'s squad to pick a starting XI.', style: TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
              )
            else
              ...squad.map((p) => SquadRow(
                    player: p,
                    trailingBadge: _lineup.containsValue(p.id)
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: AppColors.statusGood.withOpacity(0.18), borderRadius: BorderRadius.circular(8)),
                            child: const Text('Starting', style: TextStyle(color: AppColors.statusGood, fontSize: 10.5, fontWeight: FontWeight.w700)),
                          )
                        : null,
                    onRemove: () {
                      setState(() => _lineup.removeWhere((_, id) => id == p.id));
                      AppState.instance.removeSquadPlayer(p.id);
                    },
                  )),
          ],
        );
      },
    );
  }

  Widget _buildFormationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(text: 'Formation'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: formations.map((f) {
            return ChoiceChip(
              label: Text(f.name),
              selected: f == _formation,
              onSelected: (_) => _changeFormation(f),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPitchSection() {
    final team = _selectedTeam;
    if (team == null) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (context, _) {
        final squad = AppState.instance.squadForTeam(team.id);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel(
              text: 'Starting XI',
              trailing: _lineup.isEmpty
                  ? null
                  : TextButton.icon(
                      onPressed: _confirmClearLineup,
                      icon: const Icon(Icons.restart_alt_rounded, size: 16, color: AppColors.statusDifficult),
                      label: const Text('Clear Pitch', style: TextStyle(color: AppColors.statusDifficult, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_lineup.length} / 11 positions filled — tap a slot to assign a player.',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5),
            ),
            const SizedBox(height: 10),
            MatchdayPitch(
              formation: _formation,
              lineup: _lineup,
              squad: squad,
              onSlotTap: _onSlotTap,
            ),
          ],
        );
      },
    );
  }

  Widget _buildReflectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(text: 'Match Reflection'),
        const SizedBox(height: 4),
        const Text(
          'Same shape as your session reflections — rate the match and capture next steps.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 11.5),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _opponentController,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'Opponent (optional)'),
        ),
        const SizedBox(height: 18),
        _RatingRow(label: 'Team Performance', value: _performanceRating, onChanged: (v) => setState(() => _performanceRating = v)),
        _RatingRow(label: 'Tactical Execution', value: _tacticalRating, onChanged: (v) => setState(() => _tacticalRating = v)),
        _RatingRow(label: 'Player Attitude', value: _attitudeRating, onChanged: (v) => setState(() => _attitudeRating = v)),
        _RatingRow(label: 'Coaching Manner', value: _mannerRating, onChanged: (v) => setState(() => _mannerRating = v)),
        const SizedBox(height: 18),
        const SectionLabel(text: 'What went well'),
        const SizedBox(height: 8),
        TextField(
          controller: _wentWellController,
          maxLines: 3,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'What worked well this match?'),
        ),
        const SizedBox(height: 16),
        const SectionLabel(text: 'What didn\'t go as planned'),
        const SizedBox(height: 8),
        TextField(
          controller: _notPlannedController,
          maxLines: 3,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'What didn\'t go the way you expected?'),
        ),
        const SizedBox(height: 16),
        const SectionLabel(text: 'What would you do differently'),
        const SizedBox(height: 8),
        TextField(
          controller: _differentlyController,
          maxLines: 3,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'What would you change next time?'),
        ),
        const SizedBox(height: 16),
        const SectionLabel(text: 'Focus for next match'),
        const SizedBox(height: 8),
        TextField(
          controller: _focusController,
          maxLines: 2,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'What\'s the headline focus for next time?'),
        ),
        const SizedBox(height: 18),
        SectionLabel(
          text: 'Your actions',
          trailing: TextButton.icon(
            onPressed: _addActionField,
            icon: const Icon(Icons.add_rounded, size: 16, color: AppColors.accentGold),
            label: const Text('Add Action', style: TextStyle(color: AppColors.accentGold, fontSize: 12.5)),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Concrete next steps — these show up on your Dashboard until you tick them off.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 11.5),
        ),
        const SizedBox(height: 10),
        ...List.generate(_actionControllers.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _actionControllers[i],
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(hintText: 'e.g. Work on defensive shape from goal kicks'),
                  ),
                ),
                if (_actionControllers.length > 1)
                  IconButton(
                    onPressed: () => _removeActionField(i),
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
                  ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitMatchReflection,
            child: const Text('Save Match Reflection'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasTeam = _selectedTeam != null;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        Text('Matchday', style: TextStyle(fontFamily: AppFonts.heading, color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.w400)),
        const SizedBox(height: 4),
        const Text('Pick a team, build its squad, set the starting XI, and reflect on the match.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        const SizedBox(height: 22),
        _buildTeamSection(),
        if (hasTeam) ...[
          const SizedBox(height: 26),
          _buildSquadSection(),
          const SizedBox(height: 26),
          _buildFormationSection(),
          const SizedBox(height: 18),
          _buildPitchSection(),
        ],
        const SizedBox(height: 30),
        const Divider(color: AppColors.border),
        const SizedBox(height: 14),
        _buildReflectionSection(),
      ],
    );
  }
}

class _RatingRow extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  const _RatingRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5)),
          ),
          RatingInput(value: value, onChanged: onChanged, size: 24),
        ],
      ),
    );
  }
}
