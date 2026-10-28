import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Interactive 1-5 star picker for the reflection form — tap a star to set
/// the rating, tap the currently-selected star again to clear it back to
/// 0 ("not rated"). Unlike [StarRating] (display-only, supports halves),
/// this is a whole-number input control.
class RatingInput extends StatelessWidget {
  final int value; // 0 (unrated) - 5
  final ValueChanged<int> onChanged;
  final double size;

  const RatingInput({super.key, required this.value, required this.onChanged, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final starValue = i + 1;
        final filled = starValue <= value;
        return GestureDetector(
          onTap: () => onChanged(value == starValue ? 0 : starValue),
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_border_rounded,
              size: size,
              color: AppColors.accentGold,
            ),
          ),
        );
      }),
    );
  }
}
