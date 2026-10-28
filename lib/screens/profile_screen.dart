import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../data/sample_data.dart';
import '../models/team.dart';
import '../theme/app_theme.dart';
import '../widgets/section_label.dart';
import 'team_squad_screen.dart';

/// Coach's Profile — set up the teams you coach, each with an age group and
/// a colour. That colour then carries through to Session Builder's pitch
/// diagram, so every session for a team always shows in the same colour.
/// Each team's squad lives inside it — tap a team to open its squad list.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    AppState.instance.addListener(_onAppStateChanged);
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_onAppStateChanged);
    super.dispose();
  }

  void _onAppStateChanged() => setState(() {});

  void _openTeamSquad(Team team) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TeamSquadScreen(team: team)),
    );
  }

  void _openTeamForm({Team? editing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TeamFormSheet(editing: editing),
    );
  }

  void _confirmDelete(Team team) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceRaised,
        title: const Text('Remove team?', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Remove "${team.name}"? Sessions already assigned to it will keep showing its colour.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              AppState.instance.removeTeam(team.id);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Remove', style: TextStyle(color: AppColors.statusDifficult)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final teams = AppState.instance.teams;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accentGold, width: 1.5),
                ),
                child: Text(
                  SampleData.coachFirstName.isNotEmpty ? SampleData.coachFirstName[0].toUpperCase() : '?',
                  style: TextStyle(fontFamily: AppFonts.heading, color: AppColors.accentGold, fontSize: 26, fontWeight: FontWeight.w400),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      SampleData.coachFirstName,
                      style: TextStyle(fontFamily: AppFonts.heading, color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 2),
                    const Text('Grassroots coach', style: TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SectionLabel(
            text: 'My teams',
            trailing: TextButton.icon(
              onPressed: () => _openTeamForm(),
              icon: const Icon(Icons.add_rounded, size: 16, color: AppColors.accentGold),
              label: const Text('Add Team', style: TextStyle(color: AppColors.accentGold, fontSize: 12.5)),
            ),
          ),
          const SizedBox(height: 10),
          if (teams.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'No teams yet. Add the teams you coach so you can tell sessions apart and match each one\'s colour in Session Builder.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
              ),
            )
          else
            ...teams.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TeamCard(
                    team: t,
                    squadSize: AppState.instance.squadForTeam(t.id).length,
                    onTap: () => _openTeamSquad(t),
                    onEdit: () => _openTeamForm(editing: t),
                    onDelete: () => _confirmDelete(t),
                  ),
                )),
          const SizedBox(height: 4),
          const Text(
            'Tap a team to build its squad list — pick the starting XI from it on Matchday. A team\'s colour is also used for its players on the Session Builder pitch diagram.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 11.5, height: 1.4),
          ),
        ],
      ),
    );
  }
}

/// A team's card on Profile — tapping it (anywhere but the edit/delete
/// icons) opens that team's own squad list, since the squad now lives
/// inside its team rather than as one flat roster.
class _TeamCard extends StatelessWidget {
  final Team team;
  final int squadSize;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _TeamCard({required this.team, required this.squadSize, required this.onTap, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: team.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(team.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14.5)),
                    const SizedBox(height: 2),
                    Text(
                      '${team.ageGroup} · $squadSize ${squadSize == 1 ? 'player' : 'players'}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 19),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.statusDifficult, size: 19),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Add/edit-team bottom sheet: name, age group (preset chips), colour swatch.
class _TeamFormSheet extends StatefulWidget {
  final Team? editing;
  const _TeamFormSheet({this.editing});

  @override
  State<_TeamFormSheet> createState() => _TeamFormSheetState();
}

class _TeamFormSheetState extends State<_TeamFormSheet> {
  late final TextEditingController _nameController;
  late String _ageGroup;
  late Color _color;

  @override
  void initState() {
    super.initState();
    final editing = widget.editing;
    _nameController = TextEditingController(text: editing?.name ?? '');
    _ageGroup = editing?.ageGroup ?? ageGroupPresets.first;
    _color = editing?.color ?? teamColorPalette.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Give the team a name first.')),
      );
      return;
    }
    final editing = widget.editing;
    if (editing != null) {
      AppState.instance.updateTeam(editing.copyWith(name: name, ageGroup: _ageGroup, color: _color));
    } else {
      AppState.instance.addTeam(name: name, ageGroup: _ageGroup, color: _color);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editing != null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text(
              isEditing ? 'Edit Team' : 'Add Team',
              style: TextStyle(fontFamily: AppFonts.heading, color: AppColors.textPrimary, fontSize: 21, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 18),
            const Text('Team name', style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w700)),
            const SizedBox(height: 7),
            TextField(
              controller: _nameController,
              autofocus: !isEditing,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'e.g. Riverside Lions'),
            ),
            const SizedBox(height: 16),
            const Text('Age group', style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w700)),
            const SizedBox(height: 7),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: ageGroupPresets.map((g) {
                final selected = g == _ageGroup;
                return GestureDetector(
                  onTap: () => setState(() => _ageGroup = g),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.accentGold : AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: selected ? AppColors.accentGold : AppColors.border),
                    ),
                    child: Text(
                      g,
                      style: TextStyle(
                        color: selected ? AppColors.onAccent : AppColors.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Team colour', style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w700)),
            const SizedBox(height: 7),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: teamColorPalette.map((c) {
                final selected = c.value == _color.value;
                return GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(color: selected ? AppColors.textPrimary : AppColors.border, width: selected ? 2.5 : 1),
                    ),
                    child: selected
                        ? Icon(Icons.check_rounded, size: 16, color: c.computeLuminance() > 0.45 ? AppColors.onAccent : Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(isEditing ? 'Save Changes' : 'Add Team'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
