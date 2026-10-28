import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../models/pitch_diagram_data.dart';
import '../models/team.dart';
import '../theme/app_theme.dart';
import '../widgets/pitch_diagram.dart';
import '../widgets/section_label.dart';
import 'profile_screen.dart';

class _DraftSection {
  final String id;
  String phase;
  int durationMins;

  /// What's actually happening in this phase, e.g. "Rondo Possession" —
  /// shown in place of the phase label wherever this section is displayed
  /// once set (see `SessionSection.drillName`).
  String drillName;

  /// Key coaching cues for this phase, e.g. "Cue off the pass to the weak
  /// side; front three stagger their press."
  String coachingPoints;

  /// This section's own saved diagram, set once the coach taps in and
  /// presses "Save Diagram" — see `_openSectionDiagram`.
  PitchDiagramData? diagram;

  _DraftSection({
    required this.id,
    required this.phase,
    required this.durationMins,
    this.drillName = '',
    this.coachingPoints = '',
    this.diagram,
  });
}

/// Session Builder form: title, objectives, duration/players, team chips,
/// and a repeating list of session-plan sections with an inline pitch
/// diagram for the main activity phases.
class SessionBuilderScreen extends StatefulWidget {
  const SessionBuilderScreen({super.key});

  @override
  State<SessionBuilderScreen> createState() => _SessionBuilderScreenState();
}

class _SessionBuilderScreenState extends State<SessionBuilderScreen> {
  final _titleController = TextEditingController();
  final _objectivesController = TextEditingController();
  final _durationController = TextEditingController();
  final _playersController = TextEditingController();

  Team? _selectedTeam;

  int _sectionIdCounter = 4;
  final List<_DraftSection> _sections = [
    _DraftSection(id: 's0', phase: 'Warm Up & Activation', durationMins: 10),
    _DraftSection(id: 's1', phase: 'Main Activity 1', durationMins: 20),
    _DraftSection(id: 's2', phase: 'Small Sided Game', durationMins: 25),
    _DraftSection(id: 's3', phase: 'Cool Down & Recovery', durationMins: 10),
  ];

  @override
  void initState() {
    super.initState();
    final teams = AppState.instance.teams;
    if (teams.isNotEmpty) _selectedTeam = teams.first;
    AppState.instance.addListener(_onAppStateChanged);
    // Live-updates the player count shown/used by each section's "Add a
    // diagram" entry point as soon as the coach fills it in.
    _playersController.addListener(_onPlayersChanged);
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_onAppStateChanged);
    _playersController.removeListener(_onPlayersChanged);
    _titleController.dispose();
    _objectivesController.dispose();
    _durationController.dispose();
    _playersController.dispose();
    super.dispose();
  }

  void _onPlayersChanged() => setState(() {});

  int? get _playerCount => int.tryParse(_playersController.text.trim());

  Future<void> _openSectionDiagram(_DraftSection section) async {
    final label = section.drillName.trim().isNotEmpty ? section.drillName.trim() : section.phase;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(label)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: [
              PitchDiagram(
                key: ValueKey(section.id),
                sectionLabel: label,
                teamColor: _selectedTeam?.color,
                teamName: _selectedTeam?.name,
                playerCount: _playerCount,
                initialData: section.diagram,
                onSaved: (data) => section.diagram = data,
              ),
            ],
          ),
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  void _onAppStateChanged() {
    // A team may have been added/edited/removed elsewhere (e.g. Profile).
    // Keep the selection valid and pick up any colour/name change.
    setState(() {
      final teams = AppState.instance.teams;
      if (_selectedTeam == null && teams.isNotEmpty) {
        _selectedTeam = teams.first;
      } else if (_selectedTeam != null) {
        final stillExists = AppState.instance.teamById(_selectedTeam!.id);
        _selectedTeam = stillExists ?? (teams.isNotEmpty ? teams.first : null);
      }
    });
  }

  void _addSection() {
    setState(() {
      _sections.add(_DraftSection(id: 's${_sectionIdCounter++}', phase: 'Main Activity 2', durationMins: 15));
    });
  }

  void _removeSection(int index) {
    setState(() => _sections.removeAt(index));
  }

  void _save(String status) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Session $status (demo — not yet connected to Supabase).')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session Builder')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          const SectionLabel(text: 'Session details'),
          const SizedBox(height: 10),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'e.g. Tuesday U14 Training'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _objectivesController,
            maxLines: 3,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Session objectives (e.g. improve first touch under pressure) — up to 3',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(hintText: 'Duration (min)'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _playersController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(hintText: 'Players'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SectionLabel(
            text: 'Team',
            trailing: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
              child: const Text('Manage teams →', style: TextStyle(color: AppColors.accentGold, fontSize: 12.5)),
            ),
          ),
          const SizedBox(height: 8),
          if (AppState.instance.teams.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'No teams yet — add one from your Profile so this session (and its pitch diagrams) use your team\'s colour.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.4),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppState.instance.teams.map((team) {
                final selected = team.id == _selectedTeam?.id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTeam = team),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.accentGold : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? AppColors.accentGold : AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: team.color,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border, width: 0.5),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          '${team.name} (${team.ageGroup})',
                          style: TextStyle(
                            color: selected ? AppColors.onAccent : AppColors.textSecondary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 26),
          SectionLabel(
            text: 'Session sections',
            trailing: TextButton.icon(
              onPressed: _addSection,
              icon: const Icon(Icons.add_rounded, size: 16, color: AppColors.accentGold),
              label: const Text('Add Section', style: TextStyle(color: AppColors.accentGold, fontSize: 12.5)),
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(_sections.length, (i) {
            final section = _sections[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.drag_indicator_rounded, color: AppColors.textMuted, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(section.phase, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13.5)),
                        ),
                        SizedBox(
                          width: 60,
                          child: TextFormField(
                            initialValue: '${section.durationMins}',
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 12.5),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              suffixText: 'min',
                            ),
                            onChanged: (v) {
                              final parsed = int.tryParse(v);
                              if (parsed != null) section.durationMins = parsed;
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: () => _removeSection(i),
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.statusDifficult, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: section.drillName,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                      decoration: const InputDecoration(
                        isDense: true,
                        labelText: 'Drill / activity',
                        hintText: 'e.g. Rondo Possession (optional)',
                      ),
                      onChanged: (v) => section.drillName = v,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: section.coachingPoints,
                      maxLines: 2,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                      decoration: const InputDecoration(
                        isDense: true,
                        labelText: 'Coaching points',
                        hintText: 'Key cues for this phase (optional)',
                      ),
                      onChanged: (v) => section.coachingPoints = v,
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Material(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => _openSectionDiagram(section),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              Icon(
                                section.diagram != null ? Icons.grid_on_rounded : Icons.grid_on_outlined,
                                size: 16,
                                color: section.diagram != null ? AppColors.accentGold : AppColors.textMuted,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                section.diagram != null ? 'Diagram saved — tap to edit' : 'Tap to add a diagram',
                                style: TextStyle(
                                  color: section.diagram != null ? AppColors.accentGold : AppColors.textMuted,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _save('saved as draft'),
                  child: const Text('Save as Draft'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _save('saved as planned'),
                  child: const Text('Save as Planned'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
