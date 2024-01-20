import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtil {
  static const String KEY_USERNAME = 'username';
  static const String KEY_EMAIL = 'email';
  static const String KEY_UID = 'currentUID';

  static Future<void> saveUserData(
      String username, String email, String uid) async {
    debugPrint('username ->$username email $email currentuserid $uid');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(KEY_USERNAME, username);
    prefs.setString(KEY_EMAIL, email);
    prefs.setString(KEY_UID, uid);
  }

  static Future<Map<String, String?>> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString(KEY_USERNAME);
    String? email = prefs.getString(KEY_EMAIL);
    String? uid = prefs.getString(KEY_UID);

    return {
      KEY_USERNAME: username,
      KEY_EMAIL: email,
      KEY_UID: uid,
    };
  }
}
