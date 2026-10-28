import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../data/sample_data.dart';
import '../models/next_step_action.dart';
import '../models/reflection.dart';
import '../models/session.dart';
import '../theme/app_theme.dart';
import '../widgets/section_label.dart';
import '../widgets/stat_card.dart';
import '../widgets/star_rating.dart';
import '../widgets/status_badge.dart';
import 'profile_screen.dart';
import 'reflection_detail_screen.dart';
import 'session_detail_screen.dart';
import 'sessions_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const int _maxNextSteps = 5;

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

  String _greeting(DateTime now) {
    final hour = now.hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _formatDate(DateTime d) {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${weekdays[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final Session next = SampleData.nextSession;
    final Reflection? recent = AppState.instance.mostRecentReflection;
    final outstandingSteps = AppState.instance.nextSteps().where((a) => !a.done).toList();

    return RefreshIndicator(
      onRefresh: () async => Future.delayed(const Duration(milliseconds: 600)),
      color: AppColors.accentGold,
      backgroundColor: AppColors.surface,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_formatDate(now), style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      '${_greeting(now)}, ${SampleData.coachFirstName}.',
                      style: TextStyle(
                        fontFamily: AppFonts.heading,
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
                icon: Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.person_outline_rounded, color: AppColors.accentGold, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  value: '${SampleData.sessionsThisMonth}',
                  label: 'Sessions this month',
                  subLabel: 'completed',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  value: SampleData.avgSessionRating.toStringAsFixed(1),
                  label: 'Avg session rating',
                  subLabel: 'out of 5',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  value: '${SampleData.upcomingSessionsScheduled}',
                  label: 'Upcoming sessions',
                  subLabel: 'scheduled',
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          SectionLabel(
            text: 'Next session',
            trailing: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SessionsScreen()),
              ),
              child: const Text('All sessions →', style: TextStyle(color: AppColors.accentGold, fontSize: 12.5)),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => SessionDetailScreen(session: next)),
            ),
            child: _NextSessionCard(session: next),
          ),
          const SizedBox(height: 28),
          SectionLabel(
            text: 'Next steps',
            trailing: outstandingSteps.isEmpty
                ? null
                : Text('${outstandingSteps.length} outstanding', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ),
          const SizedBox(height: 10),
          if (outstandingSteps.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_outline_rounded, color: AppColors.statusExcellent, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You\'re all caught up — no outstanding actions from your reflections.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.3),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            ...outstandingSteps.take(_maxNextSteps).map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _NextStepRow(action: a),
                )),
            if (outstandingSteps.length > _maxNextSteps)
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 4),
                child: Text(
                  '+ ${outstandingSteps.length - _maxNextSteps} more — tick items off from their reflection.',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ),
          ],
          const SizedBox(height: 28),
          const SectionLabel(text: 'Recent reflection'),
          const SizedBox(height: 10),
          if (recent != null)
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ReflectionDetailScreen(reflection: recent)),
              ),
              child: _RecentReflectionCard(reflection: recent),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'No reflections logged yet.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }
}

class _NextSessionCard extends StatelessWidget {
  final Session session;
  const _NextSessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.accentGold.withOpacity(0.16),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              session.relativeLabel(DateTime.now()),
              style: const TextStyle(color: AppColors.accentGold, fontSize: 10.5, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            session.title,
            style: TextStyle(fontFamily: AppFonts.heading, color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _MetaChip(icon: Icons.calendar_today_rounded, label: _shortDate(session.date)),
              const SizedBox(width: 14),
              _MetaChip(icon: Icons.schedule_rounded, label: '${session.durationMins} min'),
              const SizedBox(width: 14),
              _MetaChip(icon: Icons.groups_rounded, label: '${session.playerCount} players'),
            ],
          ),
          const SizedBox(height: 18),
          Text('OBJECTIVES', style: TextStyle(fontFamily: AppFonts.subheading, color: AppColors.accentGold, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
          const SizedBox(height: 8),
          ...session.objectives.map(
            (o) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text('—  ', style: TextStyle(color: AppColors.accentGold)),
                  ),
                  Expanded(child: Text(o, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.3))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('SESSION PLAN', style: TextStyle(fontFamily: AppFonts.subheading, color: AppColors.accentGold, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
          const SizedBox(height: 8),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: session.sections.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final section = session.sections[i];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    '${section.drillName ?? section.phase} · ${section.durationMins}m',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 11.5),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static String _shortDate(DateTime d) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${weekdays[d.weekday - 1]} ${d.day} ${months[d.month - 1]}';
  }
}

/// One outstanding action from a reflection — a checkbox ticks it off via
/// AppState, which removes it from this list and (still visibly, checked)
/// from that reflection's own action checklist.
class _NextStepRow extends StatelessWidget {
  final NextStepAction action;
  const _NextStepRow({required this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => AppState.instance.setActionDone(action.key, true),
            child: Container(
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accentGold, width: 1.6),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(action.text, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5, height: 1.3)),
                const SizedBox(height: 3),
                Text(
                  'From: ${action.sessionTitle}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}

class _RecentReflectionCard extends StatelessWidget {
  final Reflection reflection;
  const _RecentReflectionCard({required this.reflection});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${reflection.totalScore}',
              style: TextStyle(fontFamily: AppFonts.heading, color: AppColors.accentGold, fontSize: 19, fontWeight: FontWeight.w400),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reflection.sessionTitle, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 4),
                StarRating(rating: reflection.starRating, size: 14),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusBadge(status: reflection.overallStatus),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }
}
