import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:red_rush_flutter/models/characters.dart';
import 'package:red_rush_flutter/models/sfx.dart';
import 'package:red_rush_flutter/models/user.dart';
import 'package:red_rush_flutter/services/auth.dart';
import 'package:red_rush_flutter/services/database.dart';
import 'dart:math';
import 'package:swipedetector/swipedetector.dart';

bool loading = false;
AudioCache cache = new AudioCache();
AudioPlayer player = new AudioPlayer();

void _stopFile() {
  player?.stop();
}

void _playFile(int ind) async {
  player = await cache.play(sfx[ind]);
}

class Game extends StatefulWidget {
  final int boardSize;
  final UserData userData;
  final Function(bool) flipMusicMode;
  bool music;

  Game({Key key, this.boardSize, this.userData, this.flipMusicMode, this.music}) : super(key: key);

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> with WidgetsBindingObserver{
  final AuthService _authService = AuthService();
  User user;
  int playerIndex;
  Map<int,bool> enemies;
  bool addEnemy;
  bool finish;
  bool almostFinish;
  int points;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state.index == 2) { //on destroy
      if(user.dislpayName == "Guest") {
        _authService.signOut();
        Navigator.of(context).pop();
      }

    }
  }

  @override
  Widget build(BuildContext context) {

    final double finishCond = (widget.boardSize * widget.boardSize) * 0.5;
    final double almostFinishCond = (widget.boardSize * widget.boardSize) * 0.4;
    user = Provider.of<User>(context);

    Future _updateUserData(newScores) async {
      await DatabaseService(uid: user.uid).updateUserData(
        widget.userData.dislpayName,
        newScores,
        widget.userData.player,
      );
    }

    void _dialog() {
      if (finish ?? false) {
        String title = "You Lost";
        bool newRec = false;
        var newScores = widget.userData.scores;
        if (newScores["${widget.boardSize}X${widget.boardSize}"] < points) {
          newScores["${widget.boardSize}X${widget.boardSize}"] = points;
          _updateUserData(newScores);
          title = "New Own Record!!";
          newRec = true;
        }
        newRec ? _playFile(3) : _playFile(2);
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: CustomDialog(
                title: title,
                description: "Score : $points\nGood Job!",
                buttonText: "Try Again",
                buttonText2: "Back to Main Menu",
                image: newRec
                    ? Image(
                        image: AssetImage("assets/png/star.png"),
                      )
                    : badGuysWon[0],
                onPress1: () {
                  Navigator.of(context).pop();
                  setState(() {
                    playerIndex = null;
                    enemies = null;
                    addEnemy = null;
                    finish = null;
                    almostFinish = null;
                    points = null;
                  });
                  _stopFile();

                },
                onPress2: () {
                  if(widget.music)
                    widget.flipMusicMode(false);
                  _stopFile();
                  Navigator.popUntil(context, (route) {
                    return route.settings.name == "/";
                  });
                }),
          ),
        );
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _dialog());

    //variables
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    List<TableRow> rows = [];
    List<Container> tableCells = [];
    var rng = new Random();

    //stateful variables
    enemies = enemies ?? Map<int, bool>();
    playerIndex =
        playerIndex ?? rng.nextInt(widget.boardSize * widget.boardSize);
    addEnemy = addEnemy ?? true;
    finish = finish ?? false;
    almostFinish = almostFinish ?? false;
    points = points ?? 0;

    //generate enemies
    int firstPositionEnemy = rng.nextInt(widget.boardSize * widget.boardSize);
    if (addEnemy) {
      while (firstPositionEnemy == playerIndex ||
          enemies.containsKey(firstPositionEnemy))
        firstPositionEnemy = rng.nextInt(widget.boardSize * widget.boardSize);
      
      int coinProb = rng.nextInt(10);
      enemies.addAll({firstPositionEnemy : coinProb < 1});
    }

    finish = enemies.length >= finishCond;
    almostFinish = enemies.length >= almostFinishCond;
    if (finish)
      setState(() {
        addEnemy = false;
      });
    //create gui
    for (int i = 0; i < widget.boardSize * widget.boardSize; i++) {
      if (i == playerIndex) {
        tableCells.add(Container(
            width: width / widget.boardSize,
            height: height / widget.boardSize,
            child: Image(
              image: !finish
                  ? (almostFinish
                      ? goodGuysWorried[widget.userData.player].image
                      : goodGuys[widget.userData.player].image)
                  : goodGuysLost[widget.userData.player].image,
              width: width / widget.boardSize,
              height: height / widget.boardSize,
            )));
      } else if (enemies.containsKey(i))
        tableCells.add(Container(
            width: width / widget.boardSize,
            height: height / widget.boardSize,
            child: Image(
              image: (enemies[i] ? badGuys[1].image : (!finish ? badGuys[0].image : badGuysWon[0].image))),
            ));
      else
        tableCells.add(Container(
          width: width / widget.boardSize,
          height: height / widget.boardSize,
        ));
    }

    //fill table
    for (int i = 0;
        i < widget.boardSize * widget.boardSize;
        i += widget.boardSize) {
      List<Container> rowList = [];
      for (int j = i; j < i + widget.boardSize; j++) rowList.add(tableCells[j]);
      rows.add(TableRow(children: rowList));
    }

    return WillPopScope(onWillPop: () async {
      if(widget.music)
        widget.flipMusicMode(false);
      return true;
    },
      child: SwipeDetector(
          swipeConfiguration: SwipeConfiguration(
              verticalSwipeMinVelocity: 100.0,
              verticalSwipeMinDisplacement: 50.0,
              verticalSwipeMaxWidthThreshold: 100.0,
              horizontalSwipeMaxHeightThreshold: 50.0,
              horizontalSwipeMinDisplacement: 50.0,
              horizontalSwipeMinVelocity: 200.0),
          onSwipeDown: () => setState(() {
                int newIndex = playerIndex + widget.boardSize;
                if (!finish) {
                  if (newIndex < widget.boardSize * widget.boardSize) {
                    playerIndex = newIndex;
                    if (enemies.containsKey(playerIndex)) {
                      points += enemies[playerIndex] ? 3 : 1;
                      enemies[playerIndex] ? _playFile(1) : _playFile(0);
                      enemies.remove(playerIndex);

                    }
                    addEnemy = true;
                  } else {
                    addEnemy = false;
                    Flushbar(
                      message: 'Can\'t Go There',
                      animationDuration: Duration(milliseconds: 500),
                      duration: Duration(milliseconds: 800),
                    )..show(context);
                  }
                }
              }),
          onSwipeLeft: () => setState(() {
                int newIndex = playerIndex - 1;
                if (!finish) {
                  if (newIndex % widget.boardSize != widget.boardSize - 1) {
                    playerIndex = newIndex;
                    if (enemies.containsKey(playerIndex)) {
                      points += enemies[playerIndex] ? 3 : 1;
                      enemies[playerIndex] ? _playFile(1) : _playFile(0);

                      enemies.remove(playerIndex);
                    }
                    addEnemy = true;
                  } else {
                    addEnemy = false;
                    Flushbar(
                      message: 'Can\'t Go There',
                      animationDuration: Duration(milliseconds: 500),
                      duration: Duration(milliseconds: 800),
                    )..show(context);
                  }
                }
              }),
          onSwipeRight: () => setState(() {
                int newIndex = playerIndex + 1;

                if (!finish) {
                  if (newIndex % widget.boardSize != 0) {
                    playerIndex = newIndex;
                    if (enemies.containsKey(playerIndex)) {
                      points += enemies[playerIndex] ? 3 : 1;
                      enemies[playerIndex] ? _playFile(1) : _playFile(0);

                      enemies.remove(playerIndex);
                    }
                    addEnemy = true;
                  } else {
                    addEnemy = false;
                    Flushbar(
                      message: 'Can\'t Go There',
                      animationDuration: Duration(milliseconds: 500),
                      duration: Duration(milliseconds: 800),
                    )..show(context);
                  }
                }
              }),
          onSwipeUp: () => setState(() {
                int newIndex = playerIndex - widget.boardSize;

                if (!finish) {
                  if (newIndex >= 0) {
                    playerIndex = newIndex;
                    if (enemies.containsKey(playerIndex)) {
                      points += enemies[playerIndex] ? 3 : 1;
                      enemies[playerIndex] ? _playFile(1) : _playFile(0);

                      enemies.remove(playerIndex);
                    }
                    addEnemy = true;
                  } else {
                    addEnemy = false;
                    Flushbar(
                      message: 'Can\'t Go There',
                      animationDuration: Duration(milliseconds: 500),
                      duration: Duration(milliseconds: 800),
                    )..show(context);
                  }
                }
              }),
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter,
                    colors: [
                  Colors.purple.withOpacity(0.0),
                  Colors.blueAccent,
                ],
                    stops: [
                  0.0,
                  1.0
                ])),
            child: SingleChildScrollView(
              child: Table(
                children: rows,
              ),
            ),
          )),
    );
  }
}

class CustomDialog extends StatelessWidget {
  final String title, description, buttonText, buttonText2;
  final Function() onPress1, onPress2;
  final Image image;

  CustomDialog({
    @required this.title,
    @required this.description,
    @required this.buttonText,
    @required this.buttonText2,
    this.onPress1,
    this.onPress2,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            top: Consts.avatarRadius + Consts.padding,
            bottom: Consts.padding,
            left: Consts.padding,
            right: Consts.padding,
          ),
          margin: EdgeInsets.only(top: Consts.avatarRadius),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(Consts.padding),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Align(
                    alignment: Alignment.bottomRight,
                    child: FlatButton(
                      onPressed: onPress1,
                      child: Text(buttonText),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: FlatButton(
                      onPressed: onPress2,
                      child: Text(buttonText2),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          left: Consts.padding,
          right: Consts.padding,
          child: CircleAvatar(
            child: image,
            backgroundColor: Colors.blueAccent,
            radius: Consts.avatarRadius,
          ),
        ),
      ],
    );
  }
}

class Consts {
  Consts._();

  static const double padding = 16.0;
  static const double avatarRadius = 66.0;
}
