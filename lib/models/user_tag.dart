import 'package:flutter/widgets.dart' show required;

class UserTag {
  UserTag(
      {this.uid, this.name, this.phone, this.email, this.cid, this.fcmToken, this.photo, this.role, this.designation, this.companyName});
  String name;
  String phone;
  String uid;
  String cid;
  String companyName;
  String email;
  String fcmToken;
  String photo;
  String role;
  String designation;
  String _tag;

  String get tag => _tag ?? "@" + name.replaceAll(RegExp(r' '), '_') + '($email)';

  UserTag.fromFirebaseMap({@required String uid, @required Map<String, dynamic> user})
      : this(
            uid: uid,
            name: user['name'],
            phone: user['phone'],
            cid: user['cid'],
            email: user['email'],
            role: user['role'],
            designation: user['designation'],
            fcmToken: user['fcmToken'],
            photo: (user['photo'] ?? '').contains('https://firebasestorage.googleapis.com/v0/b/max-towers.appspot.com/o/')
                ? user['photo']
                : null,
            companyName: user['companyName']);

  Map<String, dynamic> toMap() => {
        'name': name,
        'tag': tag,
        'cid': cid,
        'uid': uid,
        'email': email,
      };

  UserTag.fromMap({String tag, Map user}) {
    this._tag = tag;
    this.name = user['name'];
    this.uid = user['uid'];
    this.cid = user['cid'];
    this.email = user['email'];
  }
}
