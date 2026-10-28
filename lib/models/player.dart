/// A squad player, matching the `players` table. Surname is required
/// (alongside first name) specifically so two players who share a first
/// name — common in a grassroots squad — are still easy to tell apart in
/// lists and by their initials on the Matchday pitch. Every player belongs
/// to exactly one [teamId] — the squad lives inside its team on Profile,
/// not as one flat roster, so a coach with several teams keeps each
/// squad separate.
class Player {
  final String id;
  final String teamId;
  final String firstName;
  final String lastName;
  final String? position;
  final bool isActive;

  const Player({
    required this.id,
    required this.teamId,
    required this.firstName,
    required this.lastName,
    this.position,
    this.isActive = true,
  });

  String get fullName => '$firstName $lastName';

  /// Two-letter initials (first name + surname) — shown in squad-list
  /// avatars and, on the Matchday pitch, on the player's token instead of
  /// a shirt number.
  String get initials {
    final f = firstName.trim();
    final l = lastName.trim();
    if (f.isEmpty && l.isEmpty) return '?';
    if (l.isEmpty) return f.substring(0, f.length < 2 ? f.length : 2).toUpperCase();
    if (f.isEmpty) return l.substring(0, l.length < 2 ? l.length : 2).toUpperCase();
    return (f[0] + l[0]).toUpperCase();
  }
}
