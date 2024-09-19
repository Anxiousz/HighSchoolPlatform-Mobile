// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_ad_portal/helper/sharedpreferenceshelper.dart';
import 'package:uni_ad_portal/models/userInfo.dart';
import 'package:unicons/unicons.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

void dispose() {}

class _AccountScreenState extends State<AccountScreen> {
  // ignore: unused_field
  TextEditingController _firstNameController = new TextEditingController();
  TextEditingController _middleNameController = new TextEditingController();
  TextEditingController _lastNameController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _phoneController = new TextEditingController();
  TextEditingController _dobController = new TextEditingController();
  TextEditingController _genderController = new TextEditingController();

  List<String> list = <String>['MALE', 'FEMALE', 'OTHER'];

  Info? account;
  late Future getIn4;
  late Info loggedInInfo;

  String? accressToken;
  String? initGender;
  String? userEmail;
  String? firstName;
  String? middleName;
  String? lastName;
  String? email;
  String? phone;
  String? gender;
  String? dob;

  Future<Info?> getInfo() async {
    Info? userInfo = await Sharedpreferenceshelper.getInfo();
    return userInfo;
  }

  @override
  void initState() {
    super.initState();
    initGender = list.first;
    getIn4 = getInfo();
    getIn4.then(
      (value) {
        setState(() {
          account = value;

          _firstNameController.text = account!.data!.userInfo!.firstName!;

          _middleNameController.text = account!.data!.userInfo!.middleName!;

          _lastNameController.text = account!.data!.userInfo!.lastName!;
          _emailController.text = account!.data!.user!.email!;
          _phoneController.text = account!.data!.userInfo!.phone!;
          _genderController.text = account!.data!.userInfo!.gender!;
          _dobController.text = account!.data!.userInfo!.birthday!;
        });
      },
    );
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

  // Future<void> getUserInfo(
  //     String? token,
  //     String firstName,
  //     String middleName,
  //     String lastName,
  //     String email,
  //     String phone,
  //     String gender,
  //     String birthday) async {
  //   if (token != null) {
  //     final response = await http.get(
  //       Uri.parse('https://uaportal.online/api/v1/user/profile'),
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Accept': 'application/json',
  //       },
  //     );
  //     if (response.statusCode == 200) {
  //       final data = json.decode(utf8.decode(response.bodyBytes));
  //       setState(() {
  //         loggedInInfo = data['data'];
  //         print(loggedInInfo);
  //       });
  //     } else {
  //       print('Failed to fetch data: ${response.statusCode}');
  //     }
  //   } else {
  //     print('AccessToken is null');
  //   }
  // }

  // static Future<String?> getAccessToken() async {
  //   return await Sharedpreferenceshelper.getAccessToken();
  // }

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
      body: account != null
          ? SingleChildScrollView(
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
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 250,
                      child: TextField(
                        controller: _emailController,
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
                        controller: _phoneController,
                        obscureText: false,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Số điện thoại',
                          prefixIcon: Icon(UniconsLine.phone),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 250,
                      child: TextField(
                        controller: _firstNameController,
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
                        controller: _middleNameController,
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
                        controller: _lastNameController,
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
                      controller: _genderController,
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
                        return DropdownMenuEntry<String>(
                            value: value, label: value);
                      }).toList(),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    FilledButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                            const Color.fromARGB(255, 106, 185, 109)),
                      ),
                      onPressed: () {
                        firstName = _firstNameController.text;
                        middleName = _middleNameController.text;
                        lastName = _lastNameController.text;
                        userEmail = _emailController.text;
                        phone = _phoneController.text;
                        gender = _genderController.text;
                        dob = _dobController.text;
                        print(firstName);
                        print(dob);
                      },
                      child: const Text('Lưu thông tin'),
                    ),
                  ],
                ),
              ),
            )
          : Text("Waiting"),
    );
  }
}
