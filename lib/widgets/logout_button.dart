import 'package:flutter/material.dart';
import 'package:iot_ui/blocs/authentication/authentication_bloc.dart';
import 'package:iot_ui/blocs/authentication/authentication_event.dart';
import 'package:iot_ui/blocs/bloc_helpers/bloc_provider.dart';

class LogOutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AuthenticationBloc bloc = BlocProvider.of<AuthenticationBloc>(context);
    return IconButton(
      icon: Icon(Icons.exit_to_app),
      onPressed: () {
        bloc.emitEvent(AuthenticationEventLogout());
      },
    );
  }
}
