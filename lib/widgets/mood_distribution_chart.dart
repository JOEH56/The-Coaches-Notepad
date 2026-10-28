import 'package:flutter/material.dart';
import '../models/reflection_status.dart';
import '../theme/app_theme.dart';

/// Horizontal bar chart: how many sessions were rated each status.
class MoodDistributionChart extends StatelessWidget {
  final Map<ReflectionStatus, int> counts;

  const MoodDistributionChart({super.key, required this.counts});

  @override
  Widget build(BuildContext context) {
    int maxCount = 1;
    for (final c in counts.values) {
      if (c > maxCount) maxCount = c;
    }

    return Column(
      children: ReflectionStatus.values.map((status) {
        final count = counts[status] ?? 0;
        final double fraction = count / maxCount;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              SizedBox(
                width: 68,
                child: Text(
                  status.label,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        Container(
                          height: 10,
                          width: constraints.maxWidth * fraction,
                          decoration: BoxDecoration(
                            color: status.color,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 18,
                child: Text(
                  '$count',
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
