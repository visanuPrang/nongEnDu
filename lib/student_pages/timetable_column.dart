// ignore_for_file: unused_local_variable, unused_import, depend_on_referenced_packages

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
        'ตารางเวลาเรียน\n${variables.passGrade} ${variables.passClass}/${variables.passRoom}';
    var strUri =
        "https://script.google.com/macros/s/AKfycbwDv9uFkJ4pQR_ghiBWEca_Ao9XJ5uBWHLlVyXEQ-CcBpI0_o099PQIJT37EZzWbxt5/exec";
    IconData menuIcon = Icons.person;
    return Scaffold(
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
        backgroundColor: const Color.fromARGB(255, 0, 21, 255),
        title: Text(
          appBarTitle,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 244, 186, 43)),
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
        child: FutureBuilder(
            future: fetchUsers(strUri),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              int dataLength = 0;
              var xarrData = [];
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
                return ListView.builder(
                  itemCount: xarrData.length,
                  itemBuilder: (BuildContext context, int index) {
                    var dataDay = xarrData[index]['day'].toString();
                    var dataSubj = xarrData[index]['subject'].toString();
                    var dataFrom = xarrData[index]['durationFrom'].toString();
                    var dataTo = xarrData[index]['durationTo'];
                    debugPrint(dataTo);
                    return ViewStudentDetail(
                      dataDay: xarrData[index]['day'].toString(),
                      dataSubj: xarrData[index]['subject'].toString(),
                      dataFrom: xarrData[index]['durationFrom'].toString(),
                      dataTo: xarrData[index]['durationTo'].toString(),
                    );
                  },
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
    );
  }
}

class ViewStudentDetail extends StatelessWidget {
  final String dataDay, dataSubj;
  final String dataFrom, dataTo;
  const ViewStudentDetail(
      {super.key,
      required this.dataDay,
      required this.dataSubj,
      required this.dataFrom,
      required this.dataTo});

  @override
  Widget build(BuildContext context) {
    // TableRow tableRow = TableRow(children: <Widget>[
    //   Padding(
    //     padding: const EdgeInsets.all(10),
    //     child: Text(dataSubj),
    //   ),
    //   Padding(
    //     padding: const EdgeInsets.all(10),
    //     child: Text(dataFrom),
    //   ),
    //   Padding(
    //     padding: const EdgeInsets.all(10),
    //     child: Text(dataTo),
    //   ),
    // ]);
    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text('xxx'),
    //   ),
    //   body: Center(
    //     child: Table(
    //       border: TableBorder.all(),
    //       defaultColumnWidth: const FixedColumnWidth(90),
    //       children: <TableRow>[
    //         tableRow,
    //         tableRow,
    //         tableRow,
    //         tableRow,
    //         tableRow,
    //         tableRow,
    //       ],
    //     ),
    //   ),
    // );
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
                Text(dataFrom.toString()),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(dataTo.toString()),
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
