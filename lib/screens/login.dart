// ignore_for_file: use_build_context_synchronously, unused_local_variable
// import 'dart:io';

import 'package:bordered_text/bordered_text.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:nongendu/json/about.dart';
// import 'package:nongendu/json/user_json.dart';
import 'package:nongendu/student_pages/main_student.dart';
import 'package:nongendu/screens/home.dart';
import 'package:nongendu/models/profile.dart';
import 'package:nongendu/database/user_db.dart';
import 'package:nongendu/variables.dart';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Future<int>? futureUser;
  final userDB = UserDB();

  final formKey = GlobalKey<FormState>(); // กำหนดเกณฑ์การกรอกข้อมูล
  UserProfile profile =
      UserProfile(userType: '', userId: '', eMail: '', name: '', password: '');
  final Future<FirebaseApp> firebase = Firebase.initializeApp();
  bool statusRedEye = true;
  String school = '@EnDu.com';
  late String userType = 'x';
  late String userId = '';
  late String userName = '';
  late String passworD = '';
  late bool userFound;
  late String urlApi1 = '';
  late String userEmail = '';
  late String screenPagePS = '';

  @override
  void initState() {
    super.initState();
    statusRedEye = true;
    // deleteFile();
    // fetchUser();
  }

  void deleteFile() async {}

  void fetchUser() {
    setState(() async {
      await userDB.create(
          id: 0,
          userType: 'P',
          userId: '1',
          eMail: 'p1@EnDu.com',
          name: 'parents01',
          password: '111111');
      var user = userDB.fetchById('1', 'P') as Future<int>?;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebase,
      builder: (context, AsyncSnapshot<FirebaseApp> snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Error..."),
            ),
            body: Center(
              child: Text("${snapshot.error}"),
            ),
          );
        }

        // bool error = false;
        return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 146, 86, 107),
              // title: const Icon(Icons.cancel),
              title: const Text(
                'เข้าสู่ระบบ',
                style: TextStyle(
                    color: Color.fromARGB(255, 247, 225, 202),
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0),
              ),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(
                    Icons.login,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // do something
                  },
                )
              ],
            ),
            body: Center(
              child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.center, //align text
                      children: [
                        const SizedBox(height: 10),
                        const Image(
                            width: 150,
                            height: 150,
                            image: AssetImage("assets/images/Owl 203x203.png")),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                            height: 48,
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 146, 86, 107),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                                onPressed: () async {
                                  String hexString = "e0b8a7";
                                  //"e0b8a7e0b8b4e0b8a9e0b893e0b8b820e0b89be0b8a3e0b8b2e0b887e0b981e0b889e0b988e0b887";
                                  List<String> splitted = [];
                                  for (int i = 0;
                                      i < hexString.length;
                                      i = i + 2) {
                                    splitted.add(hexString.substring(i, i + 2));
                                  }
                                  const CircularProgressIndicator(
                                    backgroundColor:
                                        Color.fromARGB(255, 102, 82, 82),
                                    color: Color.fromARGB(255, 250, 237, 224),
                                  );
                                  urlApi1 =
                                      'https://script.google.com/macros/s/AKfycbx4yW34Z3d91J8Y_pCYJ3lk82ZwmeTGrS_GmgcCthHf-CcsQdDp_kSJN0H3Nh6q3b6RZg/exec';
                                  if (userType == 'S') {
                                    urlApi1 =
                                        'https://script.google.com/macros/s/AKfycbymyb_rzc08q6MazI41HX9GOSFpSXBxPda6zwqFloBCBH_S4x8edVT3HkyOGa5KVCPGWw/exec';
                                  }
                                  final response = await Dio().get(urlApi1);
                                  var xData = [];
                                  userName = '';
                                  for (var i = 0;
                                      i < response.data.length;
                                      i++) {
                                    xData
                                        .add(response.data[i]['No'].toString());
                                    if (response.data[i]['No'].toString() ==
                                        userId) {
                                      userName = response.data[i]['Name'];
                                      userEmail = response.data[i]['e-Mail'];
                                    }
                                  }
                                  userFound = xData.contains(userId);
                                  if (userType == '') userType = 'x';
                                  if (userId == '') userId = '0';
                                  var user =
                                      await userDB.fetchById(userType, userId);
                                },
                                icon: const Icon(Icons.person_2_outlined,
                                    size: 1,
                                    color: Color.fromARGB(255, 146, 86, 107)),
                                label: BorderedText(
                                  strokeWidth: 3.5,
                                  strokeColor:
                                      const Color.fromARGB(255, 250, 237, 224),
                                  child: const Text(
                                    'ข้อมูลผู้ใช้งาน',
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 146, 86, 107),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25.0),
                                  ),
                                ))),
                        const SizedBox(height: 3),
                        Center(
                          widthFactor: MediaQuery.of(context).size.width * 0.8,
                          child: Table(
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.top,
                              columnWidths: const {
                                0: FixedColumnWidth(165.0),
                                1: FixedColumnWidth(155.0),
                              },
                              children: [
                                TableRow(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: const Color.fromARGB(
                                                255, 102, 82, 82)),
                                        borderRadius: BorderRadius.circular(20),
                                        color: const Color.fromARGB(
                                            255, 250, 237, 224),
                                      ),
                                      margin: const EdgeInsets.all(5.0),
                                      child: ListTile(
                                        visualDensity: const VisualDensity(
                                            horizontal: -4, vertical: -4),
                                        focusColor: const Color.fromARGB(
                                            255, 250, 237, 224),
                                        horizontalTitleGap: 0,
                                        title: const Text(
                                          'ผู้ปกครอง',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Color.fromARGB(
                                                255, 102, 82, 82),
                                          ),
                                        ),
                                        leading: Radio(
                                          fillColor: MaterialStateProperty
                                              .resolveWith<Color>(
                                                  (Set<MaterialState> states) {
                                            if (states.contains(
                                                MaterialState.disabled)) {
                                              return const Color.fromARGB(
                                                  255, 102, 82, 82);
                                            }
                                            return const Color.fromARGB(
                                                255, 102, 82, 82);
                                          }),
                                          value: 'P',
                                          groupValue: userType,
                                          onChanged: (value) {
                                            setState(() {
                                              userType = value!;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: const Color.fromARGB(
                                                255, 102, 82, 82)),
                                        borderRadius: BorderRadius.circular(20),
                                        color: const Color.fromARGB(
                                            255, 250, 237, 224),
                                      ),
                                      margin: const EdgeInsets.all(5.0),
                                      child: ListTile(
                                        visualDensity: const VisualDensity(
                                            horizontal: -4, vertical: -4),
                                        focusColor: const Color.fromARGB(
                                            255, 250, 237, 224),
                                        horizontalTitleGap: 0,
                                        title: const Text(
                                          'นักเรียน',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Color.fromARGB(
                                                255, 102, 82, 82),
                                          ),
                                        ),
                                        leading: Radio(
                                          fillColor: MaterialStateProperty
                                              .resolveWith<Color>(
                                                  (Set<MaterialState> states) {
                                            if (states.contains(
                                                MaterialState.disabled)) {
                                              return const Color.fromARGB(
                                                  255, 102, 82, 82);
                                            }
                                            return const Color.fromARGB(
                                                255, 102, 82, 82);
                                          }),
                                          value: 'S',
                                          groupValue: userType,
                                          onChanged: (value) {
                                            setState(() {
                                              userType = value!;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ]),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 45,
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: TextFormField(
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: Color.fromARGB(255, 250, 237, 224),
                                prefixIcon: Icon(
                                  Icons.perm_identity,
                                  color: Color.fromARGB(255, 102, 82, 82),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 102, 82, 82)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 102, 82, 82)),
                                ),
                                label: Text(
                                  'รหัสผู้ใช้',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 102, 82, 82)),
                                ),
                              ),
                              keyboardType:
                                  TextInputType.number, //type of keyboard
                              onChanged: (value) {
                                setState(() {
                                  userId = value;
                                });
                              },
                              onSaved: (email) {
                                if (userType == 'P' || userType == 'S') {
                                  profile.eMail = '$userType${email!}$school';
                                } else {
                                  profile.eMail = 'please specify user type.';
                                  // profile.eMail =
                                  //     '$userType${email!}$school@com.com@com.com';
                                }
                              }),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        SizedBox(
                          height: 45,
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: TextFormField(
                              obscureText: statusRedEye,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor:
                                    const Color.fromARGB(255, 250, 237, 224),
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: Color.fromARGB(255, 102, 82, 82),
                                ),
                                label: const Text(
                                  'รหัสผ่าน',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 102, 82, 82)),
                                ),
                                suffixIcon: IconButton(
                                    color:
                                        const Color.fromARGB(255, 102, 82, 82),
                                    icon: statusRedEye
                                        ? const Icon(Icons.visibility)
                                        : const Icon(Icons.visibility_off),
                                    onPressed: () {
                                      setState(() {
                                        statusRedEye = !statusRedEye;
                                      });
                                    }),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 102, 82, 82)),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 102, 82, 82)),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  passworD = value;
                                });
                              },
                              onSaved: (password) {
                                profile.password = password!;
                              }),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: 50,
                          child: ElevatedButton.icon(
                            label: const Text('เข้าสู่ระบบ',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Color.fromARGB(255, 250, 237, 224))),
                            icon: const Icon(
                              Icons.login,
                              color: Color.fromARGB(255, 250, 237, 224),
                            ),
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 102, 82, 82),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20))),
                            onPressed: () async {
                              const CircularProgressIndicator(
                                backgroundColor:
                                    Color.fromARGB(255, 102, 82, 82),
                                color: Color.fromARGB(255, 250, 237, 224),
                              );
                              urlApi1 =
                                  'https://script.google.com/macros/s/AKfycbx4yW34Z3d91J8Y_pCYJ3lk82ZwmeTGrS_GmgcCthHf-CcsQdDp_kSJN0H3Nh6q3b6RZg/exec';
                              if (userType == 'S') {
                                urlApi1 =
                                    'https://script.google.com/macros/s/AKfycbymyb_rzc08q6MazI41HX9GOSFpSXBxPda6zwqFloBCBH_S4x8edVT3HkyOGa5KVCPGWw/exec';
                              }
                              final response = await Dio().get(urlApi1);
                              var xData = [];
                              userName = '';
                              for (var i = 0; i < response.data.length; i++) {
                                xData.add(response.data[i]['No'].toString());
                                if (response.data[i]['No'].toString() ==
                                    userId) {
                                  userName = response.data[i]['Name'];
                                  userEmail = response.data[i]['e-Mail'];
                                }
                              }
                              userFound = xData.contains(userId);
                              var user =
                                  await userDB.fetchById(userType, userId);
                              if (formKey.currentState!.validate()) {
                                formKey.currentState?.save();
                                try {
                                  await FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                          email: profile.eMail,
                                          password: profile.password)
                                      .then((value) {
                                    formKey.currentState?.reset();
                                    userDB.update(
                                        id: 0,
                                        userType: userType,
                                        userId: userId,
                                        eMail: profile.eMail,
                                        name: userName,
                                        password: passworD);
                                    variables.passUserName = userName;
                                    variables.passUserType = userType;
                                    variables.passUserId = userId;
                                    // if (userId == 'T') {
                                    //   screenPagePS = 'หน้าหลักคุณครู';
                                    //   Navigator.pushReplacement(context,
                                    //       MaterialPageRoute(builder: (context) {
                                    //     return MainStudentPage();
                                    //   }));
                                    // }
                                    screenPagePS = 'หน้าหลักนักเรียน';
                                    Navigator.pushReplacement(context,
                                        MaterialPageRoute(builder: (context) {
                                      return MainStudentPage();
                                    }));
                                  });
                                } on FirebaseAuthException catch (e) {
                                  Text(
                                      'e.message ${e.message}  e.code ${e.code}');
                                  Fluttertoast.showToast(
                                      msg:
                                          "เข้าสู่ระบบไม่สำเร็จ\n ${e.message}   ${e.code}",
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.black,
                                      timeInSecForIosWeb: 10);
                                  // const Alert();
                                  if (e.code == 'user-not-found' ||
                                      e.code == 'wrong-password' ||
                                      e.code == 'channel-error') {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: const Color.fromARGB(
                                              255, 102, 82, 82),
                                          content: Container(
                                            color: const Color.fromARGB(
                                                255, 102, 82, 82),
                                            child: Text(
                                                'โปรดตรวจสอบรหัสผู้ใช้หรือรหัสผ่าน\nCode: ${e.code}',
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    backgroundColor:
                                                        Color.fromARGB(
                                                            255, 102, 82, 82),
                                                    color: Color.fromARGB(
                                                        255, 250, 237, 224))),
                                          ),
                                          title: const Text(
                                            'ข้อความแจ้งข้อมูลผิดพลาด',
                                            style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                backgroundColor: Color.fromARGB(
                                                    255, 102, 82, 82),
                                                color: Color.fromARGB(
                                                    255, 250, 237, 224)),
                                          ),
                                          // content: const Text("Dialog Content"),
                                          actions: [
                                            SizedBox(
                                              height: 50,
                                              width: 320,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            255, 250, 237, 224),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20))),
                                                child: const Text('ปิด',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20,
                                                        color: Color.fromARGB(
                                                            255, 102, 82, 82))),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            )
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    if (profile.eMail ==
                                        'please specify user type.') {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 102, 82, 82),
                                            content: Container(
                                              color: const Color.fromARGB(
                                                  255, 102, 82, 82),
                                              child: const Text(
                                                  "โปรดระบุประเภทผู้ใช้ ว่าเปนนักเรียน\nหรือผู้ปกครอง...",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      backgroundColor:
                                                          Color.fromARGB(
                                                              255, 102, 82, 82),
                                                      color: Color.fromARGB(
                                                          255, 250, 237, 224))),
                                            ),
                                            title: const Text(
                                              'แจ้งเตือนข้อมูลผิดพลาด',
                                              style: TextStyle(
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.bold,
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                          255, 102, 82, 82),
                                                  color: Color.fromARGB(
                                                      255, 250, 237, 224)),
                                            ),
                                            // content: const Text("Dialog Content"),
                                            actions: [
                                              SizedBox(
                                                height: 50,
                                                width: 320,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          const Color.fromARGB(
                                                              255,
                                                              250,
                                                              237,
                                                              224),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20))),
                                                  child: const Text('ปิด',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 20,
                                                          color: Color.fromARGB(
                                                              255,
                                                              102,
                                                              82,
                                                              82))),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              )
                                            ],
                                          );
                                        },
                                      );
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 102, 82, 82),
                                            content: Container(
                                              color: const Color.fromARGB(
                                                  255, 102, 82, 82),
                                              child: Text(
                                                  "กรุณาตรวจสอบรหัสผู้ใช้/รหัสผ่าน\n\n${e.code}:\n${e.message}",
                                                  style: const TextStyle(
                                                      fontSize: 20,
                                                      backgroundColor:
                                                          Color.fromARGB(
                                                              255, 102, 82, 82),
                                                      color: Color.fromARGB(
                                                          255, 250, 237, 224))),
                                            ),
                                            title: const Text(
                                              'แจ้งข้อมูลผิดพลาด',
                                              style: TextStyle(
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.bold,
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                          255, 102, 82, 82),
                                                  color: Color.fromARGB(
                                                      255, 250, 237, 224)),
                                            ),
                                            // content: const Text("Dialog Content"),
                                            actions: [
                                              SizedBox(
                                                height: 50,
                                                width: 320,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          const Color.fromARGB(
                                                              255,
                                                              250,
                                                              237,
                                                              224),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20))),
                                                  child: const Text('ปิด',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 20,
                                                          color: Color.fromARGB(
                                                              255,
                                                              102,
                                                              82,
                                                              82))),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              )
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  }
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: 50,
                            child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 102, 82, 82),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20))),
                                onPressed: () {
                                  formKey.currentState?.reset();
                                  Navigator.pushReplacement(context,
                                      MaterialPageRoute(builder: (context) {
                                    return const HomeScreen();
                                  }));
                                },
                                icon: const Icon(Icons.cancel_outlined,
                                    color: Color.fromARGB(255, 250, 237, 224)),
                                label: const Text('ยกเลิก',
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Color.fromARGB(
                                            255, 250, 237, 224)))))
                      ],
                    ),
                  )),
            ));
      },
    );
  }
}
