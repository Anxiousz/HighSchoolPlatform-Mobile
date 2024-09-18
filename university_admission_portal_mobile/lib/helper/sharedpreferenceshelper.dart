import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Sharedpreferenceshelper {
  static const String loginInfoKey = 'loginInfo';
  static const String accInfoKey = 'accInfo';
  static const String accessTokenKey = 'accessToken';

  static Future<void> saveAccount(
      Map<String, dynamic> account, String accessToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accountJson = account.toString();
    String accessTokenJson = accessToken.toString();
    prefs.setString(loginInfoKey, accountJson);
    prefs.setString(accessTokenKey, accessTokenJson);
  }

  static Future<Map<String, dynamic>?> getInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accountJson = prefs.getString(accInfoKey);

    if (accountJson != null) {
      Map<String, dynamic> accountMap = jsonDecode(accountJson);
      return accountMap;
    } else {
      return null;
    }
  }

  static Future<void> removeInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(accInfoKey);
  }

  static Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(accessTokenKey);
  }
}
