import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_profile.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._getProfile) : super(const ProfileInitial()) {
    load();
  }

  final GetProfile _getProfile;

  void load() {
    emit(ProfileLoaded(_getProfile()));
  }
}
