import 'package:firebase_auth/firebase_auth.dart';
import 'package:red_rush_flutter/models/user.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'database.dart';



class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();


  User _userFromFirebaseUser(FirebaseUser firebaseUser) =>
      firebaseUser != null ? User(firebaseUser.uid, firebaseUser.displayName) : null;

  Future signInAnon() async {
    try {
      AuthResult authResult = await _firebaseAuth.signInAnonymously();
      FirebaseUser firebaseUser = authResult.user;
      var emptyScores = {
        "3X3": 0,
        "4X4": 0,
        "5X5": 0,
        "6X6": 0,
        "7X7": 0,
        "8X8": 0,
        "9X9": 0,
      };
      int initPlayer = 0;
      await DatabaseService(uid: firebaseUser.uid).updateUserData("Guest ${firebaseUser.uid.substring(0,9)}", emptyScores, initPlayer);
      return _userFromFirebaseUser(firebaseUser);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signInGoogle() async {
    try {
      GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
      AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      AuthResult authResult = await _firebaseAuth.signInWithCredential(credential);
      FirebaseUser firebaseUser = authResult.user;
      if(authResult.additionalUserInfo.isNewUser) {
        var emptyScores = {
          "3X3": 0,
          "4X4": 0,
          "5X5": 0,
          "6X6": 0,
          "7X7": 0,
          "8X8": 0,
          "9X9": 0,
        };
        int initPlayer = 0;
        await DatabaseService(uid: firebaseUser.uid).updateUserData(
            firebaseUser.displayName, emptyScores, initPlayer);
      }
      return _userFromFirebaseUser(firebaseUser);
    } catch (e) {
      print(e.toString());
      return null;
    }



  }


  Future signOut() async {
    try {
      FirebaseUser firebaseUser = await _firebaseAuth.currentUser();
      User user = _userFromFirebaseUser(firebaseUser);

      if(user.dislpayName == "Guest") {
        firebaseUser.delete();
        await DatabaseService(uid: user.uid).deleteUser();

      }

      return await _firebaseAuth.signOut();
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }

  Stream<User> get user {
    return _firebaseAuth.onAuthStateChanged.map(_userFromFirebaseUser);
  }
}
