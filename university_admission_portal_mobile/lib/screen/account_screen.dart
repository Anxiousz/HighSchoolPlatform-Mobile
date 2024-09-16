import 'package:flutter/material.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Trang cá nhân',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  "https://img.freepik.com/premium-photo/profile-picture-happy-young-caucasian-man-spectacles-show-confidence-leadership-headshot-portrait-smiling-millennial-male-glasses-posing-indoors-home-employment-success-concept_774935-1446.jpg",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 16),
          Text('Tên: John Doe'),
          SizedBox(height: 16),
          Text('Email: johndoe@example.com'),
          SizedBox(height: 16),
          Text('Số điện thoại: 0987654321'),
          SizedBox(height: 16),
          Text('Địa chỉ: 123, Tôn Thất Thuyết, Phư��ng 12, Quận 1, TP. HCM'),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController, String label, )
}
