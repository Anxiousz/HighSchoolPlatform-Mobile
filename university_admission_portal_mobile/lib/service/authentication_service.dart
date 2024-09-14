import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:university_admission_portal_mobile/screen/homepage.dart';

class AuthenticationService {
  // Function to perform the login
  Future<void> login(
      String username, String password, BuildContext context) async {
    // Validate input
    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog(
          context, 'Username/Email và password không được để trống.');
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

      // Handle the response
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            json.decode(utf8.decode(response.bodyBytes));
        // Show success message with token
        print('Login successful: ${responseData['data']}');

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const HomePage()));
      } else {
        final Map<String, dynamic> errorData =
            json.decode(utf8.decode(response.bodyBytes));

        _showErrorDialog(context, '${errorData['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _showErrorDialog(context, 'Error during login: $e');
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
}

void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Đăng nhập thất bại !'),
        content: Text(message),
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
