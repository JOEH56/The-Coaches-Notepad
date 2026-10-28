import 'package:flutter/material.dart';
import '../models/player.dart';
import '../theme/app_theme.dart';

/// One row in a squad roster list — shared by the Profile page (where the
/// squad is primarily built, alongside teams) and the Matchday tab (which
/// also flags who's currently in the starting XI via [trailingBadge]).
class SquadRow extends StatelessWidget {
  final Player player;
  final VoidCallback onRemove;
  final Widget? trailingBadge;

  const SquadRow({super.key, required this.player, required this.onRemove, this.trailingBadge});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.accentGold,
            child: Text(player.initials, style: const TextStyle(color: AppColors.onAccent, fontWeight: FontWeight.w800, fontSize: 11.5)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(player.fullName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.w600)),
                if (player.position != null)
                  Text(player.position!, style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
              ],
            ),
          ),
          if (trailingBadge != null) Padding(padding: const EdgeInsets.only(right: 6), child: trailingBadge!),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18),
          ),
        ],
      ),
    );
  }
}
