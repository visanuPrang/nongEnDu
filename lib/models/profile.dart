// ignore_for_file: camel_case_types

class UserProfile {
  String userType;
  String userId;
  String eMail;
  String name;
  String password;

  UserProfile(
      {required this.userType,
      required this.userId,
      required this.eMail,
      required this.name,
      required this.password});
}
