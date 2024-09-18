// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_ad_portal/helper/sharedpreferenceshelper.dart';
import 'package:uni_ad_portal/models/userInfo.dart';
import 'package:unicons/unicons.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

void dispose() {}

class _AccountScreenState extends State<AccountScreen> {
  // ignore: unused_field
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _phoneController = new TextEditingController();
  TextEditingController _dobController = new TextEditingController();
  TextEditingController _genderController = new TextEditingController();
  List<String> list = <String>['MALE', 'FEMALE', 'OTHER'];

  late Map<String, dynamic> account;
  late Future getIn4;
  String? initGender;

  Future<Map<String, dynamic>?> getInfo() async {
    Info? userInfo = await Sharedpreferenceshelper.getInfo();
    userInfo!.toJson();
  }

  @override
  void initState() {
    super.initState();
    initGender = list.first;

    // getIn4 = getInfo();

    // getIn4.then((value) {
    //   setState(() {
    //     account = value;
    //   });
    //   print(account);
    // },
    // );
    // _firstNameController.text = "xyz";
  }

  Future<void> _selectDate() async {
    print(1444);
    DateTime? _picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );

    if (_picked != null) {
      setState(() {
        _dobController.text = _picked.toString().split(" ")[0];
      });
    }
  }

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
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
                  borderRadius: BorderRadius.all(
                    Radius.circular(24),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 250,
                child: TextField(
                  obscureText: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Họ',
                    prefixIcon: Icon(UniconsLine.user),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 250,
                child: TextField(
                  obscureText: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Tên đệm',
                    prefixIcon: Icon(UniconsLine.user),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 250,
                child: TextField(
                  obscureText: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Tên',
                    prefixIcon: Icon(UniconsLine.user),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 250,
                child: TextField(
                  obscureText: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                    prefixIcon: Icon(UniconsLine.envelope),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 250,
                child: TextField(
                  obscureText: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Số điện thoại',
                    prefixIcon: Icon(UniconsLine.phone),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 250,
                child: TextField(
                  controller: _dobController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Ngày sinh',
                    prefixIcon: Icon(UniconsLine.calender),
                  ),
                  readOnly: true,
                  onTap: () {
                    _selectDate();
                  },
                ),
              ),
              const SizedBox(height: 20),
              DropdownMenu<String>(
                width: 250,
                initialSelection: list.first,
                onSelected: (String? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    initGender = value!;
                  });
                },
                dropdownMenuEntries:
                    list.map<DropdownMenuEntry<String>>((String value) {
                  return DropdownMenuEntry<String>(value: value, label: value);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
