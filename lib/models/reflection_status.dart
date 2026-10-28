import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Overall status badge shown on a reflection card.
enum ReflectionStatus { excellent, good, neutral, tough, difficult }

extension ReflectionStatusX on ReflectionStatus {
  String get label {
    switch (this) {
      case ReflectionStatus.excellent:
        return 'Excellent';
      case ReflectionStatus.good:
        return 'Good';
      case ReflectionStatus.neutral:
        return 'Neutral';
      case ReflectionStatus.tough:
        return 'Tough';
      case ReflectionStatus.difficult:
        return 'Difficult';
    }
  }

  Color get color {
    switch (this) {
      case ReflectionStatus.excellent:
        return AppColors.statusExcellent;
      case ReflectionStatus.good:
        return AppColors.statusGood;
      case ReflectionStatus.neutral:
        return AppColors.statusNeutral;
      case ReflectionStatus.tough:
        return AppColors.statusTough;
      case ReflectionStatus.difficult:
        return AppColors.statusDifficult;
    }
  }
}
