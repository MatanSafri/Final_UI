import 'package:flutter/material.dart';
import 'package:iot_ui/blocs/authentication/authentication_bloc.dart';
import 'package:iot_ui/blocs/authentication/authentication_state.dart';
import 'package:iot_ui/blocs/bloc_helpers/bloc_provider.dart';
import 'package:iot_ui/blocs/bloc_widgets/bloc_state_transform_builder.dart';
import 'package:iot_ui/blocs/decision/decision_state_action.dart';
import 'package:iot_ui/blocs/decision/decision_state_transform.dart';

///
/// Version of the DecisionPage which does not
/// contain any business logic related to the
/// action to take, based on the authentication
/// status.
///
/// This page uses the [BlocStateTransformBase]
/// to apply the Business Logic and the
/// [BlocStateTransformBuilder] to be notified
/// of the action to take.
///
/// The [DecisionStateTransform] is the place where
/// all the Business Logic resides.
///
class DecisionPage extends StatefulWidget {
  @override
  DecisionPageState createState() {
    return new DecisionPageState();
  }
}

class DecisionPageState extends State<DecisionPage> {
  DecisionStateTransform decisionStateTransform;
  DecisionStateAction oldAction;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    //
    // Initialization of the State Transform related to this Decision page
    //
    decisionStateTransform = DecisionStateTransform.init(
        BlocProvider.of<AuthenticationBloc>(context));
  }

  @override
  void dispose() {
    print("decision page disposed \n");
    decisionStateTransform?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocStateTransformBuilder<DecisionStateAction, AuthenticationState>(
      transformBloc: decisionStateTransform,
      builder: (BuildContext context, DecisionStateAction action) {
        if (action != oldAction) {
          // As this page is used to route to other pages,
          // once another page is displayed, this page will
          // be rebuilt.  Therefore, we need to prevent from
          // bubbling
          oldAction = action;

          if (action.actionType == DecisionStateActionType.routeToPage) {
            _redirectToPage(context, action.newPage);
          }
        }
        // This page does not need to display anything since it will
        // always remain behind any active page (and thus 'hidden').
        return Container();
      },
    );
  }

  void _redirectToPage(BuildContext context, Widget page) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MaterialPageRoute newRoute =
          MaterialPageRoute(builder: (BuildContext context) => page);

      Navigator.of(context)
          .pushAndRemoveUntil(newRoute, ModalRoute.withName('/decision'));
      print("model route: ${ModalRoute.withName('/decision')} \n");
      print("redirect to $page \n");
    });
  }
}
