//โครงสร้าง Database

class User {
  int id;
  String userType;
  String userId;
  String eMail;
  String name;
  String password;
  String createdAt;

  User(
      {required this.id,
      required this.userType,
      required this.userId,
      required this.eMail,
      required this.name,
      required this.password,
      required this.createdAt});

  factory User.fromSqfliteDatabase(Map<String, dynamic> map) => User(
        id: map['id']?.toInt() ?? 0,
        userType: map['userType'] ?? '',
        userId: map['userId'] ?? '',
        eMail: map['eMail'] ?? '',
        name: map['name'] ?? '',
        password: map['password'] ?? '',
        createdAt:
            DateTime.fromMicrosecondsSinceEpoch(map['created_at']).toString(),
      );
}
