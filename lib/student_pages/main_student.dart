// ignore_for_file: unused_local_variable, unused_import

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nongendu/screens/column_sizing.dart';
import 'package:nongendu/screens/home.dart';
import 'package:nongendu/database/user_db.dart';
import 'package:nongendu/student_pages/timetable.dart';
import 'package:nongendu/variables.dart';

void main() {
  runApp(MainStudentPage());
}

class MainStudentPage extends StatelessWidget {
  MainStudentPage({super.key});

  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'เมนู'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // ignore: prefer_typing_uninitialized_variables
  var userData;

  Future<List<dynamic>> fetchUsers(uriParse) async {
    final result = await http.get(
      Uri.parse(uriParse),
    );
    var xUser = auth.currentUser?.email;
    var jsonFeedback = jsonDecode(result.body);
    return jsonDecode(result.body);
  }

  final auth = FirebaseAuth.instance;

  late String userType = 'x';
  late String userId = '0';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var xUser = auth.currentUser?.email;
    var uGrade = variables.passGrade;
    var uClass = variables.passClass;
    var uRoom = variables.passRoom;
    String appBarTitle = '---';
    var strUri =
        "https://script.google.com/macros/s/AKfycbymyb_rzc08q6MazI41HX9GOSFpSXBxPda6zwqFloBCBH_S4x8edVT3HkyOGa5KVCPGWw/exec";
    if (variables.passUserType == 'P') {
      appBarTitle = "${widget.title}สำหรับผู้ปกครอง";
      IconData menuIcon = Icons.groups;
    } else {
      appBarTitle = "${widget.title}สำหรับนักเรียน";
      IconData menuIcon = Icons.person;
    }
    appBarTitle = "$appBarTitle\nคุณ ${variables.passUserName}";
    return Scaffold(
      appBar: AppBar(
        // leading: Icon(menuIcon),
        backgroundColor: const Color.fromARGB(255, 146, 86, 107),
        title: Text(
          appBarTitle,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 247, 225, 202)),
          textAlign: TextAlign.start,
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () {
              auth.signOut().then((value) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return const HomeScreen();
                }));
              });
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          alignment: Alignment.center,
          transformAlignment: Alignment.bottomCenter,
          constraints: const BoxConstraints.expand(),
          decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              image: DecorationImage(
                colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.3), BlendMode.dstIn),
                image: const AssetImage("assets/images/Owl.png"),
              )),
          child: FutureBuilder(
              future: fetchUsers(strUri),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                int dataLength = 0;
                var xarrData = [];
                if (snapshot.hasData) {
                  if (variables.passUserType == 'S') {
                    for (var i = 0; i < snapshot.data.length; i++) {
                      if (snapshot.data[i]['No'].toString() ==
                          variables.passUserId) {
                        dataLength++;
                        xarrData.add(snapshot.data[i]);
                      }
                    }
                  } else {
                    for (var i = 0; i < snapshot.data.length; i++) {
                      if (snapshot.data[i]['parents'].toString() ==
                          variables.passUserId) {
                        dataLength++;
                        xarrData.add(snapshot.data[i]);
                      }
                    }
                  }
                  return ListView.builder(
                    itemCount: xarrData.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ViewStudentDetail(
                          no: xarrData[index]['No'].toString(),
                          email: xarrData[index]['e-Mail'],
                          name: xarrData[index]['Name'],
                          parents: xarrData[index]['parents'].toString(),
                          id: xarrData[index]['id'],
                          grade: xarrData[index]['grade'],
                          iclass: xarrData[index]['class'].toString(),
                          room: xarrData[index]['room'].toString(),
                          image: xarrData[index]['image'],
                          expire: xarrData[index]['expire']);
                    },
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Color.fromARGB(255, 102, 82, 82),
                      color: Color.fromARGB(255, 250, 237, 224),
                    ),
                  );
                }
              }),
        ),
      ),
    );
  }
}

class ArrData {
  int? no;
  String? email;
  String? name;
  String? parents;
  String? id;
  String? grade;
  int? iclass;
  int? room;
  String? image;
  int? expire;

