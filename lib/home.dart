// ignore_for_file: unused_local_variable, unused_import

import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainPage());
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'T.P.D.\nApartment'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 57, 6, 119),
        title: Text(
          widget.title,
          style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 247, 225, 202)),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: Container(
        alignment: Alignment.center,
        transformAlignment: Alignment.bottomCenter,
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            image: DecorationImage(
              colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.3), BlendMode.dstIn),
              image: const AssetImage('assets/images/TPDLogo.png'),
            )),
      ),
    );
  }
}
