import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_ad_portal/service/authentication_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthenticationService _authService = AuthenticationService();

  bool _isPasswordHidden = true;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          const Text(
                            "Đăng nhập",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Đăng nhập để khám phá đầy đủ các chức năng",
                            style: TextStyle(
                                fontSize: 15, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          children: <Widget>[
                            inputFile(
                              label: "Email/Username",
                              controller: usernameController,
                            ),
                            inputFile(
                              label: "Password",
                              obscureText:
                                  _isPasswordHidden, // Sử dụng trạng thái
                              controller: passwordController,
                              toggleObscureText: () {
                                setState(() {
                                  _isPasswordHidden =
                                      !_isPasswordHidden; // Đảo ngược trạng thái
                                });
                              },
                              isPasswordField: true,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          child: MaterialButton(
                            minWidth: double.infinity,
                            height: 60,
                            onPressed: () async {
                              await _authService.login(
                                usernameController.text,
                                passwordController.text,
                                context,
                              );
                            },
                            color: const Color.fromARGB(255, 11, 182, 82),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Text(
                              "Đăng nhập",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 100),
                        height: 200,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/background.jpg"),
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget inputFile({
  required String label,
  bool obscureText = false,
  required TextEditingController controller,
  VoidCallback? toggleObscureText,
  bool isPasswordField = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 5),
      TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: (Colors.grey[400])!),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: (Colors.grey[400])!),
          ),
          suffixIcon: isPasswordField
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: toggleObscureText,
                )
              : null,
        ),
      ),
      const SizedBox(height: 10),
    ],
  );
}
