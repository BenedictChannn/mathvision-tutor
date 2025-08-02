import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_state.dart';


class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState.unauthenticated());

  final _auth = FirebaseAuth.instance;

  Future<void> signInWithGoogle() async {
    emit(const AuthState.loading());
    try {
      final account = await GoogleSignIn().signIn();
      if (account == null) {
        emit(const AuthState.unauthenticated());
        return;
      }
      final gAuth = await account.authentication;
      final cred = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );
      await _auth.signInWithCredential(cred);
      emit(AuthState.authenticated(_auth.currentUser!));
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> signInAnonymously() async {
    emit(const AuthState.loading());
    try {
      await _auth.signInAnonymously();
      emit(AuthState.authenticated(_auth.currentUser!));
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    emit(const AuthState.unauthenticated());
  }
}
