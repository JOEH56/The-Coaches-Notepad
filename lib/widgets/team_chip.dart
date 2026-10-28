import 'package:flutter/material.dart';
import '../models/team.dart';
import '../theme/app_theme.dart';

/// Small colour dot + team name, used anywhere a session needs to show
/// which of the coach's teams (set up on their Profile) it belongs to.
class TeamMetaChip extends StatelessWidget {
  final Team team;
  final double fontSize;
  const TeamMetaChip({super.key, required this.team, this.fontSize = 12.5});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: team.color, shape: BoxShape.circle, border: Border.all(color: AppColors.border, width: 0.5)),
        ),
        const SizedBox(width: 5),
        Text(team.name, style: TextStyle(color: AppColors.textSecondary, fontSize: fontSize, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
