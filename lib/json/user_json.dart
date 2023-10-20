// To parse this JSON data, do
//
//     final about = aboutFromJson(jsonString);

import 'dart:convert';

List<XUser> userFromJson(String str) =>
    List<XUser>.from(json.decode(str).map((x) => XUser.fromJson(x)));

String userToJson(List<XUser> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class XUser {
  String? id;
  String? userType;
  String? userId;
  String? eMail;
  String? name;
  String? password;

  XUser({
    this.id,
    this.userType,
    this.userId,
    this.eMail,
    this.name,
    this.password,
  });

  factory XUser.fromJson(Map<String, dynamic> json) => XUser(
        id: json["id"],
        userType: json["user_type"],
        userId: json["user_id"],
        eMail: json["email"],
        name: json["name"],
        password: json["password"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_type": userType,
        "user_id": userId,
        "email": eMail,
        "name": name,
        "password": password,
      };
}
