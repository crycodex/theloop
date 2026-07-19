import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';

class FirestoreProfileRepository implements ProfileRepository {
  const FirestoreProfileRepository(this._firestore, this._authRepository);

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  DocumentReference<Map<String, dynamic>>? get _userDoc {
    final user = _authRepository.currentUser;
    if (user == null) return null;
    return _firestore.collection('users').doc(user.uid);
  }

  @override
  Future<bool> isProfileComplete() async {
    final user = _authRepository.currentUser;
    if (user == null) return false;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return false;
    final data = doc.data();
    return data?['goal'] != null && data?['experience'] != null;
  }

  @override
  Future<Profile> getProfile() async {
    final user = _authRepository.currentUser;
    if (user == null) {
      return const Profile(name: '', email: '', target: '', plan: '');
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data() ?? <String, dynamic>{};

    return Profile(
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? user.email ?? '',
      target: data['goal'] as String? ?? '',
      plan: data['plan'] as String? ?? 'Plan Gratis',
      experience: data['experience'] as String? ?? '',
      customGoal: data['customGoal'] as String?,
    );
  }

  @override
  Future<void> updateProfile({
    required String name,
    required String goalId,
    String? customGoal,
    required String experienceId,
  }) async {
    final userDoc = _userDoc;
    if (userDoc == null) throw StateError('No hay un usuario autenticado.');

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('El nombre no puede estar vacío.');
    }

    final update = <String, dynamic>{
      'name': trimmedName,
      'goal': goalId,
      'experience': experienceId,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (goalId == 'custom' && customGoal?.trim().isNotEmpty == true) {
      update['customGoal'] = customGoal!.trim();
    } else {
      update['customGoal'] = FieldValue.delete();
    }

    await userDoc.update(update);
  }

  @override
  Future<Map<String, dynamic>> exportUserData() async {
    final userDoc = _userDoc;
    final user = _authRepository.currentUser;
    if (userDoc == null || user == null) {
      throw StateError('No hay un usuario autenticado.');
    }

    final exported = <String, dynamic>{
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'uid': user.uid,
      'email': user.email,
    };

    final userSnap = await userDoc.get();
    exported['profile'] = _serializeMap(userSnap.data());

    for (final sub in ['settings', 'cv', 'roadmap']) {
      final snap = await userDoc.collection(sub).get();
      exported[sub] = snap.docs
          .map((doc) => {'id': doc.id, ...?_serializeMap(doc.data())})
          .toList(growable: false);
    }

    final tracksSnap = await userDoc.collection('tracks').get();
    final tracks = <Map<String, dynamic>>[];
    for (final trackDoc in tracksSnap.docs) {
      final loopsSnap = await trackDoc.reference.collection('loops').get();
      tracks.add({
        'id': trackDoc.id,
        ...?_serializeMap(trackDoc.data()),
        'loops': loopsSnap.docs
            .map((loopDoc) => {
                  'id': loopDoc.id,
                  ...?_serializeMap(loopDoc.data()),
                })
            .toList(growable: false),
      });
    }
    exported['tracks'] = tracks;

    return exported;
  }

  @override
  Future<void> deleteUserData() async {
    final userDoc = _userDoc;
    if (userDoc == null) throw StateError('No hay un usuario autenticado.');

    final tracksSnap = await userDoc.collection('tracks').get();
    for (final trackDoc in tracksSnap.docs) {
      final loopsSnap = await trackDoc.reference.collection('loops').get();
      for (final loopDoc in loopsSnap.docs) {
        await loopDoc.reference.delete();
      }
      await trackDoc.reference.delete();
    }

    for (final sub in ['settings', 'cv', 'roadmap']) {
      final snap = await userDoc.collection(sub).get();
      for (final doc in snap.docs) {
        await doc.reference.delete();
      }
    }

    await userDoc.delete();
  }

  Map<String, dynamic>? _serializeMap(Map<String, dynamic>? source) {
    if (source == null) return null;
    return jsonDecode(jsonEncode(source, toEncodable: _encodeValue))
        as Map<String, dynamic>;
  }

  Object? _encodeValue(Object? value) {
    if (value is Timestamp) return value.toDate().toUtc().toIso8601String();
    if (value is Iterable) return value.map(_encodeValue).toList();
    if (value is Map) {
      return value.map((key, item) => MapEntry(key, _encodeValue(item)));
    }
    return value;
  }
}
