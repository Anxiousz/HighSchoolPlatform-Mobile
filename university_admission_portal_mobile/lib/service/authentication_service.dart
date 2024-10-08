import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uni_ad_portal/helper/sharedpreferenceshelper.dart';
import 'package:uni_ad_portal/main.dart';
import 'package:uni_ad_portal/models/userInfo.dart';
import 'package:uni_ad_portal/screen/homepage.dart';
import 'dart:convert';

import 'package:uni_ad_portal/screen/otp.dart';

class AuthenticationService {
  // Function to perform the login
  Future<void> login(
      String username, String password, BuildContext context) async {
    // Validate input
    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog(
          context, 'Username/Email và password không được để trống.', null);
      return;
    }

    // Create the request body
    final Map<String, dynamic> requestBody = {
      'username': username,
      'password': password,
    };

    // Send the POST request
    // try {
    final response = await http.post(
      Uri.parse('https://uaportal.online/api/v1/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );

    final Map<String, dynamic> responseData =
        json.decode(utf8.decode(response.bodyBytes));

    // Handle the response
    if (responseData['status'] == 200) {
      if (responseData['data']['user']['role'] == 'USER') {
        // Show success message with token
        print('Login successful: ${responseData}');
        Info userInfo = Info.fromJson(responseData);
        Sharedpreferenceshelper.saveAccount(
            userInfo, responseData['data']['accessToken']);
        //Logout dong nay
        // Sharedpreferenceshelper.removeInfo();
        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => const HomePage()));
        String accessToken = responseData['data']['accessToken'];
        await saveFCMToken(accessToken);

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) {
              return const HomePage();
            },
          ),
          (route) => false,
        );
      } else {
        _showErrorDialog(context, 'Hệ thống chỉ dành cho người dùng', null);
        print('Login successful: ${responseData['data']}');
      }
    } else if (responseData['status'] == 400 ||
        responseData['status'] == 500 ||
        responseData['status'] == 404) {
      _showErrorDialog(context, responseData['message'] ?? 'Unknown error',
          responseData['errors']);
    } else {
      _showErrorDialog(context, 'An unexpected error occurred', null);
      print('Login successful: ${responseData['data']}');
    }
    // } catch (e) {
    //   _showErrorDialog(context, 'Error during login: $e', null);
    // }
  }

  Future<void> saveFCMToken(String accessToken) async {
    // Lấy FCM token từ Firebase
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken != null) {
      // Gửi FCM token tới server
      try {
        final response = await http.post(
          Uri.parse(
              'https://uaportal.online/api/v1/follow/fcm-token?fcmToken=$fcmToken'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken', // Đính kèm accessToken
          },
        );
        Sharedpreferenceshelper.saveFCMToken(fcmToken);
        if (response.statusCode == 200) {
          print('FCM token saved successfully');
        } else {
          print('Failed to save FCM token: ${response.statusCode}');
        }
      } catch (e) {
        print('Error occurred while saving FCM token: $e');
      }
    }
  }

  // Future<void> logout() async {{
  // }} as

  // Function to perform the registration
  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String middleName,
    required String lastName,
    required String phone,
    required String gender,
    required String specificAddress,
    required String educationLevel,
    required int provinceId,
    required int districtId,
    required int wardId,
    required String birthday,
    required BuildContext context,
    required String provider,
  }) async {
    final Map<String, dynamic> requestBody = {
      'username': username,
      'email': email,
      'password': password,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'phone': phone,
      'gender': gender,
      'specific_address': specificAddress,
      'education_level': educationLevel,
      'province_id': provinceId,
      'district_id': districtId,
      'ward_id': wardId,
      'birthday': birthday,
      'provider': 'SYSTEM',
    };

    // Log all fields
    print('Registration request:');
    requestBody.forEach((key, value) {
      print('$key: $value');
    });

    try {
      final response = await http.post(
        Uri.parse('https://uaportal.online/api/v1/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      final Map<String, dynamic> responseData =
          json.decode(utf8.decode(response.bodyBytes));

      // Log the response
      print('Registration response:');
      print('Status: ${responseData['status']}');
      print('Response body: ${response.body}');

      if (responseData['status'] == 200) {
        print('Registration successful: ${responseData['data']}');
        _showSnackbar(context, 'Registration successful!');

        final String suid = responseData['data']['suid'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationPage(
              email: email,
              sUID: suid,
            ),
          ),
        );
      } else if (responseData['status'] == 400 ||
          responseData['status'] == 500 ||
          responseData['status'] == 404) {
        if (responseData.containsKey('errors') &&
            responseData['errors'] is Map<String, dynamic>) {
          print('Registration errors:');
          (responseData['errors'] as Map<String, dynamic>)
              .forEach((key, value) {
            print('$key: $value');
          });
          _showErrorDialog(
              context,
              responseData['message'] ?? 'Registration failed',
              responseData['errors']);
        } else {
          print('Registration failed: ${responseData['message']}');
          _showErrorDialog(
              context, responseData['message'] ?? 'Unknown error', null);
        }
      } else {
        _showErrorDialog(context, 'An unexpected error occurred', null);
      }
    } catch (e) {
      print('Error during registration: $e');
      _showErrorDialog(context, 'Error during registration: $e', null);
    }
  }

  static Future<dynamic> getProfile(String accessToken) async {
    final response = await http.get(
      Uri.parse('https://uaportal.online/api/v1/user/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print(jsonData);
      Info _acc = Info.fromJson(jsonData);
      print(_acc);
      return _acc;
    } else if (response.statusCode == 404 || response.statusCode == 500) {
      print("Failedddddddddd");
    } else {
      print('Error during Gettttttttttttttt: ${response.statusCode}');
    }
  }

  Future<dynamic> updateProfile(
    String firstName,
    String middleName,
    String lastName,
    String phone,
    String birthday,
    String gender,
    String accessToken,
    String education_level,
    int province_id,
    int ward_id,
    int district_id,
    String avatar,
    String specific_address,
  ) async {
    Map<String, String?> data = {
      "firstName": firstName,
      "middleName": middleName,
      "lastName": lastName,
      "phone": phone,
      "birthday": birthday,
      "gender": gender,
      "education_level": education_level,
      "specific_address": specific_address,
      "province": province_id.toString(),
      "district": district_id.toString(),
      "ward": ward_id.toString(),
      "avatar": avatar,
    };
    String jsonBody = jsonEncode(data);
    print(jsonBody);

    final response = await http.put(
      Uri.parse('https://uaportal.online/api/v1/user/profile/mobile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonBody,
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print(response.body);
      Info userInfo = Info.fromJson(jsonData);
      await Sharedpreferenceshelper.saveAccount(
          userInfo, userInfo.data!.accessToken!);
      return "Successfully Updateddddd";
    } else {
      return "FAILEDDDDDDDDDDDDDDDDD";
    }
  }

  // Function to verify OTP
  Future<void> verifyOtp(
      String email, String suid, String otp, BuildContext context) async {
    final Map<String, dynamic> requestBody = {
      'email': email,
      'otpFromEmail': otp,
    };

    try {
      final response = await http.post(
        Uri.parse('https://uaportal.online/api/v1/auth/verify-account/$suid'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      final Map<String, dynamic> responseData =
          json.decode(utf8.decode(response.bodyBytes));

      if (responseData['status'] == 200) {
        _showSnackbar(context, 'OTP verification successful!');
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const Main()));
      } else if (responseData['status'] == 400 ||
          responseData['status'] == 500 ||
          responseData['status'] == 404) {
        _showErrorDialog(
            context,
            responseData['message'] ?? 'OTP verification failed',
            responseData['errors']);
      } else {
        _showErrorDialog(context, 'An unexpected error occurred', null);
      }
    } catch (e) {
      _showErrorDialog(context, 'Error during OTP verification: $e', null);
    }
  }

  // Function to show a SnackBar with the given message
  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Function to show an error dialog
  void _showErrorDialog(
      BuildContext context, String message, Map<String, dynamic>? errors) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
                if (errors != null) ...[
                  const SizedBox(height: 10),
                  const Text('Details:'),
                  ...errors.entries
                      .map((entry) => Text('- ${entry.key}: ${entry.value}')),
                ],
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
