class UserLogin {
  int id;
  String name;
  String password;
  String loginAt;

  UserLogin(
      {required this.id,
      required this.name,
      required this.password,
      required this.loginAt});

  factory UserLogin.fromSqfliteDatabase(Map<String, dynamic> map) => UserLogin(
        id: map['id']?.toInt() ?? 0,
        name: map['name'] ?? '',
        password: map['password'] ?? '',
        loginAt:
            DateTime.fromMicrosecondsSinceEpoch(map['login_at']).toString(),
      );
}
