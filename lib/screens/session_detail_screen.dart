import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../models/reflection.dart';
import '../models/session.dart';
import '../theme/app_theme.dart';
import '../widgets/star_rating.dart';
import '../widgets/status_badge.dart';
import '../widgets/team_chip.dart';
import 'reflection_form_screen.dart';
import 'section_diagram_screen.dart';

/// Session Detail & Reflection page — shows the plan, and for completed
/// sessions, the linked post-session reflection (objectives pulled through
/// read-only, four-dimension ratings, total score out of 20).
class SessionDetailScreen extends StatefulWidget {
  final Session session;
  const SessionDetailScreen({super.key, required this.session});

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  Session get session => widget.session;

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
    Reflection? reflection;
    for (final r in AppState.instance.reflections) {
      if (r.sessionId == session.id) {
        reflection = r;
        break;
      }
    }
    final team = AppState.instance.teamById(session.teamId);

    return Scaffold(
      appBar: AppBar(
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.share_rounded, size: 20),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        children: [
          Text(session.title, style: TextStyle(fontFamily: AppFonts.heading, color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.w400)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              if (team != null) TeamMetaChip(team: team),
              _MetaText(icon: Icons.calendar_today_rounded, label: _fullDate(session.date)),
              _MetaText(icon: Icons.schedule_rounded, label: '${session.durationMins} min'),
              _MetaText(icon: Icons.groups_rounded, label: '${session.playerCount} players'),
              if (session.venue.isNotEmpty) _MetaText(icon: Icons.place_rounded, label: session.venue),
            ],
          ),
          const SizedBox(height: 22),
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
          const SizedBox(height: 22),
          Text('SESSION PLAN', style: TextStyle(fontFamily: AppFonts.subheading, color: AppColors.accentGold, fontSize: 12.5, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
          const SizedBox(height: 4),
          const Text(
            'Tap a section to view or edit its own diagram.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 11.5),
          ),
          const SizedBox(height: 10),
          ...List.generate(session.sections.length, (i) {
            final s = session.sections[i];
            final hasDiagram = s.diagram != null;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => SectionDiagramScreen(session: session, sectionIndex: i)),
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
            const SizedBox(height: 12),
            Text('SAFETY CONSIDERATIONS', style: TextStyle(fontFamily: AppFonts.subheading, color: AppColors.accentGold, fontSize: 12.5, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
            const SizedBox(height: 6),
            Text(session.safetyNotes, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.35)),
          ],
          const SizedBox(height: 26),
          if (reflection != null)
            _ReflectionSummary(reflection: reflection)
          else if (session.status == SessionStatus.completed)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ReflectionFormScreen(session: session)),
                ),
                child: const Text('Log Reflection'),
              ),
            ),
        ],
      ),
    );
  }

  static String _fullDate(DateTime d) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${weekdays[d.weekday - 1]} ${d.day} ${months[d.month - 1]} ${d.year}';
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

class _ReflectionSummary extends StatelessWidget {
  final Reflection reflection;
  const _ReflectionSummary({required this.reflection});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('REFLECTION', style: TextStyle(fontFamily: AppFonts.subheading, color: AppColors.accentGold, fontSize: 12.5, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
              StatusBadge(status: reflection.overallStatus),
            ],
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 12),
          if (reflection.whatWentWell.isNotEmpty) ...[
            const Text('What went well', style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(reflection.whatWentWell, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.3)),
          ],
        ],
      ),
    );
  }
}
