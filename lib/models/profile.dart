class Profile {
  Profile(
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

  Profile.fromMap({Map<String, dynamic> user, String uid})
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
}
