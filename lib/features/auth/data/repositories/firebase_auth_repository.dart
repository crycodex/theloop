import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/google_sign_in_result.dart';
import '../../domain/repositories/auth_repository.dart';

const _tag = 'loop.auth';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth, this._firestore);

  static const _firestoreTimeout = Duration(seconds: 15);
  static const _rollbackTimeout = Duration(seconds: 10);

  static const _iosGoogleClientId =
      '1009082169764-v7fp2e06lk8j9vobkdeqci8m0aq4j4jk.apps.googleusercontent.com';
  static const _googleServerClientId =
      '1009082169764-9dkdb304dnim6ohpdsvoresdn0e4359d.apps.googleusercontent.com';

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  Future<void>? _googleSignInInit;

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
    logTrace(_tag, '[signUp] creating auth user...');
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;
    logTrace(_tag, '[signUp] auth user created uid=$uid');
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
      logTrace(_tag, '[signUp] committing firestore batch...');
      await batch.commit().timeout(_firestoreTimeout);
      logTrace(_tag, '[signUp] firestore batch committed');

      logTrace(_tag, '[signUp] updating display name...');
      await credential.user!.updateDisplayName(name);
      logTrace(_tag, '[signUp] display name updated');

      logTrace(_tag, '[signUp] sending verification email...');
      await credential.user!.sendEmailVerification();
      logTrace(_tag, '[signUp] verification email sent');

      // Fire-and-forget: signOut() right after a fresh sign-up can hang on
      // some platforms. The router already treats an unverified currentUser
      // as logged-out, so we don't need to wait for this to complete.
      unawaited(
        _auth
            .signOut()
            .then((_) => logTrace(_tag, '[signUp] signOut completed'))
            .catchError(
              (Object e) => logTrace(_tag, '[signUp] signOut error: $e'),
            ),
      );
    } catch (e, st) {
      logTrace(_tag, '[signUp] ERROR: $e');
      logTrace(_tag, '$st');
      // Roll back the Auth account so a failed sign-up doesn't permanently
      // block retries with "email already in use".
      try {
        await credential.user!.delete().timeout(_rollbackTimeout);
        logTrace(_tag, '[signUp] rolled back orphaned auth user');
      } catch (rollbackError) {
        logTrace(_tag, '[signUp] auth rollback failed: $rollbackError');
      }
      rethrow;
    }

    logTrace(_tag, '[signUp] returning success, uid=$uid');
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

  Future<void> _ensureGoogleSignInInitialized() async {
    _googleSignInInit ??= GoogleSignIn.instance.initialize(
      clientId: _iosGoogleClientId,
      serverClientId: _googleServerClientId,
    );
    await _googleSignInInit;
  }

  @override
  Future<GoogleSignInResult> signInWithGoogle() async {
    await _ensureGoogleSignInInitialized();

    final googleUser = await GoogleSignIn.instance.authenticate();
    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) {
      throw FirebaseAuthException(code: 'invalid-credential');
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user!;
    final mappedUser = _mapUser(user)!;

    final needsOnboarding = await _needsOnboarding(user.uid);
    logTrace(
      _tag,
      '[signInWithGoogle] uid=${user.uid} needsOnboarding=$needsOnboarding',
    );

    return GoogleSignInResult(
      user: mappedUser,
      needsOnboarding: needsOnboarding,
    );
  }

  @override
  Future<GoogleSignInResult> signInWithApple() async {
    final provider = AppleAuthProvider()
      ..addScope('email')
      ..addScope('name');

    final userCredential = await _auth.signInWithProvider(provider);
    final user = userCredential.user!;
    final mappedUser = _mapUser(user)!;

    final needsOnboarding = await _needsOnboarding(user.uid);
    logTrace(
      _tag,
      '[signInWithApple] uid=${user.uid} needsOnboarding=$needsOnboarding',
    );

    return GoogleSignInResult(
      user: mappedUser,
      needsOnboarding: needsOnboarding,
    );
  }

  @override
  Future<AuthUser> completeGoogleOnboarding({
    required String name,
    required String goalId,
    String? customGoal,
    required String experienceId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No hay un usuario autenticado.');
    }

    final uid = user.uid;
    final email = user.email ?? '';
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
      }, SetOptions(merge: true))
      ..set(
        userDoc.collection('settings').doc('preferences'),
        <String, dynamic>{},
        SetOptions(merge: true),
      )
      ..set(
        userDoc.collection('cv').doc('current'),
        <String, dynamic>{},
        SetOptions(merge: true),
      )
      ..set(
        userDoc.collection('roadmap').doc('current'),
        <String, dynamic>{},
        SetOptions(merge: true),
      );

    await batch.commit().timeout(_firestoreTimeout);

    if (user.displayName != name) {
      await user.updateDisplayName(name);
    }

    return _mapUser(user)!;
  }

  Future<bool> _needsOnboarding(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return true;
    final data = doc.data();
    return data?['goal'] == null || data?['experience'] == null;
  }

  @override
  Future<void> signOut() async {
    await _ensureGoogleSignInInitialized();
    await Future.wait([_auth.signOut(), GoogleSignIn.instance.signOut()]);
  }

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
