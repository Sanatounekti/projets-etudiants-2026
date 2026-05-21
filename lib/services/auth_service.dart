import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../components/alert.dart';

class AuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Future<UserCredential> signInWithGoogle(BuildContext context) async {
    try {
      if (!context.mounted) return Future.error(Exception('Context disposed'));

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(
          child: CircularProgressIndicator(
            color: Color.fromRGBO(7, 82, 96, 1),
          ),
        ),
      );

      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        if (context.mounted) Navigator.of(context).pop();
        return Future.error(Exception('Google Sign-In cancelled'));
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      return result;
    } catch (e) {
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();

        String errorMessage = e.toString();
        if (e is FirebaseAuthException) {
          errorMessage = 'Error: ${e.code} - ${e.message}';
        }

        showDialog(
          context: context,
          builder: (ctx) => Alert_Dialog(
            isError: true,
            alertTitle: 'Error',
            errorMessage: errorMessage,
            buttonText: 'OK',
          ),
        );
      }
      rethrow;
    }
  }
}
