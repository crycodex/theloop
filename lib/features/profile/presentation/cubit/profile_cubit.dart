import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/get_profile.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(
    this._getProfile,
    this._repository,
    this._authRepository,
  ) : super(const ProfileInitial()) {
    load();
  }

  final GetProfile _getProfile;
  final ProfileRepository _repository;
  final AuthRepository _authRepository;

  Future<void> load() async {
    emit(ProfileLoaded(await _getProfile()));
  }

  Future<void> updateProfile({
    required String name,
    required String goalId,
    String? customGoal,
    required String experienceId,
  }) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    try {
      await _repository.updateProfile(
        name: name,
        goalId: goalId,
        customGoal: customGoal,
        experienceId: experienceId,
      );
      final profile = await _getProfile();
      emit(ProfileLoaded(profile, actionMessage: 'updated'));
    } catch (error) {
      emit(current.copyWith(actionError: error.toString()));
    }
  }

  Future<Map<String, dynamic>?> exportData() async {
    final current = state;
    if (current is! ProfileLoaded) return null;

    try {
      return await _repository.exportUserData();
    } catch (error) {
      emit(current.copyWith(actionError: error.toString()));
      return null;
    }
  }

  void clearActionMessage() {
    final current = state;
    if (current is ProfileLoaded) {
      emit(current.copyWith(clearMessages: true));
    }
  }

  Future<void> deleteAccount(String password) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    emit(current.copyWith(saving: true, clearMessages: true));
    try {
      await _authRepository.reauthenticateWithPassword(password);
      await _repository.deleteUserData();
      await _authRepository.deleteCurrentUser();
      emit(const ProfileDeleted());
    } catch (error) {
      emit(current.copyWith(saving: false, actionError: error.toString()));
    }
  }
}
