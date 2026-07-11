import 'auth_user.dart';

class GoogleSignInResult {
  const GoogleSignInResult({
    required this.user,
    required this.needsOnboarding,
  });

  final AuthUser user;
  final bool needsOnboarding;
}
