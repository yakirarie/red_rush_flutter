import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:red_rush_flutter/models/user.dart';
import 'package:red_rush_flutter/services/auth.dart';
import 'UI/wrapper.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
        value: AuthService().user,
        child: MaterialApp(
          navigatorObservers: [RouteObserver()],
          title: "Red Rush",
          home: Wrapper(),
        )
    );
  }
}
