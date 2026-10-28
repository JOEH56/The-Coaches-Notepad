import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Small stat tile used in rows of 3–4 across Dashboard and Progress
/// (e.g. "3 / Sessions this month / completed").
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final String? subLabel;

  /// Optional extra content shown below the label/subLabel — e.g. a short
  /// "most recent" list on the Progress screen's stat tiles. Leaving this
  /// null keeps the compact tile used elsewhere (Dashboard) unchanged.
  final Widget? child;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.subLabel,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: AppFonts.heading,
              color: AppColors.accentGold,
              fontSize: 28,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
          if (subLabel != null) ...[
            const SizedBox(height: 2),
            Text(
              subLabel!,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5),
            ),
          ],
          if (child != null) ...[
            const SizedBox(height: 12),
            child!,
          ],
        ],
      ),
    );
  }
}
