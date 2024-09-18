import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:uni_ad_portal/screen/login.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  final String sUID;

  const OtpVerificationPage({super.key, required this.email, required this.sUID});

  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  int _resendCounter = 60;
  bool _canResend = false;
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_resendCounter > 0) {
        setState(() {
          _resendCounter--;
        });
        _startResendTimer();
      } else {
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  Future<void> _verifyOtp() async {
    String otp = _controllers.map((controller) => controller.text).join();
    if (otp.length != 6) {
      _showErrorDialog('Vui lòng nhập đủ 6 số OTP');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
            'https://uaportal.online/api/v1/auth/verify-account/${widget.sUID}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': widget.email,
          'otpFromEmail': otp,
        }),
      );

      final responseData = json.decode(utf8.decode(response.bodyBytes));

      if (responseData['status'] == 200) {
        _showSuccessDialog();
      } else {
        _showErrorDialog(responseData['message'] ??
            'Xác thực OTP thất bại. Vui lòng thử lại.');
      }
    } catch (e) {
      logger.e('OTP verification error', error: e);
      _showErrorDialog('Đã xảy ra lỗi. Vui lòng thử lại sau.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
            'https://uaportal.online/api/v1/auth/regenerate-otp/${widget.sUID}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': widget.email,
        }),
      );

      final responseData = json.decode(utf8.decode(response.bodyBytes));

      if (responseData['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Mã OTP mới đã được gửi đến email của bạn.')),
        );
        setState(() {
          _resendCounter = 60;
          _canResend = false;
        });
        _startResendTimer();
      } else {
        _showErrorDialog(responseData['message'] ??
            'Gửi lại OTP thất bại. Vui lòng thử lại.');
      }
    } catch (e) {
      logger.e('Resend OTP error', error: e);
      _showErrorDialog('Đã xảy ra lỗi. Vui lòng thử lại sau.');
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thành công'),
          content: const Text('Xác thực OTP thành công!'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác thực OTP'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Nhập mã OTP đã được gửi đến email của bạn',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.email,
                style: const TextStyle(fontSize: 14, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (index) => SizedBox(
                    width: 40,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 2),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        }
                        if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        if (_controllers.every(
                            (controller) => controller.text.isNotEmpty)) {
                          _verifyOtp();
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 50),
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
                    : const Text('Xác nhận'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _canResend ? _resendOtp : null,
                child: Text(
                  _canResend
                      ? 'Gửi lại mã OTP'
                      : 'Gửi lại mã OTP sau $_resendCounter giây',
                  style: TextStyle(
                    color: _canResend ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
