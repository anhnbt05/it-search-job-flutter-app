import 'package:flutter/material.dart';
import 'package:ui/model.dart';
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
          padding: EdgeInsets.fromLTRB(30, 50, 30, 0),
          constraints: BoxConstraints.expand(),
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget> [
                Positioned.fill(
                    child: Image.asset(
                      'assets/job-search-background.avif',
                      fit: BoxFit.cover,
                    )),
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
                    child: Icon(Icons.key, size: 45, color: Colors.white)
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                  child: Text("Hello\nWelcome Back", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 30),),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                  child: TextField(
                    controller: _usernameController,
                    readOnly: false,
                    style: TextStyle(fontSize: 18,color: Colors.black),
                    decoration: InputDecoration(
                        labelText: "USERNAME",
                        labelStyle: TextStyle(color: Colors.grey, fontSize: 15),
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)
                        )
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
                            labelStyle: TextStyle(color: Colors.grey, fontSize: 15),
                            prefixIcon: Icon(Icons.lock),
                            suffixIcon: IconButton(onPressed: (){},
                                icon: Icon(
                                   Icons.visibility_off,
                                  color: Colors.blue,
                                )),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)
                            )
                        ),
                      ),
                      // Text("SHOW", style: TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.bold),)
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
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
                      TextButton(
                        onPressed: () {},
                        child: Text("NEW USER? SIGN UP", style: TextStyle(fontSize: 15, color: Colors.grey),)
                      ),
                      TextButton(onPressed: () {},
                           child:  Text("FORGOT PASSWORD?", style: TextStyle(fontSize: 15, color: Colors.blue),)
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
