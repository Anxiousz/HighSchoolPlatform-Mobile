import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:uni_ad_portal/screen/otp.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isCurrentStepValid = false;
  final logger = Logger();

  // Controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController educationLevelController =
      TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController providerController =
      TextEditingController(text: 'SYSTEM');

  // Focus nodes
  final FocusNode usernameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();
  final FocusNode firstNameFocus = FocusNode();
  final FocusNode middleNameFocus = FocusNode();
  final FocusNode lastNameFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();
  final FocusNode birthdayFocus = FocusNode();
  final FocusNode addressFocus = FocusNode();

  String? selectedProvince;
  String? selectedDistrict;
  String? selectedWard;

  List<Map<String, dynamic>> provinces = [];
  List<Map<String, dynamic>> districts = [];
  List<Map<String, dynamic>> wards = [];

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    fetchProvinces();
    passwordController.addListener(_validatePasswords);
    confirmPasswordController.addListener(_validatePasswords);
    _addListeners();
  }

  void _addListeners() {
    usernameController.addListener(_validateCurrentStep);
    emailController.addListener(_validateCurrentStep);
    firstNameController.addListener(_validateCurrentStep);
    lastNameController.addListener(_validateCurrentStep);
    phoneController.addListener(_validateCurrentStep);
    birthdayController.addListener(_validateCurrentStep);
    addressController.addListener(_validateCurrentStep);
  }

  @override
  void dispose() {
    // Dispose controllers
    usernameController.dispose();
    emailController.dispose();
    passwordController.removeListener(_validatePasswords);
    passwordController.dispose();
    confirmPasswordController.removeListener(_validatePasswords);
    confirmPasswordController.dispose();
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    genderController.dispose();
    addressController.dispose();
    educationLevelController.dispose();
    birthdayController.dispose();
    providerController.dispose();

    // Dispose focus nodes
    usernameFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    firstNameFocus.dispose();
    middleNameFocus.dispose();
    lastNameFocus.dispose();
    phoneFocus.dispose();
    birthdayFocus.dispose();
    addressFocus.dispose();
    super.dispose();
  }

  Future<void> fetchProvinces() async {
    try {
      final response = await http.get(
        Uri.parse('https://uaportal.online/api/v1/address/province'),
      );
      if (response.statusCode == 200) {
        setState(() {
          provinces = List<Map<String, dynamic>>.from(
              json.decode(utf8.decode(response.bodyBytes))['data']);
        });
      } else {
        throw Exception("Failed to load provinces");
      }
    } catch (e) {
      logger.e('Error fetching provinces', error: e);
      _showErrorDialog(
          "Không thể tải danh sách tỉnh/thành phố. Vui lòng thử lại sau.");
    }
  }

  Future<void> fetchDistricts(String provinceId) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://uaportal.online/api/v1/address/district/$provinceId'),
      );
      if (response.statusCode == 200) {
        setState(() {
          districts = List<Map<String, dynamic>>.from(
              json.decode(utf8.decode(response.bodyBytes))['data']);
          selectedDistrict = null;
          selectedWard = null;
          wards.clear();
        });
      } else {
        throw Exception("Failed to load districts");
      }
    } catch (e) {
      logger.e('Error fetching districts', error: e);
      _showErrorDialog(
          "Không thể tải danh sách quận/huyện. Vui lòng thử lại sau.");
    }
  }

  Future<void> fetchWards(String districtId) async {
    try {
      final response = await http.post(
        Uri.parse('https://uaportal.online/api/v1/address/ward/$districtId'),
      );
      if (response.statusCode == 200) {
        setState(() {
          wards = List<Map<String, dynamic>>.from(
              json.decode(utf8.decode(response.bodyBytes))['data']);
          selectedWard = null;
        });
      } else {
        throw Exception("Failed to load wards");
      }
    } catch (e) {
      logger.e('Error fetching wards', error: e);
      _showErrorDialog(
          "Không thể tải danh sách phường/xã. Vui lòng thử lại sau.");
    }
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final Map<String, dynamic> requestBody = {
          'username': usernameController.text,
          'email': emailController.text,
          'password': passwordController.text,
          'firstName': firstNameController.text,
          'middleName': middleNameController.text,
          'lastName': lastNameController.text,
          'phone': phoneController.text,
          'gender': genderController.text,
          'specific_address': addressController.text,
          'education_level': educationLevelController.text,
          'province_id': int.parse(selectedProvince ?? '0'),
          'district_id': int.parse(selectedDistrict ?? '0'),
          'ward_id': int.parse(selectedWard ?? '0'),
          'birthday': birthdayController.text,
          'provider': providerController.text,
        };

        final response = await http.post(
          Uri.parse('https://uaportal.online/api/v1/auth/register'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: utf8.encode(json.encode(requestBody)),
        );

        final responseData = json.decode(utf8.decode(response.bodyBytes));

        if (responseData['status'] == 200) {
          final suid = responseData['data']['suid'];

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'])),
          );

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OtpVerificationPage(
                email: emailController.text,
                sUID: suid,
              ),
            ),
          );
        } else {
          String errorMessage =
              responseData['message'] ?? 'Đăng ký thất bại. Vui lòng thử lại.';
          if (responseData['errors'] != null && responseData['errors'] is Map) {
            errorMessage += '\n\n';
            (responseData['errors'] as Map<String, dynamic>)
                .forEach((key, value) {
              errorMessage += '$value\n';
            });
          }
          _showErrorDialog(errorMessage);
        }
      } catch (e) {
        logger.e('Registration error', error: e);
        _showErrorDialog("Đã xảy ra lỗi. Vui lòng thử lại sau.");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Lỗi'),
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

  void _validatePasswords() {
    if (passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        passwordController.text != confirmPasswordController.text) {
      setState(() {
        _isCurrentStepValid = false;
      });
    } else {
      _validateCurrentStep();
    }
  }

  bool _validateCurrentStep() {
    bool isValid = false;
    _formKey.currentState?.save();

    switch (_currentStep) {
      case 0:
        isValid = validateAccountFields();
        break;
      case 1:
        isValid = validatePersonalFields();
        break;
      case 2:
        isValid = validateAddressFields();
        break;
    }

    setState(() {
      _isCurrentStepValid = isValid;
    });

    return isValid;
  }

  bool validateAccountFields() {
    return usernameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        passwordController.text == confirmPasswordController.text;
  }

  bool validatePersonalFields() {
    return firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        genderController.text.isNotEmpty &&
        educationLevelController.text.isNotEmpty &&
        birthdayController.text.isNotEmpty;
  }

  bool validateAddressFields() {
    return selectedProvince != null &&
        selectedDistrict != null &&
        selectedWard != null &&
        addressController.text.isNotEmpty;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        birthdayController.text = DateFormat('yyyy-MM-dd').format(picked);
        _validateCurrentStep();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Đăng ký', style: TextStyle(color: Colors.black)),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Stepper(
            type: StepperType.horizontal,
            currentStep: _currentStep,
            onStepContinue: () {
              if (_validateCurrentStep()) {
                if (_currentStep < 2) {
                  setState(() => _currentStep += 1);
                } else if (_currentStep == 2 && validateAddressFields()) {
                  _registerUser();
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
                );
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() => _currentStep -= 1);
              }
            },
            controlsBuilder: (BuildContext context, ControlsDetails details) {
              bool isCurrentStepValid = false;
              switch (_currentStep) {
                case 0:
                  isCurrentStepValid = validateAccountFields();
                  break;
                case 1:
                  isCurrentStepValid = validatePersonalFields();
                  break;
                case 2:
                  isCurrentStepValid = validateAddressFields();
                  break;
              }

              return Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  children: <Widget>[
                    if (_currentStep > 0)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: details.onStepCancel,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.grey,
                          ),
                          child: const Text('Quay lại'),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading || !isCurrentStepValid
                            ? null
                            : details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(_currentStep == 2 ? 'Đăng ký' : 'Tiếp tục'),
                      ),
                    ),
                  ],
                ),
              );
            },
            steps: [
              Step(
                title: const Text('Tài khoản'),
                content: _buildAccountFields(),
                isActive: _currentStep >= 0,
              ),
              Step(
                title: const Text('Cá nhân'),
                content: _buildPersonalFields(),
                isActive: _currentStep >= 1,
              ),
              Step(
                title: const Text('Địa chỉ'),
                content: _buildAddressFields(),
                isActive: _currentStep >= 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountFields() {
    return Column(
      children: [
        _buildTextField(usernameController, 'Tên Đăng Nhập',
            focusNode: usernameFocus, nextFocus: emailFocus),
        _buildTextField(emailController, 'Email',
            keyboardType: TextInputType.emailAddress,
            focusNode: emailFocus,
            nextFocus: passwordFocus),
        _buildTextField(passwordController, 'Mật Khẩu',
            obscureText: _obscurePassword,
            isPassword: true,
            focusNode: passwordFocus,
            nextFocus: confirmPasswordFocus),
        _buildTextField(confirmPasswordController, 'Xác nhận mật khẩu',
            obscureText: _obscureConfirmPassword,
            isPassword: true,
            focusNode: confirmPasswordFocus),
      ],
    );
  }

  Widget _buildPersonalFields() {
    return Column(
      children: [
        _buildTextField(firstNameController, 'Họ',
            focusNode: firstNameFocus, nextFocus: middleNameFocus),
        _buildTextField(middleNameController, 'Tên Đệm',
            isOptional: true,
            focusNode: middleNameFocus,
            nextFocus: lastNameFocus),
        _buildTextField(lastNameController, 'Tên',
            focusNode: lastNameFocus, nextFocus: phoneFocus),
        _buildTextField(phoneController, 'Số điện thoại',
            keyboardType: TextInputType.phone,
            focusNode: phoneFocus,
            nextFocus: birthdayFocus),
        _buildDropdownField('Giới tính', [
          {'value': 'MALE', 'label': 'Nam'},
          {'value': 'FEMALE', 'label': 'Nữ'},
          {'value': 'OTHER', 'label': 'Khác'}
        ], (value) {
          setState(() {
            genderController.text = value ?? '';
            _validateCurrentStep();
          });
        }),
        _buildDropdownField('Trình độ học vấn', [
          {'value': 'HIGH', 'label': 'Học Sinh'},
          {'value': 'OTHER', 'label': 'Phụ Huynh'}
        ], (value) {
          setState(() {
            educationLevelController.text = value ?? '';
            _validateCurrentStep();
          });
        }),
        _buildTextField(
          birthdayController,
          'Ngày sinh (YYYY-MM-DD)',
          keyboardType: TextInputType.datetime,
          focusNode: birthdayFocus,
          readOnly: true,
          onTap: () => _selectDate(context),
        ),
      ],
    );
  }

  Widget _buildAddressFields() {
    return Column(
      children: [
        _buildDropdownField(
            'Tỉnh/Thành Phố',
            provinces
                .map((p) =>
                    {'value': p['id'].toString(), 'label': p['name'] as String})
                .toList(), (value) {
          setState(() {
            selectedProvince = value;
            fetchDistricts(selectedProvince!);
            _validateCurrentStep();
          });
        }),
        _buildDropdownField(
            'Quận/Huyện',
            districts
                .map((d) =>
                    {'value': d['id'].toString(), 'label': d['name'] as String})
                .toList(), (value) {
          setState(() {
            selectedDistrict = value;
            fetchWards(selectedDistrict!);
            _validateCurrentStep();
          });
        }),
        _buildDropdownField(
            'Phường/Xã',
            wards
                .map((w) =>
                    {'value': w['id'].toString(), 'label': w['name'] as String})
                .toList(), (value) {
          setState(() {
            selectedWard = value;
            _validateCurrentStep();
          });
        }),
        _buildTextField(addressController, 'Địa chỉ cụ thể',
            focusNode: addressFocus),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false,
      TextInputType keyboardType = TextInputType.text,
      bool isOptional = false,
      FocusNode? focusNode,
      FocusNode? nextFocus,
      bool isPassword = false,
      bool readOnly = false,
      VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword
            ? (label == 'Mật Khẩu' ? _obscurePassword : _obscureConfirmPassword)
            : obscureText,
        keyboardType: keyboardType,
        focusNode: focusNode,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: isOptional ? '$label (Không bắt buộc)' : label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey[200],
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red, width: 1.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red, width: 2.0),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    label == 'Mật Khẩu'
                        ? (_obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility)
                        : (_obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                  ),
                  onPressed: () {
                    setState(() {
                      if (label == 'Mật Khẩu') {
                        _obscurePassword = !_obscurePassword;
                      } else {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      }
                    });
                  },
                )
              : (label == 'Ngày sinh (YYYY-MM-DD)'
                  ? const Icon(Icons.calendar_today)
                  : null),
        ),
        validator: (value) {
          if (!isOptional && (value == null || value.isEmpty)) {
            return 'Vui lòng nhập $label';
          }
          if (isPassword && value!.isNotEmpty) {
            if (value.length < 8 || value.length > 16) {
              return 'Mật khẩu phải từ 8 đến 16 ký tự';
            }
            if (!value.contains(RegExp(r'[A-Z]'))) {
              return 'Mật khẩu phải bao gồm ít nhất 1 chữ in hoa';
            }
            if (!value.contains(RegExp(r'[a-z]'))) {
              return 'Mật khẩu phải bao gồm ít nhất 1 chữ thường';
            }
            if (!value.contains(RegExp(r'[0-9]'))) {
              return 'Mật khẩu phải bao gồm ít nhất 1 chữ số';
            }
            if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
              return 'Mật khẩu phải bao gồm ít nhất 1 ký tự đặc biệt';
            }
          }
          if (label == 'Email' && value!.isNotEmpty) {
            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(value)) {
              return 'Vui lòng nhập đúng định dạng email @---.com';
            }
          }
          return null;
        },
        onChanged: (value) {
          _validateCurrentStep();
        },
        onFieldSubmitted: (_) {
          if (nextFocus != null) {
            FocusScope.of(context).requestFocus(nextFocus);
          } else {
            FocusScope.of(context).unfocus();
          }
        },
      ),
    );
  }

  Widget _buildDropdownField(String label, List<Map<String, String>> items,
      Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item['value'],
            child: Text(item['label']!),
          );
        }).toList(),
        onChanged: (value) {
          onChanged(value);
          _validateCurrentStep();
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng chọn $label';
          }
          return null;
        },
      ),
    );
  }
}
