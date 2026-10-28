import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../theme/app_theme.dart';

/// Opens the shared "Add Player" bottom sheet for [teamId]'s squad — used
/// from that team's own squad screen on Profile (where the squad is built)
/// and, in future, anywhere else a team's roster needs topping up. First
/// name and surname are both required — see [Player]'s own doc comment for
/// why.
void showAddSquadPlayerSheet(BuildContext context, String teamId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddSquadPlayerSheet(teamId: teamId),
  );
}

const List<String> _squadPositions = ['Goalkeeper', 'Defender', 'Midfielder', 'Forward'];

class _AddSquadPlayerSheet extends StatefulWidget {
  final String teamId;
  const _AddSquadPlayerSheet({required this.teamId});

  @override
  State<_AddSquadPlayerSheet> createState() => _AddSquadPlayerSheetState();
}

class _AddSquadPlayerSheetState extends State<_AddSquadPlayerSheet> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String? _position;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _save() {
    final first = _firstNameController.text.trim();
    final last = _lastNameController.text.trim();
    if (first.isEmpty || last.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter both a first name and surname.')),
      );
      return;
    }
    final added = AppState.instance.addSquadPlayer(teamId: widget.teamId, firstName: first, lastName: last, position: _position);
    Navigator.of(context).pop();
    if (!added) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Squad is full — remove a player first (max ${AppState.maxSquadSize}).')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
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
            Text(
              'Add Player',
              style: TextStyle(fontFamily: AppFonts.heading, color: AppColors.textPrimary, fontSize: 21, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 18),
            const Text('First name', style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w700)),
            const SizedBox(height: 7),
            TextField(
              controller: _firstNameController,
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'e.g. Aiden'),
            ),
            const SizedBox(height: 16),
            const Text('Surname', style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w700)),
            const SizedBox(height: 7),
            TextField(
              controller: _lastNameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'e.g. Clarke'),
            ),
            const SizedBox(height: 5),
            const Text(
              'Both are required, so players sharing a first name still stay easy to tell apart.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
            const SizedBox(height: 16),
            const Text('Position', style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w700)),
            const SizedBox(height: 7),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: _squadPositions.map((p) {
                final selected = p == _position;
                return GestureDetector(
                  onTap: () => setState(() => _position = selected ? null : p),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.accentGold : AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: selected ? AppColors.accentGold : AppColors.border),
                    ),
                    child: Text(
                      p,
                      style: TextStyle(
                        color: selected ? AppColors.onAccent : AppColors.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Add to Squad'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
