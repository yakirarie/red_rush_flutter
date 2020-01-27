import 'package:flutter/material.dart';
import 'package:red_rush_flutter/models/scores.dart';
import 'package:tuple/tuple.dart';
import 'package:red_rush_flutter/models/characters.dart';

import 'main_menu.dart';

class ScoreTile extends StatelessWidget {
  final Scores scores;

  ScoreTile({this.scores});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
              child: goodGuys[scores.player],
              backgroundColor: Colors.white,
              radius: 25.0),
          title: MyText(text: scores.playerName),
          onTap: ()=> _showDialog(scores.scoresMap, scores.playerName, context),

          subtitle: MyText(text: getBestScore(scores.scoresMap),),
        ),
      ),
    );
  }
}

String getBestScore(scoresMap){
  int maxScore = 0;
  String boardName = "3X3";
  scoresMap.forEach((k, v){
    if (v > maxScore){
      maxScore = v;
      boardName = k;
    }
  });
  return "BEST: $boardName-$maxScore";

}




void _showDialog(Map scores, String name, context) {

  // flutter defined function
  showDialog(
    context: context,
    builder: (context) {
      // return object of type Dialog
      return AlertDialog(
        title: new Text(name),
        content: PlayerScore(scoresMap: scores,),
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

class PlayerScore extends StatelessWidget {
  final Map scoresMap;

  PlayerScore({Key key, this.scoresMap}): super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Tuple2<String,String>> scoresList = _scoresMapToTuplesList();
    return ListView.builder(
      itemCount: scoresList.length,
      itemBuilder: (context, index){
        return Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Card(
            child: ListTile(
              leading: CircleAvatar(
                  child: Image(
                    image: AssetImage("assets/png/pixeredrush.png"),
                  ),
                  backgroundColor: Colors.white,
                  radius: 25.0),
              title: Text(scoresList[index].item2),
              subtitle: Text(scoresList[index].item1),
            ),
          ),
        );
      },
    );
  }

  List<Tuple2<String,String>> _scoresMapToTuplesList(){
    List<Tuple2<String,String>> scoresList = [];
    scoresMap.forEach((a, b) {
      scoresList.add(Tuple2<String,String>(a ?? '', '$b' ?? ''));
    });
    return scoresList;
  }
}
