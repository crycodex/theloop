import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Stream<AuthUser?> authStateChanges() =>
      _auth.authStateChanges().map(_mapUser);

  @override
  AuthUser? get currentUser => _mapUser(_auth.currentUser);

  AuthUser? _mapUser(User? user) => user == null
      ? null
      : AuthUser(
          uid: user.uid,
          email: user.email,
          emailVerified: user.emailVerified,
        );

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String name,
    required String goalId,
    String? customGoal,
    required String experienceId,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;
    final userDoc = _firestore.collection('users').doc(uid);

    final batch = _firestore.batch()
      ..set(userDoc, {
        'uid': uid,
        'name': name,
        'email': email,
        'goal': goalId,
        if (customGoal != null && customGoal.trim().isNotEmpty)
          'customGoal': customGoal.trim(),
        'experience': experienceId,
        'createdAt': FieldValue.serverTimestamp(),
      })
      ..set(userDoc.collection('settings').doc('preferences'), <String, dynamic>{})
      ..set(userDoc.collection('cv').doc('current'), <String, dynamic>{})
      ..set(userDoc.collection('roadmap').doc('current'), <String, dynamic>{});
    await batch.commit();

    await credential.user!.updateDisplayName(name);
    await credential.user!.sendEmailVerification();
    await _auth.signOut();

    return AuthUser(uid: uid, email: email, emailVerified: false);
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    if (!user.emailVerified) {
      await user.sendEmailVerification();
      await _auth.signOut();
      throw FirebaseAuthException(code: 'email-not-verified');
    }
    return AuthUser(uid: user.uid, email: user.email, emailVerified: true);
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email);
}
