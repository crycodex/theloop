class Profile {
  const Profile({
    required this.name,
    required this.email,
    required this.target,
    required this.plan,
    this.experience = '',
    this.customGoal,
  });

  final String name;
  final String email;
  final String target;
  final String plan;
  final String experience;
  final String? customGoal;
}
