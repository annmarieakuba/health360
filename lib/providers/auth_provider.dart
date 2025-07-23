import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../settings/auth_service.dart';
import '../settings/shared_preferences_service.dart';
import '../models/user.dart';
import 'health_data_provider.dart';

class AuthProvider with ChangeNotifier {
  AppUser? _user;
  final AuthService _authService = AuthService();
  HealthDataProvider? _healthDataProvider;
  bool _isInitialized = false;

  AppUser? get user => _user;

  // Initialize the AuthProvider by loading user data from SharedPreferences
  Future<void> initialize() async {
    if (!_isInitialized) {
      await refreshUserData();
      _isInitialized = true;
    }
  }

  void setHealthDataProvider(HealthDataProvider provider) {
    _healthDataProvider = provider;
  }

  /// Refreshes user data from SharedPreferences
  /// This is useful when the app needs to sync user data across screens
  Future<void> refreshUserData() async {
    try {
      final sharedPrefsService = SharedPreferencesService();
      final userInfo = await sharedPrefsService.getUserInfo();

      if (userInfo != null) {
        _user = AppUser(
          uid: userInfo['uid'] ?? '',
          email: userInfo['email'] ?? '',
          username: userInfo['username'] ?? '',
          displayName: userInfo['displayName'] ?? '',
        );
        notifyListeners();
        print('User data refreshed from SharedPreferences');
      }
    } catch (e) {
      print('Error refreshing user data: $e');
    }
  }

  // Initialize from existing Firebase user (for persistence)
  Future<void> initializeFromFirebaseUser(User firebaseUser) async {
    try {
      _user = AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        username: firebaseUser.displayName ?? '',
        displayName: firebaseUser.displayName ?? '',
      );

      // Save user info to SharedPreferences
      final sharedPrefsService = SharedPreferencesService();
      await sharedPrefsService.saveUserInfo(
        _user!.uid,
        _user!.email,
        _user!.username,
        _user!.displayName,
      );
      await sharedPrefsService.saveAuthState(true);

      if (_healthDataProvider != null) {
        // Initialize health data after setting user
        await _healthDataProvider!.initializeData(_user!.uid);
      }
      notifyListeners();
    } catch (e) {
      print('Error initializing from Firebase user: $e');
      rethrow;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      _user = await _authService.signIn(email, password);
      if (_user != null) {
        // Save user info to SharedPreferences
        final sharedPrefsService = SharedPreferencesService();
        await sharedPrefsService.saveUserInfo(
          _user!.uid,
          _user!.email,
          _user!.username,
          _user!.displayName,
        );
        await sharedPrefsService.saveAuthState(true);

        if (_healthDataProvider != null) {
          // Initialize health data after successful sign in
          await _healthDataProvider!.initializeData(_user!.uid);
        }
      }
      notifyListeners();
    } catch (e) {
      print('Error in signIn: $e');
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, String username) async {
    try {
      _user = await _authService.signUp(email, password, username);
      if (_user != null) {
        // Save user info to SharedPreferences
        final sharedPrefsService = SharedPreferencesService();
        await sharedPrefsService.saveUserInfo(
          _user!.uid,
          _user!.email,
          _user!.username,
          _user!.displayName,
        );
        await sharedPrefsService.saveAuthState(true);

        if (_healthDataProvider != null) {
          // Initialize health data after successful sign up
          await _healthDataProvider!.initializeData(_user!.uid);
        }
      }
      notifyListeners();
    } catch (e) {
      print('Error in signUp: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      if (_healthDataProvider != null) {
        // Clear all health data when signing out
        await _healthDataProvider!.clearAllData();
      }

      // Clear SharedPreferences data
      final sharedPrefsService = SharedPreferencesService();
      await sharedPrefsService.clearAllCachedData();

      _user = null;
      notifyListeners();
    } catch (e) {
      print('Error in signOut: $e');
      rethrow;
    }
  }

  /// Deletes the user account and clears all associated data
  /// This method performs a complete cleanup of user data:
  /// 1. Clears all health data (nutrition, exercise, sleep, mood)
  /// 2. Clears cached data in SharedPreferences
  /// 3. Deletes the Firebase authentication account
  /// 4. Clears local user state
  Future<void> deleteAccount() async {
    try {
      print('=== Starting Account Deletion Process ===');

      // Step 1: Clear all health data from local storage and memory
      // This removes nutrition, exercise, sleep, and mood records
      if (_healthDataProvider != null) {
        print('Step 1: Clearing health data...');
        await _healthDataProvider!.clearAllData();
        print('✓ Health data cleared successfully');
      }

      // Step 2: Clear cached data from SharedPreferences
      // This removes any cached latest data for quick access
      print('Step 2: Clearing SharedPreferences data...');
      final sharedPrefsService = SharedPreferencesService();
      await sharedPrefsService.clearAllCachedData();
      print('✓ SharedPreferences data cleared successfully');

      // Step 3: Delete the Firebase authentication account
      // This removes the user from Firebase Auth system
      print('Step 3: Deleting Firebase account...');
      await _authService.deleteAccount();
      print('✓ Firebase account deleted successfully');

      // Step 4: Clear local user state and notify listeners
      // This ensures the UI updates to reflect the logged-out state
      print('Step 4: Clearing local user state...');
      _user = null;
      notifyListeners();
      print('✓ Local user state cleared successfully');

      print('=== Account Deletion Completed Successfully ===');
    } catch (e) {
      print('Error in deleteAccount: $e');
      // Even if there's an error, we should clear local data
      try {
        if (_healthDataProvider != null) {
          await _healthDataProvider!.clearAllData();
        }
        final sharedPrefsService = SharedPreferencesService();
        await sharedPrefsService.clearAllCachedData();
        _user = null;
        notifyListeners();
        print('Local data cleared despite error');
      } catch (clearError) {
        print('Error clearing local data: $clearError');
      }
      rethrow;
    }
  }
}
