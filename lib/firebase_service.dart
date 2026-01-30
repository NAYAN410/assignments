import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign up with Email and Password
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required Map<String, dynamic> additionalData,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        // Save user details to Realtime Database
        await _saveUserToDatabase(userCredential.user!.uid, {
          ...additionalData,
          'email': email,
          'profilePic': '',
          'authMethod': 'manual',
        });
      }
      return userCredential;
    } catch (e) {
      print("Error in Manual Sign Up: $e");
      return null;
    }
  }

  // Sign in with Email and Password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      print("Error in Manual Sign In: $e");
      return null;
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        // Save/Update user details to Realtime Database
        await _saveUserToDatabase(userCredential.user!.uid, {
          'name': userCredential.user!.displayName ?? '',
          'email': userCredential.user!.email ?? '',
          'profilePic': userCredential.user!.photoURL ?? '',
          'authMethod': 'google',
        });
      }
      return userCredential;
    } catch (e) {
      print("Error in Google Sign In: $e");
      return null;
    }
  }

  // Save user details to Realtime Database
  Future<void> _saveUserToDatabase(String uid, Map<String, dynamic> userData) async {
    await _dbRef.child('users').child(uid).update(userData);
  }

  // Get user data from database
  Future<Map<dynamic, dynamic>?> getUserData(String uid) async {
    try {
      final snapshot = await _dbRef.child('users').child(uid).get();
      if (snapshot.exists) {
        return snapshot.value as Map<dynamic, dynamic>?;
      }
      return null;
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
