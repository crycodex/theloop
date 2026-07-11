import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth, this._firestore);

  static const _firestoreTimeout = Duration(seconds: 15);
  static const _rollbackTimeout = Duration(seconds: 10);

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
    debugPrint('[signUp] creating auth user...');
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;
    debugPrint('[signUp] auth user created uid=$uid');
    final userDoc = _firestore.collection('users').doc(uid);

    try {
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
        ..set(
          userDoc.collection('settings').doc('preferences'),
          <String, dynamic>{},
        )
        ..set(userDoc.collection('cv').doc('current'), <String, dynamic>{})
        ..set(
          userDoc.collection('roadmap').doc('current'),
          <String, dynamic>{},
        );
      debugPrint('[signUp] committing firestore batch...');
      await batch.commit().timeout(_firestoreTimeout);
      debugPrint('[signUp] firestore batch committed');

      debugPrint('[signUp] updating display name...');
      await credential.user!.updateDisplayName(name);
      debugPrint('[signUp] display name updated');

      debugPrint('[signUp] sending verification email...');
      await credential.user!.sendEmailVerification();
      debugPrint('[signUp] verification email sent');

      // Fire-and-forget: signOut() right after a fresh sign-up can hang on
      // some platforms. The router already treats an unverified currentUser
      // as logged-out, so we don't need to wait for this to complete.
      unawaited(
        _auth
            .signOut()
            .then((_) => debugPrint('[signUp] signOut completed'))
            .catchError((Object e) => debugPrint('[signUp] signOut error: $e')),
      );
    } catch (e, st) {
      debugPrint('[signUp] ERROR: $e');
      debugPrint('$st');
      // Roll back the Auth account so a failed sign-up doesn't permanently
      // block retries with "email already in use".
      try {
        await credential.user!.delete().timeout(_rollbackTimeout);
        debugPrint('[signUp] rolled back orphaned auth user');
      } catch (rollbackError) {
        debugPrint('[signUp] auth rollback failed: $rollbackError');
      }
      rethrow;
    }

    debugPrint('[signUp] returning success, uid=$uid');
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
      unawaited(_auth.signOut());
      throw FirebaseAuthException(code: 'email-not-verified');
    }
    return AuthUser(uid: user.uid, email: user.email, emailVerified: true);
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  @override
  Future<void> reauthenticateWithPassword(String password) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('No hay un usuario autenticado.');
    final email = user.email;
    if (email == null || email.isEmpty) {
      throw StateError('La cuenta no tiene correo asociado.');
    }
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
  }

  @override
  Future<void> deleteCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('No hay un usuario autenticado.');
    await user.delete();
  }
}
