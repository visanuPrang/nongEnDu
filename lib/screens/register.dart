// ignore_for_file:  depend_on_referenced_packages, prefer_typing_uninitialized_variables, use_build_context_synchronously, duplicate_ignore

import 'package:bordered_text/bordered_text.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nongendu/main.dart';
import 'package:nongendu/screens/home.dart';
import 'package:nongendu/models/profile.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>(); // กำหนดเกณฑ์การกรอกข้อมูล
  UserProfile profile =
      UserProfile(userType: '', userId: '', eMail: '', name: '', password: '');
  final Future<FirebaseApp> firebase = Firebase.initializeApp();
  bool statusRedEye = true;
  String school = '@EnDu.com';
  late String userType = 'x';
  late String realEmail;
  late bool userFound;
  late String parentsName;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebase,
      builder: (context, AsyncSnapshot<FirebaseApp> snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 146, 86, 107),
              title: const Text(
                "Error...",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Color.fromARGB(255, 247, 225, 202)),
              ),
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
                'ลงทะเบียนผู้ใช้ระบบ',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Color.fromARGB(255, 247, 225, 202)),
              ),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(
                    Icons.settings_accessibility,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // no action needs
                  },
                )
              ],
            ),
            body: Center(
              // padding: const EdgeInsets.all(10),
              child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.center, //align text
                      children: [
                        const Image(
                            image: AssetImage("assets/images/Owl 203x203.png")),
                        const SizedBox(
                          height: 20,
                          child: ColoredBox(color: Colors.amber),
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
                                onPressed: () {},
                                icon: const Icon(
                                    size: 1,
                                    Icons.person_add_alt_1_outlined,
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
                                  realEmail = value;
                                });
                              },
                              onSaved: (eMail) {
                                if (userType == 'P' || userType == 'S') {
                                  profile.eMail = '$userType${eMail!}$school';
                                } else {
                                  profile.eMail =
                                      '$userType${eMail!}$school@com.com@com.com';
                                }
                              }),
                        ),
                        const SizedBox(height: 8),
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
                                  selectionColor:
                                      Color.fromARGB(255, 102, 82, 82),
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
                              onSaved: (password) {
                                profile.password = password!;
                              }),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: 50,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.app_registration,
                                color: Color.fromARGB(255, 250, 237, 224)),
                            label: const Text('ลงทะเบียน',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Color.fromARGB(255, 250, 237, 224))),
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
                              // var urlApi1 =
                              //     "https://visanup-laptop2/nongendu/test.php";
                              var urlApi1 =
                                  'https://script.google.com/macros/s/AKfycbx4yW34Z3d91J8Y_pCYJ3lk82ZwmeTGrS_GmgcCthHf-CcsQdDp_kSJN0H3Nh6q3b6RZg/exec';
                              final response = await Dio().get(urlApi1);
                              debugPrint('-----${response.data}-----');
                              debugPrint('-----${response.data.length}-----');
                              var xData = [];
                              parentsName = '';
                              for (var i = 0; i < response.data.length; i++) {
                                xData.add(response.data[i]['No'].toString());
                                debugPrint(
                                    '-----${response.data[i]['No']}-----');
                                if (response.data[i]['No'] == realEmail) {
                                  parentsName = response.data[i]['Name'];
                                }
                              }
                              userFound = xData.contains(realEmail);
                              profile.eMail =
                                  '$userType$school@com.com@com.com';
                              if (formKey.currentState!.validate() &&
                                  userFound) {
                                formKey.currentState?.save();
                                debugPrint(
                                    "debugPrint => e-mail: ${profile.eMail}  password = ${profile.password}  name = $parentsName");
                                try {
                                  await FirebaseAuth.instance
                                      .createUserWithEmailAndPassword(
                                          email: profile.eMail,
                                          password: profile.password)
                                      .then((value) {
                                    //รอให้ save เสร็จก่อน
                                    //prepare data
                                    Navigator.pop(context);
                                    Fluttertoast.showToast(
                                        msg:
                                            "ลงทะเบียนสำเร็จ e-mail: ${profile.eMail}  คุณ = $parentsName ",
                                        gravity: ToastGravity.CENTER_LEFT,
                                        backgroundColor: Colors.black,
                                        timeInSecForIosWeb: 10);
                                    formKey.currentState?.reset();
                                    // ignore: use_build_context_synchronously
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return const HomeScreen();
                                    }));
                                  });
                                } on FirebaseAuthException catch (e) {
                                  debugPrint(
                                      '${e.message}   ${e.hashCode}   ${e.code}');
                                  Fluttertoast.showToast(
                                      msg:
                                          "ลงทะเบียนไม่สำเร็จ\n ${e.message}   ${e.code}",
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.black,
                                      timeInSecForIosWeb: 10);
                                  // const Alert();
                                  if (e.code == 'email-already-in-use') {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: const Color.fromARGB(
                                              255, 102, 82, 82),
                                          content: Container(
                                            color: const Color.fromARGB(
                                                255, 102, 82, 82),
                                            child: const Text(
                                                'ท่านเคยลงทะเบียนไว้แล้ว',
                                                style: TextStyle(
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
                                                fontSize: 25,
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
                                    var strMsg = e.code;
                                    debugPrint('===> $strMsg ${e.message}');
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: const Color.fromARGB(
                                              255, 102, 82, 82),
                                          content: Container(
                                            color: const Color.fromARGB(
                                                255, 102, 82, 82),
                                            child: const Text(
                                                'กรุณาตรวจสอบ\n  -ต้องระบุว่าเปนผู้ปกครองหรือนักเรียน\n\t-ชื่อผู้ใช้ ดูจากรหัสที่โรงเรียนแจกให้\n  -รหัสผ่านต้องไม่น้อยกว่า 6 ตัวอักษร',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    backgroundColor:
                                                        Color.fromARGB(
                                                            255, 102, 82, 82),
                                                    color: Color.fromARGB(
                                                        255, 250, 237, 224))),
                                          ),
                                          title: const Text(
                                            'ข้อความแจ้งเตือน',
                                            style: TextStyle(
                                                fontSize: 25,
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
                                  }
                                }
                              }
                              if (!userFound) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: const Color.fromARGB(
                                          255, 102, 82, 82),
                                      content: Container(
                                        color: const Color.fromARGB(
                                            255, 102, 82, 82),
                                        child: const Text(
                                            'ไม่มีข้อมูลรหัสผู้ใชัของท่าน โปรดตรวจสอบ\nหรือติดต่อโรงเรียน',
                                            style: TextStyle(
                                                fontSize: 20,
                                                backgroundColor: Color.fromARGB(
                                                    255, 102, 82, 82),
                                                color: Color.fromARGB(
                                                    255, 250, 237, 224))),
                                      ),
                                      title: const Text(
                                        'ข้อความแจ้งข้อมูลผิดพลาด',
                                        style: TextStyle(
                                            fontSize: 25,
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
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20))),
                                            child: const Text('ปิด',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
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
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
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

// class CustomAlertDialog {
//       void showDialogAlert(BuildContext context) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return CustomAlertDialog(
//               conntent: Container(
//             width: MediaQuery.of(context).size.width / 1.2,
//             height: MediaQuery.of(context).size.height / 4,
//             color: Colors.white,
//           ));
//         },
//       );
//     }

// }

// class DialogAlert extends StatelessWidget {
//   const DialogAlert({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return TextButton(
//       onPressed: () => showDialog<String>(
//         context: context,
//         builder: (BuildContext context) => AlertDialog(
//           title: const Text('AlertDialog Title'),
//           content: const Text('AlertDialog description'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () => Navigator.pop(context, 'Cancel'),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(context, 'OK'),
//               child: const Text('OK'),
//             ),
//           ],
//         ),
//       ),
//       child: const Text('Show Dialog'),
//     );
//   }
// }

class Alert extends StatelessWidget {
  const Alert({super.key});

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}

class NewWidget extends StatelessWidget {
  const NewWidget({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      elevation: 0,
      backgroundColor: const Color.fromARGB(255, 102, 82, 82),
      child: _buildChild(context),
    );
  }
}

_buildChild(BuildContext context) => Container(
      height: 350,
      decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(12))),
      child: Column(
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 120,
            width: 120,
          )
        ],
      ),
    );
