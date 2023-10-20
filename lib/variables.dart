class Variables {
  static final Variables _variables = Variables._internal();
  String passUserName = '---';
  String passStudentId = '---';
  String passUserId = '---';
  String passUserType = '---';
  String passGrade = '---';
  String passClass = '---';
  String passRoom = '---';
  factory Variables() {
    return _variables;
  }

  Variables._internal();
}

final variables = Variables();
// String passUserName = 'LoginScreen.userName';
