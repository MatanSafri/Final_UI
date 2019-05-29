import 'package:iot_ui/blocs/authentication/authentication_event.dart';
import 'package:iot_ui/blocs/authentication/authentication_state.dart';
import 'package:iot_ui/blocs/bloc_helpers/bloc_event_state.dart';
import 'package:iot_ui/services/DAL.dart';
import 'package:iot_ui/services/authentication.dart';
import 'package:iot_ui/validators/validator_email.dart';
import 'package:iot_ui/validators/validator_password.dart';
import 'package:rxdart/rxdart.dart';

class AuthenticationBloc
    extends BlocEventStateBase<AuthenticationEvent, AuthenticationState>
    with EmailValidator, PasswordValidator {
  AuthenticationBloc()
      : super(
          initialState: AuthenticationState.notAuthenticated(true),
        );

  static final BaseAuth auth = new Auth();

  final BehaviorSubject<String> _emailController = BehaviorSubject<String>();
  final BehaviorSubject<String> _passwordController = BehaviorSubject<String>();
  final BehaviorSubject<String> _passwordConfirmController =
      BehaviorSubject<String>();

  //
  //  Inputs
  //
  Function(String) get onEmailChanged => _emailController.sink.add;
  Function(String) get onPasswordChanged => _passwordController.sink.add;
  Function(String) get onRetypePasswordChanged =>
      _passwordConfirmController.sink.add;

  //
  // Validators
  //
  Stream<String> get email => _emailController.stream.transform(validateEmail);
  Stream<String> get password =>
      _passwordController.stream.transform(validatePassword);
  Stream<String> get confirmPassword => _passwordConfirmController.stream
          .transform(validatePassword)
          .doOnData((String c) {
        // If the password is accepted (after validation of the rules)
        // we need to ensure both password and retyped password match
        if (0 != _passwordController.value.compareTo(c)) {
          // If they do not match, add an error
          _passwordConfirmController.addError("No Match");
        }
      });

  //
  // Registration button
  Stream<bool> get registerValid =>
      (lastState != null && lastState.isLoginPage) ||
              (lastState == null && initialState.isLoginPage)
          ? Observable.combineLatest2(email, password, (e, p) => true)
          : Observable.combineLatest3(
              email, password, confirmPassword, (e, p, c) => true);

  @override
  void dispose() {
    print("authbloc disposed \n");
    _emailController?.close();
    _passwordController?.close();
    _passwordConfirmController?.close();
  }

  @override
  Stream<AuthenticationState> eventHandler(
      AuthenticationEvent event, AuthenticationState currentState) async* {
    if (event is AuthenticationEventLogin ||
        event is AuthenticationEventRegister) {
      // Inform that we are proceeding with the authentication
      yield AuthenticationState.authenticating(currentState.isLoginPage);

      // call to the authentication server
      try {
        String userId = currentState.isLoginPage
            ? await auth.signIn(event.email, event.password)
            : await auth.signUp(event.email, event.password);

        // if new user creating the user systems on firestore
        if (!currentState.isLoginPage)
          await DAL.updateUserSystems(userId, List<String>());
        yield AuthenticationState.authenticated(
            userId, currentState.isLoginPage);
      } catch (e) {
        // String errorMessage;
        //  if (_isIos) {
        //     errorMessage = e.details;
        //   } else
        //     errorMessage = e.message;
        // }
        yield AuthenticationState.failure(e.message, currentState.isLoginPage);
      }

      // if (userId != null && userId.length > 0)
      //   yield AuthenticationState.authenticated(userId);
      // else
      //   yield AuthenticationState.failure();
    } else if (event is AuthenticationEventLogout) {
      yield AuthenticationState.notAuthenticated(true);
    } else if (event is AuthenticationEventChangeScreen) {
      yield AuthenticationState.notAuthenticated(!currentState.isLoginPage);
    }
  }
}
