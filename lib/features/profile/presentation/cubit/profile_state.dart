import '../../domain/entities/profile.dart';

sealed class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded(
    this.profile, {
    this.saving = false,
    this.actionMessage,
    this.actionError,
  });

  final Profile profile;
  final bool saving;
  final String? actionMessage;
  final String? actionError;

  ProfileLoaded copyWith({
    Profile? profile,
    bool? saving,
    String? actionMessage,
    String? actionError,
    bool clearMessages = false,
  }) {
    return ProfileLoaded(
      profile ?? this.profile,
      saving: saving ?? this.saving,
      actionMessage: clearMessages ? null : actionMessage ?? this.actionMessage,
      actionError: clearMessages ? null : actionError ?? this.actionError,
    );
  }
}

class ProfileDeleted extends ProfileState {
  const ProfileDeleted();
}
