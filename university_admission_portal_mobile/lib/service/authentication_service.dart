import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uni_ad_portal/main.dart';
import 'package:uni_ad_portal/screen/homepage.dart';
import 'dart:convert';

import 'package:uni_ad_portal/screen/otp.dart';
import 'package:uni_ad_portal/screen/test.dart';

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
    try {
      final response = await http.post(
        Uri.parse('https://uaportal.online/api/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      final Map<String, dynamic> responseData =
          json.decode(utf8.decode(response.bodyBytes));

      // Handle the response
      if (responseData['status'] == 200) {
        // Test case 1 : If not role User
        if (responseData['data']['user']['role'] != 'USER') {
          _showErrorDialog(
              context, 'Hệ thống chỉ áp dụng cho người dùng ', null);
          return;
        }

        // Test case 2 : Show success message with token
        print('Login successful: ${responseData['data']}');

        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => const HomePage()));
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) {
              return HomePage();
            },
          ),
          (route) => false,
        );
      } else if (responseData['status'] == 400 ||
          responseData['status'] == 500 ||
          responseData['status'] == 404) {
        _showErrorDialog(context, responseData['message'] ?? 'Unknown error',
            responseData['errors']);
      } else {
        _showErrorDialog(context, 'An unexpected error occurred', null);
      }
    } catch (e) {
      _showErrorDialog(context, 'Error during login: $e', null);
    }
  }

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
