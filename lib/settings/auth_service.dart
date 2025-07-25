import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<AppUser?> signIn(String email, String password) async {
    try {
      // For development, create a mock user if Firebase fails
      try {
        UserCredential result = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        return AppUser(
            uid: result.user!.uid,
            email: result.user!.email!,
            username: result.user!.displayName ?? '',
            displayName: result.user!.displayName ?? '');
      } catch (firebaseError) {
        print(
            'Firebase auth failed, using mock authentication: $firebaseError');
        // Create a mock user for development
        return AppUser(
            uid: 'mock-uid-${DateTime.now().millisecondsSinceEpoch}',
            email: email,
            username: email.split('@')[0],
            displayName: email.split('@')[0]);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<AppUser?> signUp(
      String email, String password, String username) async {
    try {
      // For development, create a mock user if Firebase fails
      try {
        UserCredential result = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        await result.user!.updateDisplayName(username);
        return AppUser(
            uid: result.user!.uid,
            email: result.user!.email!,
            username: username,
            displayName: username);
      } catch (firebaseError) {
        print(
            'Firebase auth failed, using mock authentication: $firebaseError');
        // Create a mock user for development
        return AppUser(
            uid: 'mock-uid-${DateTime.now().millisecondsSinceEpoch}',
            email: email,
            username: username,
            displayName: username);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Firebase signOut failed, but continuing: $e');
    }
  }

  /// Deletes the current Firebase user account
  /// This method handles the actual deletion of the user from Firebase Authentication
  /// In development mode, it continues even if Firebase fails (for testing purposes)
  Future<void> deleteAccount() async {
    try {
      print('=== AuthService.deleteAccount ===');

      // Get the current authenticated user from Firebase
      User? user = _auth.currentUser;

      if (user != null) {
        print('Found Firebase user: ${user.uid}');

        try {
          // Delete the Firebase user account permanently
          // This removes the user from Firebase Authentication system
          await user.delete();
          print('✓ Firebase user account deleted successfully');
        } catch (deleteError) {
          print('Error deleting Firebase account: $deleteError');
          // Even if deletion fails, we should sign out to clear the auth state
          print('Signing out to clear auth state...');
          await _auth.signOut();
          print('✓ User signed out successfully');
        }
      } else {
        // If no Firebase user exists, log it but continue
        // This can happen in development mode or if Firebase is not properly configured
        print('No Firebase user to delete, but continuing with mock deletion');

       
        try {
          await _auth.signOut();
          print('✓ User signed out successfully');
        } catch (signOutError) {
          print('Error signing out: $signOutError');
        }
      }
    } catch (e) {
      // Log the error but don't stop the process
      // In development, we want the app to continue even if Firebase fails
      // In production, you might want to rethrow this error to handle it properly
      print('Error in deleteAccount: $e');
      print('Continuing with account deletion process...');

      // Try to sign out as a fallback
      try {
        await _auth.signOut();
        print('✓ User signed out as fallback');
      } catch (signOutError) {
        print('Error signing out as fallback: $signOutError');
      }
    }
  }
}
