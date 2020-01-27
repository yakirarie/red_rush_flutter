
class User {
  String uid;
  String dislpayName;

  User(String uid, String displayName){
    this.uid = uid;
    this.dislpayName = displayName == null ? "Guest" : displayName;
  }
}

class UserData{
  String uid;
  String dislpayName;
  var scores;
  int player;
  bool music;

  UserData(String uid, String displayName, var scores, int player, bool music){
    this.uid = uid;
    this.dislpayName = displayName;
    this.scores = scores;
    this.player = player;
    this.music = music;
  }


}