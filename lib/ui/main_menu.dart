import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:red_rush_flutter/colors.dart';
import 'package:red_rush_flutter/models/characters.dart';
import 'package:red_rush_flutter/models/scores.dart';
import 'package:red_rush_flutter/models/user.dart';
import 'package:red_rush_flutter/services/auth.dart';
import 'package:red_rush_flutter/ui/game.dart';
import 'package:red_rush_flutter/ui/loading.dart';
import 'package:red_rush_flutter/services/database.dart';
import 'package:red_rush_flutter/ui/score_tile.dart';
import 'package:red_rush_flutter/ui/settings_form.dart';
import 'points_list.dart';

final FirebaseDatabase database = FirebaseDatabase.instance;
bool loading = false;
AudioCache cache = new AudioCache();
AudioPlayer player = new AudioPlayer();

void _stopFile() {
  player?.stop(); // stop the file like this
}

void _playFile() async {
  _stopFile();
  player = await cache.loop('mp3/redrush_mainmenu.mp3');
}


class MainMenu extends StatefulWidget {

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> with WidgetsBindingObserver {
  final AuthService _authService = AuthService();
  User user;
  bool music;


  @override
  void initState() {
    super.initState();
    _playFile();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state.index == 2) { //on pause
      if (user.dislpayName == "Guest") _authService.signOut();
    }

    if (state.index == 2 || state.index == 1) { //on pause/inactive
      _stopFile();
      setState(() {
        music = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    music = music ?? true;
    user = Provider.of<User>(context);

    void _showSettingsPanel() {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              child: SettingsFrom(onSoundChange: (on) {
                setState(() {
                  music = on;
                });
                on ? _playFile() : _stopFile();
              }, music: music,),
            );
          });
    }

    void _showInfo() {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: new Text("About Red Rush"),
            content: Column(
                mainAxisAlignment: MainAxisAlignment.start, children: [
              SizedBox(
                height: 20.0,
              ),
              MyText(
                  textColor: textColorBody,
                  text:
                  "Swipe left, right, up or down to move around and gain points"),
              SizedBox(
                height: 60.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 70,
                    width: 70,
                    child: badGuys[0],

                  ),
                  SizedBox(
                    width: 20.0,
                  ),
                  MyText(
                      textColor: textColorBody,
                      text:
                      "1 point"),
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 70,
                    width: 70,
                    child: badGuys[1],

                  ),
                  SizedBox(
                    width: 20.0,
                  ),
                  MyText(
                      textColor: textColorBody,
                      text:
                      "3 points"),
                ],
              ),
              Expanded(

                child: Container(alignment: Alignment.bottomCenter,
                  child: MyText(textColor: textColorBody,
                    text: "Created By Yakir Arie\n © 2019 Red Rush",),),
              )
            ]),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (user.dislpayName == "Guest") await _authService.signOut();
        return true;
      },
      child: StreamProvider<List<Scores>>.value(
          value: DatabaseService().users,
          child: Scaffold(
            appBar: AppBar(
              title: Container(
                padding: EdgeInsets.symmetric(vertical: 50, horizontal: 10),
                child: MyText(
                  textColor: textColorBars,
                  text: user.dislpayName.split(" ")[0],
                ),
              ),
              titleSpacing: 5.4,
              elevation: 7,
              backgroundColor: mainColor,
              actions: <Widget>[
                IconButton(icon: Icon(Icons.info), onPressed: _showInfo),
                FlatButton.icon(
                  icon: Icon(Icons.person),
                  label: Text("Log Out"),
                  onPressed: () async {
                    setState(() {
                      loading = true;
                    });
                    await _authService.signOut();
                    setState(() {
                      loading = false;
                    });
                    _stopFile();
                  },
                ),
                FlatButton.icon(
                    onPressed: () => _showSettingsPanel(),
                    icon: Icon(Icons.settings),
                    label: Text("settings"))
              ],
            ),
            body: MyBody(flipMusicMode: (on) {
              on ? _stopFile() : _playFile();
            },music: music),
            bottomNavigationBar: MyBottomNavigationBar(),
            backgroundColor: Colors.white,
          )),
    );
  }
}

class MyBottomNavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scores = Provider.of<List<Scores>>(context) ?? [];
    final user = Provider.of<User>(context);

    void _showWorld(scores) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: new Text("Top Players"),
            content: PointsList(
              scores: scores,
            ),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    void _showOwn(scores) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: new Text(user.dislpayName),
            content: PlayerScore(
              scoresMap: scores,
            ),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return StreamBuilder<UserData>(
        stream: DatabaseService(uid: user.uid).userData,
        builder: (context, snapshot) {
          UserData userData = snapshot.data;

          return Container(
            child: BottomNavigationBar(

              onTap: (ind) =>
              ind == 1
                  ? _showWorld(scores)
                  : _showOwn(sortScoresMap(userData.scores)),
              items: [
                BottomNavigationBarItem(
                    icon: Icon(Icons.list, color: Colors.white,),
                    title: MyText(
                      textColor: textColorBars,
                      text: "Your Scores",
                    )),
                BottomNavigationBarItem(
                    icon: Icon(Icons.score, color: Colors.white),
                    title: MyText(
                      textColor: textColorBars,
                      text: "Top Players",
                    )),
              ],
              elevation: 22,
              backgroundColor: mainColor,
            ),
          );
        });
  }
}

class MyText extends StatelessWidget {
  final String text;
  final Color textColor;

  MyText({Key key, this.textColor, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 16.8,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
          ),
        ));
  }
}

class MyBody extends StatefulWidget {
  final Function(bool) flipMusicMode;
  bool music;
  MyBody({Key key, this.flipMusicMode,this.music}) : super(key: key);

  @override
  _MyBodyState createState() => _MyBodyState();
}

class _MyBodyState extends State<MyBody> {
  double _choseSize;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return StreamBuilder<UserData>(
        stream: DatabaseService(uid: user.uid).userData,
        builder: (context, snapshot) {
          UserData userData = snapshot.data;
          return Container(
              padding: EdgeInsets.symmetric(vertical: 50, horizontal: 10),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Image(
                        image: AssetImage("assets/png/pixeredrush.png"),
                      ),
                      Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 50, horizontal: 10)),
                      MyText(
                        textColor: textColorBody,
                        text:
                        "Gain as many points as possible before half of the stage is filled!"
                            .toUpperCase(),
                      ),
                      Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10)),
                      MySlider(
                        onSliderChange: (val) =>
                            setState(() => _choseSize = val),
                      ),
                      Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10)),
                      GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                            color: textColorBody,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.play_arrow),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  if(widget.music)
                                    widget.flipMusicMode(widget.music);
                                  return Game(
                                      boardSize: (_choseSize ?? 3).round(),
                                      userData: userData, flipMusicMode: widget.flipMusicMode,music: widget.music);
                                },
                              ));
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                  loading ? Loading() : Container(),
                ],
              ));
        });
  }
}

class MySlider extends StatefulWidget {
  final Function(double) onSliderChange;

  MySlider({Key key, this.onSliderChange}) : super(key: key);

  @override
  _MySliderState createState() => _MySliderState();
}

class _MySliderState extends State<MySlider> {
  double _sliderValue = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Slider(
        value: _sliderValue,
        onChanged: (newVal) {
          setState(() => _sliderValue = newVal);
          widget.onSliderChange(newVal + 3);
        },
        max: 6,
        min: 0,
        activeColor: sliderColor,
        label: '${_sliderValue.round() + 3} X ${_sliderValue.round() + 3}',
        divisions: 6,
      ),
    );
  }
}
