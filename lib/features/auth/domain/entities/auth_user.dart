class AuthUser {
  const AuthUser({
    required this.uid,
    required this.email,
    this.emailVerified = false,
  });

  final String uid;
  final String? email;
  final bool emailVerified;
}
