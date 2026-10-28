import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../data/sample_data.dart';
import '../models/reflection.dart';
import '../models/reflection_status.dart';
import '../models/session.dart';
import '../theme/app_theme.dart';
import '../widgets/mood_distribution_chart.dart';
import '../widgets/rating_line_chart.dart';
import '../widgets/section_label.dart';
import '../widgets/star_rating.dart';
import '../widgets/stat_card.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
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
    final reflections = List.of(AppState.instance.reflections)
      ..sort((a, b) => a.date.compareTo(b.date));

    final ratingValues = reflections.map((r) => r.starRating).toList();
    final xLabels = reflections.map((r) => '${r.date.day} ${_monthShort(r.date.month)}').toList();

    final moodCounts = <ReflectionStatus, int>{};
    for (final status in ReflectionStatus.values) {
      moodCounts[status] = reflections.where((r) => r.overallStatus == status).length;
    }

    // Most recent reflections first, for the per-dimension breakdown and the
    // "Avg session rating" / "Reflections written" stat tiles below.
    final recentReflections = List<Reflection>.of(reflections).reversed.toList();
    final recentThree = recentReflections.take(3).toList();

    // Most recent completed sessions first, for the "Sessions completed" /
    // "Total hours coached" stat tiles — newest always at the top, and once
    // a fourth completed session exists the oldest of the three drops off.
    final completedSessions = List<Session>.of(SampleData.sessions.where((s) => s.status == SessionStatus.completed))
      ..sort((a, b) => b.date.compareTo(a.date));
    final recentSessions = completedSessions.take(3).toList();

    final sessionRows = recentSessions
        .map((s) => _RecentRow(
              title: s.title,
              trailing: Text(_shortDate(s.date), style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ))
        .toList();
    final hoursRows = recentSessions
        .map((s) => _RecentRow(
              title: s.title,
              trailing: Text('${s.durationMins} min', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ))
        .toList();
    final ratingRows = recentThree
        .map((r) => _RecentRow(
              title: r.sessionTitle,
              trailing: StarRating(rating: r.starRating, size: 12),
            ))
        .toList();
    final reflectionRows = recentThree
        .map((r) => _RecentRow(
              title: r.sessionTitle,
              trailing: Text(_shortDate(r.date), style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ))
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        Text('Progress', style: TextStyle(fontFamily: AppFonts.heading, color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.w400)),
        const SizedBox(height: 4),
        const Text('Your coaching trajectory over time', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        const SizedBox(height: 20),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: StatCard(
                  value: '${SampleData.progressSessionsCompleted}',
                  label: 'Sessions completed',
                  child: _RecentList(rows: sessionRows, emptyText: 'No completed sessions yet.'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  value: '${SampleData.progressTotalHoursCoached.toStringAsFixed(0)}h',
                  label: 'Total hours coached',
                  child: _RecentList(rows: hoursRows, emptyText: 'No completed sessions yet.'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: StatCard(
                  value: '${SampleData.avgSessionRating.toStringAsFixed(1)}/5',
                  label: 'Avg session rating',
                  child: _RecentList(rows: ratingRows, emptyText: 'No reflections logged yet.'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  value: '${SampleData.progressReflectionsWritten}',
                  label: 'Reflections written',
                  child: _RecentList(rows: reflectionRows, emptyText: 'No reflections logged yet.'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _ChartCard(
          title: 'Session Rating Over Time',
          subtitle: 'Post-session ratings from reflections',
          child: RatingLineChart(values: ratingValues, xLabels: xLabels),
        ),
        const SizedBox(height: 16),
        _ChartCard(
          title: 'Mood Distribution',
          subtitle: 'How sessions have felt overall',
          child: MoodDistributionChart(counts: moodCounts),
        ),
        const SizedBox(height: 24),
        const SectionLabel(text: 'Progress by area'),
        const SizedBox(height: 4),
        const Text(
          'Your most recent scores in each coaching dimension.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 11.5),
        ),
        const SizedBox(height: 10),
        _DimensionCard(
          title: 'Session Design',
          reflections: recentThree,
          ratingOf: (r) => r.ratingSessionDesign,
        ),
        const SizedBox(height: 12),
        _DimensionCard(
          title: 'Session Outcomes',
          reflections: recentThree,
          ratingOf: (r) => r.ratingSessionOutcomes,
        ),
        const SizedBox(height: 12),
        _DimensionCard(
          title: 'Coaching Behaviour',
          reflections: recentThree,
          ratingOf: (r) => r.ratingCoachingBehaviour,
        ),
        const SizedBox(height: 12),
        _DimensionCard(
          title: 'Player Engagement',
          reflections: recentThree,
          ratingOf: (r) => r.ratingPlayerEngagement,
        ),
        const SizedBox(height: 16),
        const SectionLabel(text: 'Date range'),
        const SizedBox(height: 8),
        Row(
          children: const [
            _RangeChip(label: 'This Month', selected: true),
            SizedBox(width: 8),
            _RangeChip(label: 'This Season', selected: false),
            SizedBox(width: 8),
            _RangeChip(label: 'All Time', selected: false),
          ],
        ),
      ],
    );
  }

  static String _monthShort(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

String _shortDate(DateTime d) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${d.day} ${months[d.month - 1]}';
}

/// The "3 most recent" list shown inside a stat tile on Progress — newest
/// first. Sourced live from AppState/SampleData each build, so as soon as a
/// new session is completed or a new reflection is logged, everything here
/// shifts down one and the oldest of the three drops off automatically.
class _RecentList extends StatelessWidget {
  final List<Widget> rows;
  final String emptyText;
  const _RecentList({required this.rows, required this.emptyText});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Text(emptyText, style: const TextStyle(color: AppColors.textMuted, fontSize: 11));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: AppColors.border, height: 1),
        const SizedBox(height: 10),
        Text(
          'RECENT',
          style: TextStyle(fontFamily: AppFonts.subheading, color: AppColors.accentGold, fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.6),
        ),
        const SizedBox(height: 6),
        ...rows,
      ],
    );
  }
}

class _RecentRow extends StatelessWidget {
  final String title;
  final Widget trailing;
  const _RecentRow({required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _ChartCard({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14.5)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

/// One coaching-dimension card in the "Progress by area" section — shows the
/// three most recent completed sessions that have a reflection, each with
/// its score for just this dimension (Session Design, Session Outcomes,
/// Coaching Behaviour, or Player Engagement).
class _DimensionCard extends StatelessWidget {
  final String title;
  final List<Reflection> reflections;
  final int Function(Reflection) ratingOf;

  const _DimensionCard({required this.title, required this.reflections, required this.ratingOf});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14.5)),
          const SizedBox(height: 12),
          if (reflections.isEmpty)
            const Text(
              'No completed sessions with a reflection yet.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
            )
          else
            ...List.generate(reflections.length, (i) {
              final r = reflections[i];
              final isLast = i == reflections.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.sessionTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(_formatDate(r.date), style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    StarRating(rating: ratingOf(r).toDouble(), size: 14),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  static String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _RangeChip extends StatelessWidget {
  final String label;
  final bool selected;
  const _RangeChip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: selected ? AppColors.accentGold : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? AppColors.accentGold : AppColors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? AppColors.onAccent : AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
