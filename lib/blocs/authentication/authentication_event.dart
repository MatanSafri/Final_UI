import 'package:iot_ui/blocs/bloc_helpers/bloc_event_state.dart';

abstract class AuthenticationEvent extends BlocEvent {
  final String email;
  final String password;

  AuthenticationEvent({
    this.email: '',
    this.password: '',
  });
}

class AuthenticationEventChangeScreen extends AuthenticationEvent {}

class AuthenticationEventLogin extends AuthenticationEvent {
  AuthenticationEventLogin({String email, String password})
      : super(
          email: email,
          password: password,
        );
}

class AuthenticationEventRegister extends AuthenticationEvent {
  AuthenticationEventRegister({String email, String password})
      : super(
          email: email,
          password: password,
        );
}

class AuthenticationEventLogout extends AuthenticationEvent {}
