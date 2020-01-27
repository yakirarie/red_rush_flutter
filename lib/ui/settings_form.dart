import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:red_rush_flutter/models/characters.dart';
import 'package:red_rush_flutter/models/user.dart';
import 'package:red_rush_flutter/colors.dart';
import 'package:red_rush_flutter/services/database.dart';
import 'package:red_rush_flutter/ui/loading.dart';


class SettingsFrom extends StatefulWidget {
  final Function(bool) onSoundChange;
  bool music;

  SettingsFrom({Key key, this.onSoundChange, this.music}) : super(key: key);

  @override
  _SettingsFromState createState() => _SettingsFromState();
}

class _SettingsFromState extends State<SettingsFrom> {
  final _formKey = GlobalKey<FormState>();
  String _newName;
  int _newPlayer;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return StreamBuilder<UserData>(
        stream: DatabaseService(uid: user.uid).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            UserData userData = snapshot.data;
            return Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Text(
                    "Edit Name",
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    initialValue: userData.dislpayName,
                    validator: (val) =>
                        val.isEmpty ? 'Please enter a name' : null,
                    onChanged: (val) => setState(() => _newName = val),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    "Choose Character",
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    height: 110.0,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: goodGuys.length,
                      itemBuilder: (context, index) {
                        Color updateChosen(index){
                          int chosen = _newPlayer ?? userData.player;
                          return  index == chosen
                              ? mainColor
                              : Colors.white;
                        }
                        return Padding(
                            padding: EdgeInsets.only(right: 5.0, left: 5.0),

                            child: FlatButton(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                                color: updateChosen(index),
                                onPressed: () => setState(() => _newPlayer = index),
                                padding: EdgeInsets.all(0.0),
                                child: goodGuys[index]));
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),


                      Text("Sound", style: TextStyle(fontSize: 18.0),),

                  IconButton(
                      icon: (widget.music) ? Icon(Icons.volume_up) : Icon(Icons.volume_off),
                      onPressed: () {
                        setState(() {
                          widget.music = !widget.music;
                        });
                      }),
                  RaisedButton(
                    color: textColorBody,
                    child: Text(
                      'update',
                      style: TextStyle(color: textColorBars),
                    ),
                    onPressed: () async {
                      final form = _formKey.currentState;
                      if (form.validate()) {
                        await DatabaseService(uid: user.uid).updateUserData(
                            _newName ?? userData.dislpayName,
                            userData.scores,
                            _newPlayer ?? userData.player,
                        );

                        widget.onSoundChange(widget.music);

                        Navigator.pop(context);
                      }
                    },
                  )
                ],
              ),
            );
          } else {
            return Loading();
          }
        });
  }

}
