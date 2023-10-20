// ignore_for_file: unused_local_variable, unused_import, must_be_immutable, depend_on_referenced_packages, unused_element, body_might_complete_normally_nullable

import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:nongendu/screens/home.dart';
import 'package:nongendu/database/user_db.dart';
import 'package:nongendu/student_pages/main_student.dart';
import 'package:nongendu/variables.dart';

void main() {
  runApp(Timetable());
}

class Timetable extends StatelessWidget {
  Timetable({super.key});

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
    var jsonFeedback = jsonDecode(result.body);
    return jsonDecode(result.body);
  }

  final auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String dataDay, oldDay, dataSubj;
    String dataFrom, dataTo;
    String appBarTitle =
        'ตารางสอน\nชั้น/ห้อง ${variables.passGrade} ${variables.passClass}/${variables.passRoom}';
    var strUri =
        "https://script.google.com/macros/s/AKfycbwDv9uFkJ4pQR_ghiBWEca_Ao9XJ5uBWHLlVyXEQ-CcBpI0_o099PQIJT37EZzWbxt5/exec";
    IconData menuIcon = Icons.person;

    var xarrData = [];
    Future refresh() async {
      final result = await http.get(
        Uri.parse(
            "https://script.google.com/macros/s/AKfycbwDv9uFkJ4pQR_ghiBWEca_Ao9XJ5uBWHLlVyXEQ-CcBpI0_o099PQIJT37EZzWbxt5/exec"),
      );
      if (result.statusCode == 200) {
        setState(() => xarrData.clear());
        final List newItems = jsonDecode(result.body);
      }
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 143, 151, 242),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            auth.signOut().then((value) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) {
                return MainStudentPage();
              }));
            });
          },
        ),
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
      body: Container(
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
              xarrData = [];
              if (!snapshot.hasData) {
                const Center(
                    child: Text(
                  'ไม่มีข้อมูลตารางสอน',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                ));
              }
              if (snapshot.hasData) {
                for (var i = 0; i < snapshot.data.length; i++) {
                  if (variables.passGrade == snapshot.data[i]['grade'] &&
                      variables.passClass ==
                          snapshot.data[i]['class'].toString() &&
                      variables.passRoom ==
                          snapshot.data[i]['room'].toString()) {
                    dataLength++;
                    xarrData.add(snapshot.data[i]);
                  }
                }
                var oldDay = 'xxx';
                debugPrint('${xarrData.length}');
                if (xarrData.isEmpty) {
                  return const Center(
                    child: Text(
                      'ไม่มีข้อมูลตารางสอน',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 102, 82, 82),
                      ),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: refresh,
                  child: ListView.builder(
                    itemCount: xarrData.length,
                    itemBuilder: (BuildContext context, int index) {
                      index == 0
                          ? oldDay = 'xxx'
                          : oldDay = xarrData[index - 1]['day'].toString();
                      if (xarrData.isNotEmpty) {
                        return ViewTimetable1(
                          dataDay: xarrData[index]['day'].toString(),
                          showHeader:
                              oldDay != xarrData[index]['day'].toString(),
                          dataCode: xarrData[index]['code'].toString(),
                          dataSubj: xarrData[index]['subject'].toString(),
                          dataFrom: xarrData[index]['durationFrom'].toString(),
                          dataTo: xarrData[index]['durationTo'].toString(),
                          oldDay: oldDay,
                        );
                      }
                    },
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
        //),
      ),
    );
  }
}

class ViewTimetable extends StatelessWidget {
  final String dataDay, dataSubj;
  final String dataFrom, dataTo;
  const ViewTimetable(
      {super.key,
      required this.dataDay,
      required this.dataSubj,
      required this.dataFrom,
      required this.dataTo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Row(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(dataSubj),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  dataFrom.toString(),
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  dataTo.toString(),
                  style: const TextStyle(fontSize: 5),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
      ]),
    );
  }
}

row({required List<Container> children}) {}

class ViewTimetable1 extends StatelessWidget {
  final String dataDay, dataCode, dataSubj, oldDay;
  final String dataFrom, dataTo;
  final bool showHeader;
  const ViewTimetable1({
    super.key,
    required this.dataDay,
    required this.dataCode,
    required this.dataSubj,
    required this.dataFrom,
    required this.dataTo,
    required this.showHeader,
    required this.oldDay,
  });

