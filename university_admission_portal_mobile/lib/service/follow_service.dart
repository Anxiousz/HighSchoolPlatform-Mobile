import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FollowService {
  Future<void> unFollowUniMajor(
      String token, String universityMajorId, BuildContext context) async {
    print(token);
    print(universityMajorId);
    final url =
        'https://uaportal.online/api/v1/follow/university/major/$universityMajorId';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('Successfully unfollowed university major');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Huỷ theo dõi thành công')),
        );
      } else {
        print('Failed to unfollow: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to unfollow. Please try again.')),
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
