import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../models/session.dart';
import '../theme/app_theme.dart';
import '../widgets/pitch_diagram.dart';

/// Full-page view/editor for one specific session section's own tactics
/// diagram — reached by tapping that section on Session Detail (or from the
/// Session Builder while planning). Saving here mutates the section's
/// `diagram` field directly on the shared Session instance, so whichever
/// screen opened this one sees the update as soon as it's popped.
class SectionDiagramScreen extends StatelessWidget {
  final Session session;
  final int sectionIndex;

  const SectionDiagramScreen({super.key, required this.session, required this.sectionIndex});

  @override
  Widget build(BuildContext context) {
    final section = session.sections[sectionIndex];
    final team = AppState.instance.teamById(session.teamId);

    return Scaffold(
      appBar: AppBar(title: Text(section.drillName ?? section.phase)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          Text(section.phase, style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
          const SizedBox(height: 4),
          Text(
            '${section.durationMins} min · ${session.title}',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
          ),
          const SizedBox(height: 18),
          PitchDiagram(
            key: ValueKey('${session.id}-$sectionIndex'),
            sectionLabel: section.drillName ?? section.phase,
            teamColor: team?.color,
            teamName: team?.name,
            playerCount: session.playerCount,
            initialData: section.diagram,
            onSaved: (data) => section.diagram = data,
          ),
        ],
      ),
    );
  }
}
