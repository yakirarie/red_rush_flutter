import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:red_rush_flutter/models/user.dart';
import 'package:red_rush_flutter/services/database.dart';
import 'package:red_rush_flutter/ui/sign_in.dart';
import 'main_menu.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    if (user == null) return SignIn();
    return StreamProvider<UserData>.value(value: DatabaseService(uid: user.uid).userData ,child: MainMenu());
  }
}
