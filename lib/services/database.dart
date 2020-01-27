import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:red_rush_flutter/models/scores.dart';
import 'package:red_rush_flutter/models/user.dart';

class DatabaseService {
  final String uid;

  DatabaseService({this.uid});

  final CollectionReference usersCollection =
      Firestore.instance.collection("users");

  Future updateUserData(String name, var scores, int player) async {
    return await usersCollection.document(uid).setData({
      "name": name,
      "scores": scores,
      "player": player,
    });
  }

  List<Scores> _pointsListFromSnapshot(QuerySnapshot querySnapshot) {
    return querySnapshot.documents.map((doc) {
      return Scores(doc.data["name"] ?? '', doc.data["scores"] ?? {}, doc.data["player"] ?? 0);
    }).toList();
  }

  Stream<List<Scores>> get users {
    return usersCollection.snapshots().map(_pointsListFromSnapshot);
  }

  UserData _userDataFromSnapshot(DocumentSnapshot documentSnapshot) {
    return UserData(
        uid, documentSnapshot.data['name'], documentSnapshot.data['scores'], documentSnapshot.data['player'], documentSnapshot.data['music']);
  }

  Stream<UserData> get userData {
    return usersCollection.document(uid).snapshots().map(_userDataFromSnapshot);
  }

  Future deleteUser() async{
    return await usersCollection.document(uid).delete();

  }
}
