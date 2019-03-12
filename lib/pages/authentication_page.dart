import 'package:flutter/material.dart';
import 'package:iot_ui/blocs/authentication/authentication_bloc.dart';
import 'package:iot_ui/blocs/authentication/authentication_event.dart';
import 'package:iot_ui/blocs/authentication/authentication_state.dart';
import 'package:iot_ui/blocs/bloc_helpers/bloc_provider.dart';
import 'package:iot_ui/blocs/bloc_widgets/bloc_state_builder.dart';
import 'package:iot_ui/widgets/pending_action.dart';

class AuthenticationPage extends StatefulWidget {
  @override
  _AuthenticationPageState createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  AuthenticationBloc _authenticationBloc;
  TextEditingController _emailController;
  TextEditingController _passwordController;
  TextEditingController _retypeController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _retypeController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController?.dispose();
    _passwordController?.dispose();
    _retypeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //_isIos = Theme.of(context).platform == TargetPlatform.iOS;
    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Software for IOT'),
      ),
      body: BlocEventStateBuilder<AuthenticationEvent, AuthenticationState>(
          bloc: _authenticationBloc,
          builder: (BuildContext context, AuthenticationState state) {
            if (state.isAuthenticating) return PendingAction();

            return _showBody(context, state);
          }),
    );
  }

  Widget _showLogo() {
    return new Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 48.0,
          child: Image.asset('assets/flutter-icon.png'),
        ),
      ),
    );
  }

  Widget _showEmailInput() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
        child: StreamBuilder<String>(
            stream: _authenticationBloc.email,
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              return TextField(
                decoration: InputDecoration(
                    labelText: 'email',
                    errorText: snapshot.error,
                    hintText: 'Email',
                    icon: new Icon(
                      Icons.mail,
                      color: Colors.grey,
                    )),
                controller: _emailController,
                onChanged: _authenticationBloc.onEmailChanged,
                keyboardType: TextInputType.emailAddress,
              );
            }));
  }

  Widget _showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: StreamBuilder<String>(
          stream: _authenticationBloc.password,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            return TextField(
              decoration: InputDecoration(
                  labelText: 'password',
                  errorText: snapshot.error,
                  hintText: 'Password',
                  icon: new Icon(
                    Icons.lock,
                    color: Colors.grey,
                  )),
              controller: _passwordController,
              obscureText: true,
              onChanged: _authenticationBloc.onPasswordChanged,
            );
          }),
    );
  }

  _showRetypePasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: StreamBuilder<String>(
          stream: _authenticationBloc.confirmPassword,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            return TextField(
              decoration: InputDecoration(
                  labelText: 'retype password',
                  errorText: snapshot.error,
                  hintText: 'Password',
                  icon: new Icon(
                    Icons.lock,
                    color: Colors.grey,
                  )),
              controller: _retypeController,
              obscureText: true,
              onChanged: _authenticationBloc.onRetypePasswordChanged,
            );
          }),
    );
  }

  Widget _showPrimaryButton(AuthenticationState state) {
    return StreamBuilder<bool>(
      stream: _authenticationBloc.registerValid,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        var text = state.isLoginPage ? "Log in" : "Register";
        return Padding(
            padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
            child: MaterialButton(
              elevation: 5.0,
              minWidth: 200.0,
              height: 42.0,
              color: Colors.blue,
              child: Text(text,
                  style: new TextStyle(fontSize: 20.0, color: Colors.white)),
              onPressed: (snapshot.hasData && snapshot.data == true)
                  ? () {
                      AuthenticationEvent event = state.isLoginPage
                          ? AuthenticationEventLogin(
                              email: _emailController.text,
                              password: _passwordController.text)
                          : AuthenticationEventRegister(
                              email: _emailController.text,
                              password: _passwordController.text);
                      _authenticationBloc.emitEvent(event);
                    }
                  : null,
            ));
      },
    );
  }

  Widget _showSecondaryButton(AuthenticationState state) {
    return new FlatButton(
        child: state.isLoginPage
            ? new Text('Create an account',
                style:
                    new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300))
            : new Text('Have an account? Log in',
                style:
                    new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
        onPressed: () {
          _authenticationBloc.emitEvent(AuthenticationEventChangeScreen());
        });
  }

  Widget _showErrorMessage(AuthenticationState state) {
    if (state.errorMessage != '') {
      return Padding(
          padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
          child: Text(
            state.errorMessage,
            style: TextStyle(
                fontSize: 13.0,
                color: Colors.red,
                height: 1.0,
                fontWeight: FontWeight.w300),
          ));
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget _showBody(BuildContext context, AuthenticationState state) {
    var children = <Widget>[];

    children.addAll([_showLogo(), _showEmailInput(), _showPasswordInput()]);
    if (!state.isLoginPage) children.add(_showRetypePasswordInput());

    children.addAll([
      _showErrorMessage(state),
      _showPrimaryButton(state),
      _showSecondaryButton(state),
    ]);

    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          child: new ListView(shrinkWrap: true, children: children),
        ));
  }
}
