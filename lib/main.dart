import 'package:flutter/material.dart';
import 'package:iot_ui/blocs/authentication/authentication_bloc.dart';
import 'package:iot_ui/blocs/bloc_helpers/bloc_provider.dart';
import 'package:iot_ui/pages/decision_page.dart';
import 'package:iot_ui/pages/home_page.dart';
import 'package:iot_ui/pages/initialization_page.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthenticationBloc>(
        bloc: AuthenticationBloc(),
        child: MaterialApp(
          title: 'Software for IOT',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: InitializationPage(),
          routes: {
            '/decision': (BuildContext context) => DecisionPage(),
            '/homepage': (BuildContext context) => HomePage(),
          },
        ));
  }
}
