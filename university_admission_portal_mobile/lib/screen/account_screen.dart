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
        title: const Text(
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
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  "https://img.freepik.com/premium-photo/profile-picture-happy-young-caucasian-man-spectacles-show-confidence-leadership-headshot-portrait-smiling-millennial-male-glasses-posing-indoors-home-employment-success-concept_774935-1446.jpg",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Tên: John Doe'),
          const SizedBox(height: 16),
          const Text('Email: johndoe@example.com'),
          const SizedBox(height: 16),
          const Text('Số điện thoại: 0987654321'),
          const SizedBox(height: 16),
          const Text(
              'Địa chỉ: 123, Tôn Thất Thuyết, Phư��ng 12, Quận 1, TP. HCM'),
        ],
      ),
    );
  }

  // Widget _buildTextField(TextEditingController, String label, )
}
