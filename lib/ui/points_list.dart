import 'dart:math';

import 'package:flutter/material.dart';
import 'package:red_rush_flutter/models/scores.dart';
import 'package:red_rush_flutter/ui/score_tile.dart';

class PointsList extends StatefulWidget {
  final scores;
  final int numTop = 5;

  PointsList({Key key, this.scores}) : super(key: key);

  @override
  _PointsListState createState() => _PointsListState();
}

class _PointsListState extends State<PointsList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: min(widget.numTop, widget.scores.length),
      itemBuilder: (context, index) {
        return ScoreTile(
          scores: getTopPlayers(widget.scores, widget.numTop)[index],
        );
      },
    );
  }
}

List<Scores> getTopPlayers(List<Scores> scores, int numTop) {
  scores.sort((Scores a, Scores b) {
    int sumA = 0, sumB = 0;
    a.scoresMap.forEach((String _, int points) {
      sumA += points;
    });
    b.scoresMap.forEach((String _, int points) {
      sumB += points;
    });
    return sumA.compareTo(sumB);
  });
  scores = scores.reversed.toList();
  return scores.sublist(0, min(numTop, scores.length));
}
