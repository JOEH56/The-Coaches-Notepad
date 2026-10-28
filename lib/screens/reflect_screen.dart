import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../data/sample_data.dart';
import '../models/reflection.dart';
import '../models/session.dart';
import '../theme/app_theme.dart';
import '../widgets/star_rating.dart';
import '../widgets/status_badge.dart';
import 'reflection_detail_screen.dart';
import 'reflection_form_screen.dart';

class ReflectScreen extends StatefulWidget {
  const ReflectScreen({super.key});

  @override
  State<ReflectScreen> createState() => _ReflectScreenState();
}

class _ReflectScreenState extends State<ReflectScreen> {
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

  /// Completed sessions that don't have a reflection yet — the candidates
  /// for "Log Reflection" when the coach hasn't come from a specific
  /// session's own detail page.
  List<Session> get _reflectableSessions {
    final list = SampleData.sessions
        .where((s) => s.status == SessionStatus.completed && !AppState.instance.hasReflectionFor(s.id))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  void _startLogReflection() {
    final candidates = _reflectableSessions;
    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Every completed session already has a reflection — complete a new session to log another.')),
      );
      return;
    }
    if (candidates.length == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ReflectionFormScreen(session: candidates.first)),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SessionPickerSheet(sessions: candidates),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reflections = List<Reflection>.from(AppState.instance.reflections)
      ..sort((a, b) => b.date.compareTo(a.date));

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
                  Text('Reflections', style: TextStyle(fontFamily: AppFonts.heading, color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.w400)),
                  const SizedBox(height: 4),
                  Text('${reflections.length} entries logged', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _startLogReflection,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Log Reflection'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
            ),
          ],
        ),
        const SizedBox(height: 18),
        ...reflections.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ReflectionCard(reflection: r),
            )),
      ],
    );
  }
}

/// Bottom sheet listing completed-but-unreflected sessions when there's more
/// than one candidate for "Log Reflection" and no specific session was
/// already in context.
class _SessionPickerSheet extends StatelessWidget {
  final List<Session> sessions;
  const _SessionPickerSheet({required this.sessions});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Text('Which session?', style: TextStyle(fontFamily: AppFonts.heading, color: AppColors.textPrimary, fontSize: 21, fontWeight: FontWeight.w400)),
          const SizedBox(height: 4),
          const Text('Pick the completed session you\'re reflecting on.', style: TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: sessions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final s = sessions[i];
                return Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ReflectionFormScreen(session: s)),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13.5)),
                                const SizedBox(height: 2),
                                Text(_formatDate(s.date), style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

/// Tappable summary card — opens the full ReflectionDetailScreen (which also
/// shows the linked session's plan) rather than expanding inline.
class _ReflectionCard extends StatelessWidget {
  final Reflection reflection;
  const _ReflectionCard({required this.reflection});

  @override
  Widget build(BuildContext context) {
    final r = reflection;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ReflectionDetailScreen(reflection: r)),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${r.starRating.round()}',
                      style: TextStyle(fontFamily: AppFonts.heading, color: AppColors.accentGold, fontSize: 19, fontWeight: FontWeight.w400),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.sessionTitle, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14.5)),
                        const SizedBox(height: 4),
                        StarRating(rating: r.starRating, size: 14),
                      ],
                    ),
                  ),
                  StatusBadge(status: r.overallStatus),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
                ],
              ),
              const SizedBox(height: 8),
              Text(_formatDate(r.date), style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
              const SizedBox(height: 6),
              Text(
                r.whatWentWell,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.35),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
