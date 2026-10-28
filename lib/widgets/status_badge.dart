import 'package:flutter/material.dart';
import '../models/reflection_status.dart';

/// Colored pill used on reflection cards: Excellent / Good / Neutral /
/// Tough / Difficult. Kept semantic (not navy) so it reads clearly against
/// the navy card surface.
class StatusBadge extends StatelessWidget {
  final ReflectionStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status.color.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: status.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(color: status.color, fontSize: 11.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
