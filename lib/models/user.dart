class AppUser {
  final String uid;
  final String email;
  final String username;
  String displayName;

  AppUser({
    required this.uid,
    required this.email,
    required this.username,
    String? displayName,
  }) : displayName = displayName ?? username;
}
