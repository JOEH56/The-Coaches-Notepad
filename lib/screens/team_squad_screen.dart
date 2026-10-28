import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../models/team.dart';
import '../theme/app_theme.dart';
import '../widgets/section_label.dart';
import '../widgets/squad_player_sheet.dart';
import '../widgets/squad_row.dart';

/// A single team's squad list — opened by tapping that team's card on
/// Profile. The squad lives inside its team (rather than as one flat
/// roster shared by every team), capped at [AppState.maxSquadSize] and
/// built here so it's ready to pick a starting XI from on Matchday.
class TeamSquadScreen extends StatefulWidget {
  final Team team;
  const TeamSquadScreen({super.key, required this.team});

  @override
  State<TeamSquadScreen> createState() => _TeamSquadScreenState();
}

class _TeamSquadScreenState extends State<TeamSquadScreen> {
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

  @override
  Widget build(BuildContext context) {
    final team = widget.team;
    final squad = AppState.instance.squadForTeam(team.id);
    final full = AppState.instance.squadFullFor(team.id);

    return Scaffold(
      appBar: AppBar(title: Text('${team.name} Squad')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: team.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 1),
                ),
              ),
              const SizedBox(width: 10),
              Text(team.ageGroup, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 22),
          SectionLabel(
            text: 'Squad (${squad.length}/${AppState.maxSquadSize})',
            trailing: TextButton.icon(
              onPressed: full ? null : () => showAddSquadPlayerSheet(context, team.id),
              icon: Icon(Icons.add_rounded, size: 16, color: full ? AppColors.textMuted : AppColors.accentGold),
              label: Text('Add Player', style: TextStyle(color: full ? AppColors.textMuted : AppColors.accentGold, fontSize: 12.5)),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            full
                ? 'Squad is full — remove a player to add another.'
                : 'Up to ${AppState.maxSquadSize} players. First name and surname are both required, so players who share a first name stay easy to tell apart.',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5, height: 1.4),
          ),
          const SizedBox(height: 14),
          if (squad.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'No players yet. Build this team\'s squad here so it\'s ready to pick a starting XI from on Matchday.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
              ),
            )
          else
            ...squad.map((p) => SquadRow(
                  player: p,
                  onRemove: () => AppState.instance.removeSquadPlayer(p.id),
                )),
        ],
      ),
    );
  }
}
