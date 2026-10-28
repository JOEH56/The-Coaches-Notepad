import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Small-caps muted section label, e.g. "NEXT SESSION", "OBJECTIVES".
class SectionLabel extends StatelessWidget {
  final String text;
  final Widget? trailing;

  const SectionLabel({super.key, required this.text, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text.toUpperCase(),
          style: TextStyle(
            fontFamily: AppFonts.subheading,
            color: AppColors.accentGold,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
