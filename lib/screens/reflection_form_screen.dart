import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../models/reflection.dart';
import '../models/reflection_status.dart';
import '../models/session.dart';
import '../theme/app_theme.dart';
import '../widgets/rating_input.dart';
import '../widgets/section_label.dart';

/// The "Log Reflection" form for a completed session: four required 1-5
/// ratings, an optional coach-wellbeing rating, four free-text questions,
/// and a dynamic list of concrete actions (which feed the Dashboard's Next
/// Steps once saved). Saves straight into AppState — no backend yet, same
/// demo pattern as the rest of the app, but this one actually persists for
/// the session (until the app restarts).
class ReflectionFormScreen extends StatefulWidget {
  final Session session;
  const ReflectionFormScreen({super.key, required this.session});

  @override
  State<ReflectionFormScreen> createState() => _ReflectionFormScreenState();
}

class _ReflectionFormScreenState extends State<ReflectionFormScreen> {
  int _designRating = 0;
  int _outcomesRating = 0;
  int _behaviourRating = 0;
  int _engagementRating = 0;
  int _wellbeingRating = 0; // 0 = skipped

  final _wentWellController = TextEditingController();
  final _notPlannedController = TextEditingController();
  final _differentlyController = TextEditingController();
  final _focusController = TextEditingController();
  final _wellbeingNotesController = TextEditingController();
  final List<TextEditingController> _actionControllers = [TextEditingController()];

  @override
  void dispose() {
    _wentWellController.dispose();
    _notPlannedController.dispose();
    _differentlyController.dispose();
    _focusController.dispose();
    _wellbeingNotesController.dispose();
    for (final c in _actionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addActionField() => setState(() => _actionControllers.add(TextEditingController()));

  void _removeActionField(int i) => setState(() {
        _actionControllers[i].dispose();
        _actionControllers.removeAt(i);
      });

  /// Maps the total score (out of 20) to an overall mood badge, the same
  /// bands the sample reflections already follow.
  static ReflectionStatus _statusForScore(int score) {
    if (score >= 18) return ReflectionStatus.excellent;
    if (score >= 14) return ReflectionStatus.good;
    if (score >= 10) return ReflectionStatus.neutral;
    if (score >= 6) return ReflectionStatus.tough;
    return ReflectionStatus.difficult;
  }

  void _submit() {
    if (_designRating == 0 || _outcomesRating == 0 || _behaviourRating == 0 || _engagementRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please rate all four dimensions before saving.')),
      );
      return;
    }

    final score = _designRating + _outcomesRating + _behaviourRating + _engagementRating;
    final actions = _actionControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();

    final reflection = Reflection(
      id: 'r${DateTime.now().millisecondsSinceEpoch}',
      sessionId: widget.session.id,
      sessionTitle: widget.session.title,
      date: DateTime.now(),
      ratingSessionDesign: _designRating,
      ratingSessionOutcomes: _outcomesRating,
      ratingCoachingBehaviour: _behaviourRating,
      ratingPlayerEngagement: _engagementRating,
      overallStatus: _statusForScore(score),
      whatWentWell: _wentWellController.text.trim(),
      whatDidntGoAsPlanned: _notPlannedController.text.trim(),
      whatWouldYouDoDifferently: _differentlyController.text.trim(),
      focusNextSession: _focusController.text.trim(),
      coachWellbeingRating: _wellbeingRating == 0 ? null : _wellbeingRating,
      coachWellbeingNotes: _wellbeingRating == 0 ? '' : _wellbeingNotesController.text.trim(),
      actions: actions,
    );

    AppState.instance.addReflection(reflection);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reflection saved.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Reflection')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Text(widget.session.title, style: TextStyle(fontFamily: AppFonts.heading, color: AppColors.textPrimary, fontSize: 21, fontWeight: FontWeight.w400)),
          const SizedBox(height: 2),
          Text(_fullDate(widget.session.date), style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
          const SizedBox(height: 22),
          const SectionLabel(text: 'Ratings'),
          const SizedBox(height: 4),
          const Text(
            'Rate each dimension out of 5 — all four are required.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 11.5),
          ),
          const SizedBox(height: 12),
          _RatingRow(label: 'Session Design', value: _designRating, onChanged: (v) => setState(() => _designRating = v)),
          _RatingRow(label: 'Session Outcomes', value: _outcomesRating, onChanged: (v) => setState(() => _outcomesRating = v)),
          _RatingRow(label: 'Coaching Behaviour', value: _behaviourRating, onChanged: (v) => setState(() => _behaviourRating = v)),
          _RatingRow(label: 'Player Engagement', value: _engagementRating, onChanged: (v) => setState(() => _engagementRating = v)),
          const SizedBox(height: 22),
          const SectionLabel(text: 'Coach wellbeing (optional)'),
          const SizedBox(height: 12),
          _RatingRow(label: 'How did you feel delivering it?', value: _wellbeingRating, onChanged: (v) => setState(() => _wellbeingRating = v)),
          if (_wellbeingRating > 0) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _wellbeingNotesController,
              maxLines: 2,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'Anything about how you felt coaching this one (optional)'),
            ),
          ],
          const SizedBox(height: 22),
          const SectionLabel(text: 'What went well'),
          const SizedBox(height: 8),
          TextField(
            controller: _wentWellController,
            maxLines: 3,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'What worked well in this session?'),
          ),
          const SizedBox(height: 18),
          const SectionLabel(text: 'What didn\'t go as planned'),
          const SizedBox(height: 8),
          TextField(
            controller: _notPlannedController,
            maxLines: 3,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'What didn\'t go the way you expected?'),
          ),
          const SizedBox(height: 18),
          const SectionLabel(text: 'What would you do differently'),
          const SizedBox(height: 8),
          TextField(
            controller: _differentlyController,
            maxLines: 3,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'What would you change next time?'),
          ),
          const SizedBox(height: 18),
          const SectionLabel(text: 'Focus for next session'),
          const SizedBox(height: 8),
          TextField(
            controller: _focusController,
            maxLines: 2,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'What\'s the headline focus for next time?'),
          ),
          const SizedBox(height: 22),
          SectionLabel(
            text: 'Your actions',
            trailing: TextButton.icon(
              onPressed: _addActionField,
              icon: const Icon(Icons.add_rounded, size: 16, color: AppColors.accentGold),
              label: const Text('Add Action', style: TextStyle(color: AppColors.accentGold, fontSize: 12.5)),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Concrete next steps — these show up on your Dashboard until you tick them off.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 11.5),
          ),
          const SizedBox(height: 10),
          ...List.generate(_actionControllers.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _actionControllers[i],
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(hintText: 'e.g. Time-box the grid drill to 10 minutes'),
                    ),
                  ),
                  if (_actionControllers.length > 1)
                    IconButton(
                      onPressed: () => _removeActionField(i),
                      icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
                    ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              child: const Text('Save Reflection'),
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

class _RatingRow extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  const _RatingRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5)),
          ),
          RatingInput(value: value, onChanged: onChanged, size: 24),
        ],
      ),
    );
  }
}
