import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../data/sample_data.dart';
import '../models/reflection.dart';
import '../models/session.dart';
import '../theme/app_theme.dart';
import '../widgets/star_rating.dart';
import '../widgets/status_badge.dart';
import '../widgets/team_chip.dart';
import 'section_diagram_screen.dart';

/// Full reflection detail page, pushed from a tap on a Reflect-tab card.
/// Shows the complete reflection (score, four-dimension breakdown, free-text
/// fields) and, at the bottom, the linked session's plan so a coach can see
/// exactly what was planned alongside how it went.
class ReflectionDetailScreen extends StatefulWidget {
  final Reflection reflection;
  const ReflectionDetailScreen({super.key, required this.reflection});

  @override
  State<ReflectionDetailScreen> createState() => _ReflectionDetailScreenState();
}

class _ReflectionDetailScreenState extends State<ReflectionDetailScreen> {
  Reflection get reflection => widget.reflection;

  @override
  void initState() {
    super.initState();
    AppState.instance.addListener(_onAppStateChanged);
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_onAppStateChanged);
    super.dispose();
  }

  void _onAppStateChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    Session? session;
    for (final s in SampleData.sessions) {
      if (s.id == reflection.sessionId) {
        session = s;
        break;
      }
    }
    final team = AppState.instance.teamById(session?.teamId);

    return Scaffold(
      appBar: AppBar(title: const Text('Reflection')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  reflection.sessionTitle,
                  style: TextStyle(fontFamily: AppFonts.heading, color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.w400),
                ),
              ),
              StatusBadge(status: reflection.overallStatus),
            ],
          ),
          const SizedBox(height: 6),
          Text(_formatDate(reflection.date), style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('${reflection.totalScore}', style: TextStyle(fontFamily: AppFonts.heading, color: AppColors.accentGold, fontSize: 36, fontWeight: FontWeight.w400)),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4, left: 4),
                      child: Text('/ 20', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                    ),
                    const Spacer(),
                    StarRating(rating: reflection.starRating, size: 18),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(),
                const SizedBox(height: 10),
                _DetailRow(label: 'Session Design', value: reflection.ratingSessionDesign),
                _DetailRow(label: 'Session Outcomes', value: reflection.ratingSessionOutcomes),
                _DetailRow(label: 'Coaching Behaviour', value: reflection.ratingCoachingBehaviour),
                _DetailRow(label: 'Player Engagement', value: reflection.ratingPlayerEngagement),
                if (reflection.coachWellbeingRating != null)
                  _DetailRow(label: 'Coach Wellbeing', value: reflection.coachWellbeingRating!),
              ],
            ),
          ),
          const SizedBox(height: 22),
          if (reflection.whatWentWell.isNotEmpty)
            _TextBlock(title: 'What went well', text: reflection.whatWentWell),
          if (reflection.whatDidntGoAsPlanned.isNotEmpty)
            _TextBlock(title: 'What didn\'t go as planned', text: reflection.whatDidntGoAsPlanned),
          if (reflection.whatWouldYouDoDifferently.isNotEmpty)
            _TextBlock(title: 'What would you do differently', text: reflection.whatWouldYouDoDifferently),
          if (reflection.focusNextSession.isNotEmpty)
            _TextBlock(title: 'Focus for next session', text: reflection.focusNextSession),
          if (reflection.coachWellbeingNotes.isNotEmpty)
            _TextBlock(title: 'Coach wellbeing notes', text: reflection.coachWellbeingNotes),

          if (reflection.actions.isNotEmpty) ...[
            Text('YOUR ACTIONS', style: TextStyle(fontFamily: AppFonts.subheading, color: AppColors.accentGold, fontSize: 12.5, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
            const SizedBox(height: 4),
            const Text(
              'Ticked-off items disappear from your Dashboard\'s Next Steps.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11.5),
            ),
            const SizedBox(height: 10),
            ...List.generate(reflection.actions.length, (i) {
              final key = '${reflection.id}::$i';
              final done = AppState.instance.isActionDone(key);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => AppState.instance.setActionDone(key, !done),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          margin: const EdgeInsets.only(top: 1),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: done ? AppColors.statusExcellent : Colors.transparent,
                            border: Border.all(color: done ? AppColors.statusExcellent : AppColors.accentGold, width: 1.6),
                          ),
                          child: done ? const Icon(Icons.check_rounded, size: 15, color: Colors.white) : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            reflection.actions[i],
                            style: TextStyle(
                              color: done ? AppColors.textMuted : AppColors.textPrimary,
                              fontSize: 13.5,
                              height: 1.3,
                              decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
          ],

          if (session != null) ...[
            const SizedBox(height: 10),
            Text('SESSION PLAN', style: TextStyle(fontFamily: AppFonts.subheading, color: AppColors.accentGold, fontSize: 12.5, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 14,
              runSpacing: 6,
              children: [
                if (team != null) TeamMetaChip(team: team),
                _MetaText(icon: Icons.schedule_rounded, label: '${session.durationMins} min'),
                _MetaText(icon: Icons.groups_rounded, label: '${session.playerCount} players'),
                if (session.venue.isNotEmpty) _MetaText(icon: Icons.place_rounded, label: session.venue),
              ],
            ),
            const SizedBox(height: 12),
            if (session.objectives.isNotEmpty) ...[
              Text('OBJECTIVES', style: TextStyle(fontFamily: AppFonts.subheading, color: AppColors.accentGold, fontSize: 12.5, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
              const SizedBox(height: 8),
              ...session.objectives.map(
                (o) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(padding: EdgeInsets.only(top: 2), child: Text('—  ', style: TextStyle(color: AppColors.accentGold))),
                      Expanded(child: Text(o, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5, height: 1.35))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
            ...List.generate(session.sections.length, (i) {
              final s = session!.sections[i];
              final hasDiagram = s.diagram != null;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => SectionDiagramScreen(session: session!, sectionIndex: i)),
                      );
                      if (mounted) setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  s.drillName ?? s.phase,
                                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                                ),
                              ),
                              Text('${s.durationMins} min', style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.w700, fontSize: 12.5)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(s.phase, style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
                          if (s.coachingPoints.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(s.coachingPoints, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.3)),
                          ],
                          const SizedBox(height: 10),
                          const Divider(height: 1, color: AppColors.border),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                hasDiagram ? Icons.grid_on_rounded : Icons.grid_on_outlined,
                                size: 14,
                                color: hasDiagram ? AppColors.accentGold : AppColors.textMuted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                hasDiagram ? 'View diagram' : 'Add a diagram',
                                style: TextStyle(
                                  color: hasDiagram ? AppColors.accentGold : AppColors.textMuted,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            if (session.safetyNotes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('SAFETY CONSIDERATIONS', style: TextStyle(fontFamily: AppFonts.subheading, color: AppColors.accentGold, fontSize: 12.5, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
              const SizedBox(height: 6),
              Text(session.safetyNotes, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.35)),
            ],
          ],
        ],
      ),
    );
  }

  static String _formatDate(DateTime d) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _MetaText extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaText({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
      ],
    );
  }
}

class _TextBlock extends StatelessWidget {
  final String title;
  final String text;
  const _TextBlock({required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(text, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5, height: 1.35)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final int value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
          Text('$value / 5', style: const TextStyle(color: AppColors.textPrimary, fontSize: 12.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
