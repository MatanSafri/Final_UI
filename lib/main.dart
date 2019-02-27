import 'package:flutter/material.dart';
import 'package:iot_ui/services/authentication.dart';
import 'login_signup_page.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Flutter Login Demo',
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new LoginSignUpPage(auth: Auth()));
  }
}
