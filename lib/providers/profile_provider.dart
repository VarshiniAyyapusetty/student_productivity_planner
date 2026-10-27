
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

class ProfileProvider extends ChangeNotifier {
  static const String _storageKey = 'student_productivity_profile';

  UserProfile _profile = const UserProfile();
  bool _isLoading = true;

  UserProfile get profile => _profile;
  bool get isLoading => _isLoading;

  Future<void> loadProfile() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedProfile = preferences.getString(_storageKey);

      if (savedProfile != null) {
        final decoded = jsonDecode(savedProfile);
        _profile = UserProfile.fromJson(
          Map<String, dynamic>.from(decoded as Map),
        );
      }
    } catch (error) {
      debugPrint('Could not load saved profile: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(UserProfile updatedProfile) async {
    _profile = updatedProfile;
    notifyListeners();

    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(
        _storageKey,
        jsonEncode(_profile.toJson()),
      );
    } catch (error) {
      debugPrint('Could not save profile: $error');
    }
  }
}
