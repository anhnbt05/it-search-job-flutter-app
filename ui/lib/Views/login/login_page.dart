import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:ui/ViewModels/login/SignInViewModel.dart';
import 'package:ui/ViewModels/login/LoginNavigationViewModel.dart';
import '../../Helpers/toastification.dart';
import '../../main.dart';

class LoginPage extends StatefulWidget {
  final void Function(String, String) onLoginSuccess;
  const LoginPage({Key? key, required this.onLoginSuccess}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SignInViewModel(),
      child: Scaffold(
        body: Consumer<SignInViewModel>(
          builder: (context, signInViewModel, child) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                MediaQuery.of(context).size.width * 0.08,
                MediaQuery.of(context).size.height * 0.05,
                MediaQuery.of(context).size.width * 0.08,
                0,
              ),
              constraints: BoxConstraints.expand(),
              color: Colors.white,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height * 0.25,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/job-search-background.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                      child: Container(
                        width: 70,
                        height: 70,
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.purple, Colors.blueAccent],
                          ),
                        ),
                        child: Icon(Icons.key, size: 45, color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                      child: Text(
                        "Xin chào\nChào mừng bạn trở lại",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 30),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                      child: TextField(
                        controller: _usernameController,
                        style: TextStyle(fontSize: 18, color: Colors.black),
                        decoration: InputDecoration(
                          labelText: "EMAIL",
                          labelStyle: TextStyle(color: Colors.grey, fontSize: 15),
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                      child: Stack(
                        alignment: AlignmentDirectional.centerEnd,
                        children: [
                          TextField(
                            controller: _passwordController,
                            style: TextStyle(fontSize: 18, color: Colors.black),
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              labelText: "MẬT KHẨU",
                              labelStyle: TextStyle(color: Colors.grey, fontSize: 15),
                              prefixIcon: Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: signInViewModel.isLoading
                              ? null
                              : () async {
                           final Map<String, dynamic>? payload = await signInViewModel.signIn(
                              context,
                              _usernameController.text,
                              _passwordController.text,
                            );
                            if (signInViewModel.errorMessage != null) {
                              showTopToastification(
                                content: signInViewModel.errorMessage!,
                                title: "Thất bại",
                                color:  Colors.red,
                                icon:  Icons.error_outline,
                              );
                            } else if (payload != null) {
                              final String role = payload['app_metadata']['role'];
                              final String userId = payload['sub'];
                              widget.onLoginSuccess(role, userId);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: signInViewModel.isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text("ĐĂNG NHẬP", style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                    ),
                    Container(
                      height: 130,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => LoginNavigationViewModel().goToRegister(context),
                            child: Text("ĐĂNG KÝ TÀI KHOẢN MỚI", style: TextStyle(fontSize: 15, color: Colors.grey)),
                          ),
                          TextButton(
                            onPressed: () => LoginNavigationViewModel().goToForgotPassword(context),
                            child: Text("QUÊN MẬT KHẨU", style: TextStyle(fontSize: 15, color: Colors.blue)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
