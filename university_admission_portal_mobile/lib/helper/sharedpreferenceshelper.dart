import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_ad_portal/models/userInfo.dart';

class Sharedpreferenceshelper {
  static const String accInfoKey = 'accInfo';
  static const String accessTokenKey = 'accessToken';

  static Future<void> saveAccount(Info account, String accessToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accountJson = jsonEncode(account);
    String accessTokenJson = accessToken.toString();
    prefs.setString(accInfoKey, accountJson);
    //Them
    prefs.setString(accessTokenKey, accessTokenJson);
  }

  static Future<Info?> getInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accountJson = prefs.getString(accInfoKey);

    if (accountJson != null) {
      Map<String, dynamic> accountMap = jsonDecode(accountJson);
      print(accountMap);
      return Info.fromJson(accountMap);
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
