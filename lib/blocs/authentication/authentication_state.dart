import 'package:iot_ui/blocs/bloc_helpers/bloc_event_state.dart';
import 'package:meta/meta.dart';

class AuthenticationState extends BlocState {
  AuthenticationState({
    @required this.isAuthenticated,
    @required this.isLoginPage,
    this.isAuthenticating: false,
    this.errorMessage: '',
    this.userName: '',
  });

  final bool isAuthenticated;
  final bool isAuthenticating;
  final String errorMessage;
  final bool isLoginPage;
  final String userName;

  factory AuthenticationState.notAuthenticated(isLoginPage) {
    return AuthenticationState(
      isAuthenticated: false,
      isLoginPage: isLoginPage,
    );
  }

  factory AuthenticationState.authenticated(String userName, bool isLoginPage) {
    return AuthenticationState(
      isAuthenticated: true,
      isLoginPage: isLoginPage,
      userName: userName,
    );
  }

  factory AuthenticationState.authenticating(isLoginPage) {
    return AuthenticationState(
        isAuthenticated: false,
        isAuthenticating: true,
        isLoginPage: isLoginPage);
  }

  factory AuthenticationState.failure(errorMessage, isLoginPage) {
    return AuthenticationState(
      isAuthenticated: false,
      errorMessage: errorMessage,
      isLoginPage: isLoginPage,
    );
  }
}