  Color _randomBackgroundColor() {
    List<Color> colors = [Colors.red, Colors.green, Colors.amber, Colors.black];

    return colors[Random().nextInt(colors.length)];
  }

  /// With this you can get the Color either black or white
  Color _textColorForBackground(Color backgroundColor) {
    if (ThemeData.estimateBrightnessForColor(backgroundColor) ==
        Brightness.dark) {
      return Colors.black;
    }

    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = _randomBackgroundColor();
    final counterTextStyle = GoogleFonts.montserrat(
      fontWeight: FontWeight.bold,
      fontSize: 20,
      textStyle: Theme.of(context).textTheme.displaySmall,
    );
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          showHeader == true
              ? const SizedBox(
                  height: 10,
                )
              : const SizedBox(
                  height: 0,
                ),
          showHeader == true
              ? Table(
                  border: TableBorder.all(
                      color: const Color.fromARGB(255, 232, 227, 227)),
                  columnWidths: const {
                    0: FixedColumnWidth(350),
                  },
                  children: [
                    TableRow(children: [
                      Container(
                        height: 30,
                        color: dataDay == 'จันทร์'
                            ? const Color.fromARGB(255, 255, 249, 154)
                            : (dataDay == 'อังคาร'
                                ? const Color.fromARGB(255, 250, 216, 226)
                                : (dataDay == 'พุธ'
                                    ? const Color.fromARGB(255, 176, 221, 162)
                                    : (dataDay == 'พุฤหัสบดี'
                                        ? const Color.fromARGB(
                                            255, 246, 199, 152)
                                        : (dataDay == 'ศุกร์'
                                            ? const Color.fromARGB(
                                                255, 192, 248, 250)
                                            : (dataDay == 'เสาร์'
                                                ? const Color.fromARGB(
                                                    255, 209, 157, 249)
                                                : const Color.fromARGB(
                                                    255, 254, 43, 43)))))),
                        child: Text(
                          "   $dataDay",
                          style: counterTextStyle,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ])
                  ],
                )
              : Table(),
          showHeader == true
              ? Table(
                  border: TableBorder.all(
                      color: const Color.fromARGB(255, 232, 227, 227)),
                  columnWidths: const {
                    0: FixedColumnWidth(70),
                    1: FixedColumnWidth(170),
                    2: FixedColumnWidth(55),
                    3: FixedColumnWidth(55)
                  },
                  children: [
                    TableRow(children: [
                      Container(
                        height: 30,
                        color: const Color.fromARGB(255, 242, 236, 228),
                        // margin: const EdgeInsets.all(10.0),
                        child: const Text(
                          'รหัส',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        height: 30,
                        color: const Color.fromARGB(255, 242, 236, 228),
                        // margin: const EdgeInsets.all(10.0),
                        child: const Text(
                          'วิชา',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        height: 30,
                        color: const Color.fromARGB(255, 242, 236, 228),
                        // margin: const EdgeInsets.all(10),
                        child: const Text(
                          'ตั้งแต่',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        height: 30,
                        color: const Color.fromARGB(255, 242, 236, 228),
                        // margin: const EdgeInsets.all(10),
                        child: const Text(
                          'ถึง',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ])
                  ],
                )
              : Table(),
          Table(
            border: TableBorder.all(
                color: const Color.fromARGB(255, 232, 227, 227)),
            columnWidths: const {
              0: FixedColumnWidth(70),
              1: FixedColumnWidth(170),
              2: FixedColumnWidth(55),
              3: FixedColumnWidth(55)
            },
            children: [
              TableRow(children: [
                Container(
                  height: 27,
                  color: const Color.fromARGB(255, 247, 247, 247),
                  child: Text(
                    dataCode,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // ignore: sized_box_for_whitespace
                Container(
                  height: 27,
                  color: const Color.fromARGB(255, 247, 247, 247),
                  child: Text(
                    ' $dataSubj',
                    style: const TextStyle(
                      fontSize: 15,
                      // color: _textColorForBackground(bgColor),
                    ),
                    textAlign: TextAlign.justify,
                    // softWrap: const bool.fromEnvironment('backGround'),
                  ),
                ),
                Container(
                  height: 27,
                  color: const Color.fromARGB(255, 247, 247, 247),
                  child: Text(
                    '$dataFrom ',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  height: 27,
                  color: const Color.fromARGB(255, 247, 247, 247),
                  child: Text(
                    '$dataTo ',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ]),
            ],
          )
        ],
      ),
    );
  }
}