  ArrData(
      {this.no,
      this.email,
      this.name,
      this.parents,
      this.id,
      this.grade,
      this.iclass,
      this.room,
      this.image,
      this.expire});

  ArrData.fromJson(Map<String, dynamic> json) {
    no = json['No'];
    email = json['e-Mail'];
    name = json['Name'];
    parents = json['parents'];
    id = json['id'];
    grade = json['grade'];
    iclass = json['class'];
    room = json['room'];
    image = json['image'];
    expire = json['expire'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['No'] = no;
    data['e-Mail'] = email;
    data['Name'] = name;
    data['parents'] = parents;
    data['id'] = id;
    data['grade'] = grade;
    data['class'] = iclass;
    data['room'] = room;
    data['image'] = image;
    data['expire'] = expire;
    return data;
  }
}

class ViewStudentDetail extends StatelessWidget {
  final String email, name, parents, id, image;
  final String expire, no, grade, iclass, room;
  const ViewStudentDetail({
    super.key,
    required this.no,
    required this.email,
    required this.name,
    required this.parents,
    required this.id,
    required this.grade,
    required this.iclass,
    required this.room,
    required this.image,
    required this.expire,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Row(
          children: [
            SizedBox(
                height: 150,
                width: 150,
                child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(40)),
                    child: Image.network(image))),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('รหัส $id',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color.fromARGB(255, 0, 0, 99))),
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color.fromARGB(255, 0, 0, 99))),
                Text('ชั้น $grade $iclass/$room',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color.fromARGB(255, 0, 0, 99))),
              ],
            )
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 8,
            ),
            SizedBox(
              child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.top,
                  columnWidths: const {
                    1: FixedColumnWidth(100),
                    2: FixedColumnWidth(10),
                    3: FixedColumnWidth(100),
                    4: FixedColumnWidth(10),
                    5: FixedColumnWidth(100),
                  },
                  children: [
                    TableRow(children: [
                      const SizedBox(
                        height: 10,
                      ),
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        clipBehavior: Clip.hardEdge,
                        child: Container(
                          width: 100,
                          height: 100,
                          color: const Color.fromARGB(255, 102, 82, 82),
                          child: InkWell(
                            onTap: () {
                              variables.passGrade = grade;
                              variables.passClass = iclass;
                              variables.passRoom = room;
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (context) {
                                return Timetable();
                              }));
                            },
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.calendar_month_outlined,
                                    size: 50,
                                    color: Color.fromARGB(
                                        255, 250, 237, 224)), // <-- Icon
                                Text('ตารางสอน',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Color.fromARGB(
                                            255, 250, 237, 224))), // <-- Text
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        clipBehavior: Clip.hardEdge,
                        child: Container(
                          width: 100,
                          height: 100,
                          color: const Color.fromARGB(255, 102, 82, 82),
                          child: InkWell(
                            onTap: () {
                              variables.passGrade = grade;
                              variables.passClass = iclass;
                              variables.passRoom = room;
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor:
                                        const Color.fromARGB(255, 102, 82, 82),
                                    content: Container(
                                      color: const Color.fromARGB(
                                          255, 102, 82, 82),
                                      child: const Text('Not available...',
                                          style: TextStyle(
                                              fontSize: 20,
                                              backgroundColor: Color.fromARGB(
                                                  255, 102, 82, 82),
                                              color: Color.fromARGB(
                                                  255, 250, 237, 224))),
                                    ),
                                    title: const Text(
                                      'ผลการเรียน',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          backgroundColor:
                                              Color.fromARGB(255, 102, 82, 82),
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
                            },
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.calendar_month_outlined,
                                    size: 50,
                                    color: Color.fromARGB(
                                        255, 250, 237, 224)), // <-- Icon
                                Text('ผลการเรียน',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Color.fromARGB(
                                            255, 250, 237, 224))), // <-- Text
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        clipBehavior: Clip.hardEdge,
                        child: Container(
                          width: 100,
                          height: 100,
                          color: const Color.fromARGB(255, 102, 82, 82),
                          child: InkWell(
                            onTap: () {
                              variables.passGrade = grade;
                              variables.passClass = iclass;
                              variables.passRoom = room;
                              debugPrint(iclass);
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor:
                                        const Color.fromARGB(255, 102, 82, 82),
                                    content: Container(
                                      color: const Color.fromARGB(
                                          255, 102, 82, 82),
                                      child: const Text('Not available...',
                                          style: TextStyle(
                                              fontSize: 20,
                                              backgroundColor: Color.fromARGB(
                                                  255, 102, 82, 82),
                                              color: Color.fromARGB(
                                                  255, 250, 237, 224))),
                                    ),
                                    title: const Text(
                                      'กิจกรรม',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          backgroundColor:
                                              Color.fromARGB(255, 102, 82, 82),
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
                            },
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.emoji_emotions_outlined,
                                    size: 50,
                                    color: Color.fromARGB(
                                        255, 250, 237, 224)), // <-- Icon
                                Text('กิจกรรม',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Color.fromARGB(
                                            255, 250, 237, 224))), // <-- Text
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                    ]),
                  ]),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.top,
                  columnWidths: const {
                    0: FixedColumnWidth(10),
                    1: FixedColumnWidth(30),
                    2: FixedColumnWidth(100),
                    3: FixedColumnWidth(10),
                    4: FixedColumnWidth(100),
                    5: FixedColumnWidth(40),
                  },
                  children: [
                    TableRow(children: [
                      const SizedBox(
                        height: 10,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        clipBehavior: Clip.hardEdge,
                        child: Container(
                          width: 100,
                          height: 100,
                          color: const Color.fromARGB(255, 102, 82, 82),
                          child: InkWell(
                            onTap: () {
                              variables.passGrade = grade;
                              variables.passClass = iclass;
                              variables.passRoom = room;
                              debugPrint(iclass);
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor:
                                        const Color.fromARGB(255, 102, 82, 82),
                                    content: Container(
                                      color: const Color.fromARGB(
                                          255, 102, 82, 82),
                                      child: const Text('Not available...',
                                          style: TextStyle(
                                              fontSize: 20,
                                              backgroundColor: Color.fromARGB(
                                                  255, 102, 82, 82),
                                              color: Color.fromARGB(
                                                  255, 250, 237, 224))),
                                    ),
                                    title: const Text(
                                      'เวลาเรียน',
                                      style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          backgroundColor:
                                              Color.fromARGB(255, 102, 82, 82),
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
                            },
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.check_box_outlined,
                                    size: 50,
                                    color: Color.fromARGB(
                                        255, 250, 237, 224)), // <-- Icon
                                Text('เวลาเรียน',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Color.fromARGB(
                                            255, 250, 237, 224))), // <-- Text
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        clipBehavior: Clip.hardEdge,
                        child: Container(
                          width: 100,
                          height: 100,
                          color: const Color.fromARGB(255, 102, 82, 82),
                          child: InkWell(
                            onTap: () {
                              variables.passGrade = grade;
                              variables.passClass = iclass;
                              variables.passRoom = room;
                              debugPrint(iclass);
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor:
                                        const Color.fromARGB(255, 102, 82, 82),
                                    content: Container(
                                      color: const Color.fromARGB(
                                          255, 102, 82, 82),
                                      child: const Text('Not available...',
                                          style: TextStyle(
                                              fontSize: 20,
                                              backgroundColor: Color.fromARGB(
                                                  255, 102, 82, 82),
                                              color: Color.fromARGB(
                                                  255, 250, 237, 224))),
                                    ),
                                    title: const Text(
                                      'แนะแนว(ความถนัด)',
                                      style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          backgroundColor:
                                              Color.fromARGB(255, 102, 82, 82),
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
                            },
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.psychology_alt_outlined,
                                    size: 50,
                                    color: Color.fromARGB(
                                        255, 250, 237, 224)), // <-- Icon
                                Text('แนะแนว(ความถนัด)',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Color.fromARGB(
                                            255, 250, 237, 224))), // <-- Text
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                    ]),
                  ]),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
        const SizedBox(height: 16),
      ]),
    );
  }
}

row({required List<Container> children}) {}
