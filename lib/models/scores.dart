import 'dart:collection';

class Scores {
  SplayTreeMap<String, int> scoresMap;
  String playerName;
  int player;

  Scores(String playerName, var scoresMap, int player){
    this.playerName = playerName;
    this.player = player;
    this.scoresMap = sortScoresMap(scoresMap);


    }
  }

  SplayTreeMap<String, int> sortScoresMap(var scores){
    return new SplayTreeMap<String,int>.from(scores, (a, b) {
      int aSize = int.parse(a.split("X")[0]);
      int bSize = int.parse(b.split("X")[0]);
      return aSize.compareTo(bSize);
    });
  }



