import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Row of 5 accent-colored stars (filled/half/empty) for a rating out of 5.
class StarRating extends StatelessWidget {
  final double rating; // 0-5
  final double size;

  const StarRating({super.key, required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final threshold = i + 1;
        IconData icon;
        if (rating >= threshold) {
          icon = Icons.star_rounded;
        } else if (rating >= threshold - 0.5) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_border_rounded;
        }
        return Icon(icon, size: size, color: AppColors.accentGold);
      }),
    );
  }
}
