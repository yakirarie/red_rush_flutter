import 'dart:math';

import 'package:flutter/material.dart';
import 'package:red_rush_flutter/colors.dart';
import 'package:red_rush_flutter/models/characters.dart';
import 'package:red_rush_flutter/services/auth.dart';
import 'package:red_rush_flutter/models/user.dart';
import 'loading.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _authService = AuthService();
  bool loading = false;
  final rand = Random().nextInt(goodGuys.length);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Red Rush",
        ),
        centerTitle: true,
        titleSpacing: 5.4,
        elevation: 7,
        backgroundColor: mainColor,
      ),
      body: Container(
          padding: EdgeInsets.symmetric(vertical: 50, horizontal: 10),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: FractionalOffset.centerLeft,
                end: FractionalOffset.centerRight,
                colors: [
                  Colors.red.withOpacity(0.7),
                  Colors.green.withOpacity(0.9),
                ],
              )),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 180,
                    width: 180,
                    child: goodGuys[rand],

                  ),
                  SizedBox(
                    height: 40,
                  ),
                  FlatButton.icon(
                    icon: Icon(Icons.person_outline),
                    label: Text(
                      'Play As Guest',
                      style: TextStyle(color: textColorBars),
                    ),
                    onPressed: () async {
                      setState(() {
                        loading = true;
                      });
                      User result = await _authService.signInAnon();
                      result == null ? print("error") : print(result.uid);
                      setState(() {
                        loading = false;
                      });
                    },
                    color: textColorBody,
                  ),
                  FlatButton.icon(
                    icon: Icon(Icons.mail_outline),
                    label: Text(
                      'Sign In With GMail',
                      style: TextStyle(color: textColorBars),
                    ),
                    onPressed: () async {
                      setState(() {
                        loading = true;
                      });
                      User result = await _authService.signInGoogle();
                      result == null ? print("error") : print(result.uid);
                      setState(() {
                        loading = false;
                      });
                    },
                    color: textColorBody,
                  ),
                ],
              ),
              loading ? Loading() : Container(),
            ],
          )),
      backgroundColor: Colors.white,
    );
  }
}
