/// A single coach action pulled from a reflection's "actions" answer, with
/// its completion state resolved — the item shown on the Dashboard's "Next
/// Steps" area and as a checklist on the reflection it came from.
class NextStepAction {
  /// Unique across the whole app — `<reflectionId>::<index>` — used to look
  /// up / toggle completion in AppState.
  final String key;
  final String text;
  final String reflectionId;
  final String sessionTitle;
  final DateTime reflectionDate;
  final bool done;

  const NextStepAction({
    required this.key,
    required this.text,
    required this.reflectionId,
    required this.sessionTitle,
    required this.reflectionDate,
    required this.done,
  });
}
