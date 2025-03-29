import 'package:flutter/material.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const LoginPage({Key? key, required this.onLoginSuccess}) : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void onSignInClicked() {

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
          constraints: BoxConstraints.expand(),
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget> [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                child: Container(
                    width: 70,
                    height: 70,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey
                    ),
                    child: FlutterLogo()),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 60),
                child: Text("Hello\nWelcome Back", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 30),),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 60),
                child: TextField(
                  style: TextStyle(fontSize: 18,color: Colors.black),
                  decoration: InputDecoration(
                      labelText: "USER NAME",
                      labelStyle: TextStyle(color: Colors.grey, fontSize: 15)
                  ),),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                child: Stack(
                  alignment: AlignmentDirectional.centerEnd,
                  children: [
                    TextField(
                      style: TextStyle(fontSize: 18,color: Colors.black),
                      obscureText: true,
                      decoration: InputDecoration(
                          labelText: "PASSWORD",
                          labelStyle: TextStyle(color: Colors.grey, fontSize: 15)
                      ),),
                    Text("SHOW", style: TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.bold),)
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: SizedBox( width: double.infinity, height: 56,
                  child: ElevatedButton(
                      onPressed: onSignInClicked,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue
                      ),
                      child: Text("SIGN IN", style: TextStyle(color: Colors.white, fontSize: 16),)
                  ),
                ),
              ),
              Container(
                height: 130,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("NEW USER? SIGN UP", style: TextStyle(fontSize: 15, color: Colors.grey),),
                    Text("FORGOT PASSWORD?", style: TextStyle(fontSize: 15, color: Colors.blue),)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
