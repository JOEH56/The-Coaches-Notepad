import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../data/sample_data.dart';
import '../models/session.dart';
import '../theme/app_theme.dart';
import '../widgets/team_chip.dart';
import 'session_builder_screen.dart';
import 'session_detail_screen.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  bool _showUpcoming = true;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final upcoming = SampleData.sessions.where((s) => s.status == SessionStatus.planned).toList();
    final completed = SampleData.sessions.where((s) => s.status == SessionStatus.completed).toList();
    final list = (_showUpcoming ? upcoming : completed)
        .where((s) => s.title.toLowerCase().contains(_query.toLowerCase()) ||
            s.topicTheme.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Session Planner', style: TextStyle(fontFamily: AppFonts.heading, color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.w400)),
                  const SizedBox(height: 4),
                  Text('${SampleData.sessions.length} sessions total', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SessionBuilderScreen()),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('New Session'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          onChanged: (v) => setState(() => _query = v),
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Search sessions by topic',
            prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _ToggleChip(
              label: 'Upcoming (${upcoming.length})',
              selected: _showUpcoming,
              onTap: () => setState(() => _showUpcoming = true),
            ),
            const SizedBox(width: 10),
            _ToggleChip(
              label: 'Completed (${completed.length})',
              selected: !_showUpcoming,
              onTap: () => setState(() => _showUpcoming = false),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (list.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(
              child: Text('No sessions found', style: TextStyle(color: AppColors.textMuted)),
            ),
          )
        else
          ...list.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SessionCard(session: s),
              )),
      ],
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentGold : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.accentGold : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.onAccent : AppColors.textSecondary,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final Session session;
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final team = AppState.instance.teamById(session.teamId);
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SessionDetailScreen(session: session)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    session.title,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 15.5, fontWeight: FontWeight.w700),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              ],
            ),
            if (team != null) ...[
              const SizedBox(height: 6),
              TeamMetaChip(team: team, fontSize: 12),
            ],
            const SizedBox(height: 6),
            Text(
              '${_fullDate(session.date)} · ${session.durationMins} min · ${session.playerCount} players',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
            ),
            const SizedBox(height: 4),
            Text(
              '${session.drillCount} drills',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  static String _fullDate(DateTime d) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${weekdays[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
